#!/usr/bin/env python

usage = """usage: %prog [options] path1 path2 ...

diffstrings compares your primary locale with all your other locales to help you determine which new strings need to be translated.  It outputs XML files which can be translated, and then merged back into your strings files.

The path arguments supplied to this script should be the path containing your source files.  The file system will be searched to find the .lproj directories containing the Localizable.strings files that the script will read and write.
"""

import os.path, codecs, optparse, re, datetime
from xml.sax.saxutils import escape
from xml.dom import minidom

###################################################################################################

global xmlFormat
xmlFormat = {}

reLprojFileName = re.compile(r'(.+?)\.lproj')
reStringsFileName = re.compile(r'(.+?)\.strings')
reComment = re.compile(r'/\*(.*?)\*/')
reString = re.compile(r'\s*"((\\.|.)+?)"\s*=\s*"(.+?)";')
reVariable = re.compile(r'%(@|d|f|lld|\d+\.?f|\d+\.\d+f|\d+d)')
reEnumeratedVariable = re.compile('(%?\d+\$)')

defaultComment = "No comment provided by engineer."

###################################################################################################

def generateProjects(projects):
    for project in projects:
        project.generateStrings()

def diffProjects(projects, sourceLocaleName, focusedLocaleName=None, verbose=False, dryRun=False):
    compiledStrings = {}
    sourceMap = {}
    for project in projects:
        project.compileStrings(compiledStrings, focusedLocaleName)
        project.compileSourceMap(sourceMap)

    if sourceLocaleName not in compiledStrings:
        print "WARNING: No '%s' locale found!" % sourceLocaleName
    else:
        sourceStrings = compiledStrings[sourceLocaleName]

        if verbose:
            print "\n", "=" * 80
            print "* %s has %d total strings." \
                  % (sourceLocaleName, len(sourceStrings.strings))
            print "=" * 80

            for localeName, localizedStrings in compiledStrings.iteritems():
                if localizedStrings != sourceStrings:
                    sourceStrings.diffReport(localizedStrings)

        for localeName, localizedStrings in compiledStrings.iteritems():
            if localizedStrings != sourceStrings:
                translation = sourceStrings.diff(localizedStrings)
                if not dryRun:
                    translation.save(".", sourceMap=sourceMap)

def mergeProjects(projects, sourceLocaleName, focusedLocaleName=None, verbose=False, dryRun=False):
    translations = {}

    for project in projects:
        sourceStrings = project.condenseStringSourceFiles()
        sourceStrings.save()

        for localeName, localizedStrings in project.locales.iteritems():
            if not focusedLocaleName or focusedLocaleName == localeName:
                if localizedStrings.name in translations:
                    translation = translations[localizedStrings.name]
                else:
                    translation = Translation(localizedStrings.name)
                    translation.open(".")
                    translations[localizedStrings.name] = translation

                if translation.strings:
                    if verbose:
                        localizedStrings.mergeReport(sourceStrings, translation)

                    localizedStrings.mergeTranslation(sourceStrings, translation)
                    if not dryRun:
                        localizedStrings.save()
                else:
                    if verbose:
                        print "no translation.strings for %s, sad" % localeName

###################################################################################################

class XcodeProject(object):
    def __init__(self, path, sourceLocaleName):
        self.path = path
        self.sourceLocaleName = sourceLocaleName
        self.sourceLocalePath = self.__findStringsFile(sourceLocaleName, self.path)
        self.stringSourceFiles = list(self.__iterateSourceStrings())

        self.locales = {}
        for localeName, localizedStrings in self.__iterateLocalizableStrings():
            self.locales[localeName] = localizedStrings

    def condenseStringSourceFiles(self):
        """ Copies all strings from all sources files into a single file."""
        sourceStrings = LocalizableStrings(self.sourceLocaleName)

        sourceStrings.path = self.__findSourceStringsPath()
        if not sourceStrings.path:
            sourceStrings.path = os.path.join(self.sourceLocalePath, "Localizable.strings")

        for sourceFile in self.stringSourceFiles:
            sourceStrings.update(sourceFile)
        return sourceStrings

    def compileStrings(self, compiledStrings, focusedLocaleName=None):
        """ Copies all strings in a dictionary for each locale."""

        if not self.sourceLocaleName in compiledStrings:
            compiledStrings[self.sourceLocaleName] = LocalizableStrings(self.sourceLocaleName)
        compiledStringsFile = compiledStrings[self.sourceLocaleName]

        for sourceStrings in self.stringSourceFiles:
            compiledStringsFile.update(sourceStrings)

        if focusedLocaleName:
            locales = {focusedLocaleName: self.locales[focusedLocaleName]}
        else:
            locales = self.locales

        for localeName, sourceStrings in locales.iteritems():
            if not localeName in compiledStrings:
                compiledStringsFile = LocalizableStrings(localeName)
                compiledStrings[localeName] = compiledStringsFile
            else:
                compiledStringsFile = compiledStrings[localeName]

            compiledStringsFile.update(sourceStrings)

    def compileSourceMap(self, sourceMap):
        for sourceStrings in self.stringSourceFiles:
            for source in sourceStrings.strings:
                if not source in sourceMap:
                    sourceMap[source] = []

                name,ext = os.path.splitext(os.path.basename(sourceStrings.path))
                sourceMap[source].append(name)

    def generateStrings(self):
        buildPath = None

        cwd = os.getcwd()
        os.chdir(self.path)

        extras = ""
        if os.path.isdir(os.path.join(self.path, "Three20.xcodeproj")):
            extras = " -s TTLocalizedString"

        for fileName in os.listdir(self.path):
            name,ext = os.path.splitext(fileName)
            if ext == ".m":
                if not buildPath:
                    buildPath = self.__makeBuildPath()
                    if not os.path.isdir(buildPath):
                        os.makedirs(buildPath)

                command = "genstrings %s -o %s%s" % (fileName, buildPath, extras)
                print "   %s" % command
                os.system(command)

                resultPath = os.path.join(buildPath, "Localizable.strings")
                if os.path.isfile(resultPath):
                    renamedPath = os.path.join(buildPath, "%s.strings" % name)
                    os.rename(resultPath, renamedPath)

        os.chdir(cwd)

    def __findStringsFile(self, localeName, searchPath):
        dirName = "%s.lproj" % localeName
        localeDirPath = os.path.join(searchPath, dirName)
        if os.path.isdir(localeDirPath):
            return localeDirPath

        for name in os.listdir(searchPath):
            path = os.path.join(searchPath, name)
            if os.path.isdir(path):
                localeDirPath = self.__findStringsFile(localeName, path)
                if localeDirPath:
                    return localeDirPath

        return None

    def __iterateSourceStrings(self):
        buildPath = self.__makeBuildPath()
        if not os.path.exists(buildPath):
            for path in self.__findSourceStrings():
                yield path
        else:
            for fileName in os.listdir(buildPath):
                name,ext = os.path.splitext(fileName)
                if ext == ".strings":
                    strings = LocalizableStrings(self.sourceLocaleName)

                    filePath = os.path.join(buildPath, fileName)
                    strings.open(filePath)
                    yield strings

    def __findSourceStringsPath(self):
        for name in os.listdir(self.sourceLocalePath):
            m = reStringsFileName.match(name)
            if m:
                return os.path.join(self.sourceLocalePath, name)

    def __findSourceStrings(self):
        for name in os.listdir(self.sourceLocalePath):
            m = reStringsFileName.match(name)
            if m:
                strings = LocalizableStrings(self.sourceLocaleName)

                filePath = os.path.join(self.sourceLocalePath, name)
                strings.open(filePath)
                yield strings

    def __iterateLocalizableStrings(self):
        dirPath = os.path.dirname(self.sourceLocalePath)
        for dirName in os.listdir(dirPath):
            m = reLprojFileName.match(dirName)
            if m:
                localeName = m.groups()[0]
                if localeName != self.sourceLocaleName:
                    strings = LocalizableStrings(localeName)

                    localeDirPath = os.path.join(dirPath, dirName)
                    for name in os.listdir(localeDirPath):
                        m = reStringsFileName.match(name)
                        if m:
                            filePath = os.path.abspath(os.path.join(localeDirPath, name))
                            strings.open(filePath)
                            break

                    yield localeName, strings

    def __makeBuildPath(self):
        return os.path.join(self.path, "build", "i18n")

###################################################################################################

class LocalizableStrings(object):
    def __init__(self, name):
        self.name = name
        self.path = None
        self.strings = {}
        self.comments = {}

    def open(self, path):
        if os.path.isfile(path):
            self.path = path
            self.__parse()

    def save(self, path=None, suffix=""):
        text = self.generate()
        if text:
            if path:
                filePath = self.__makePath(path, suffix)
            else:
                filePath = self.path

            print "***** Saving %s" % filePath
            f = codecs.open(filePath, 'w', 'utf-16')
            f.write(text)
            f.close()

    def generate(self):
        lines = []

        # This may not sort non-English strings sensibly, but the order itself
        # doesn't matter - this is just so that the strings come out in some
        # consistent order every time. (Less efficient, but oh well.)
        for source in sorted(self.strings.keys()):
            if source in self.comments:
                comment = self.comments[source]
                lines.append("/* %s */" % comment)
            lines.append('"%s" = "%s";\n' % (source, self.strings[source]))

        return "\n".join(lines)

    def mergeTranslation(self, sourceStrings, translation):
        for source in sourceStrings.strings:
            sourceEnum = enumerateStringVariables(source)
            if sourceEnum in translation.strings:
                targetEnum = translation.strings[sourceEnum]
                target = denumerateStringVariables(targetEnum)
                self.strings[source] = target

    def update(self, other):
        self.strings.update(other.strings)
        self.comments.update(other.comments)

    def diff(self, localizedStrings):
        translation = Translation(localizedStrings.name)

        for source, target in self.strings.iteritems():
            sourceEnum = enumerateStringVariables(source)

            if source in localizedStrings.strings:
                target = localizedStrings.strings[source]
                translation.translated[sourceEnum] = True

            targetEnum = enumerateStringVariables(target)
            translation.strings[sourceEnum] = targetEnum

            if source in self.comments:
                translation.comments[sourceEnum] = self.comments[source]

        return translation

    def diffReport(self, localizedStrings):
        name = localizedStrings.name
        newStrings = list(self.__compare(localizedStrings))
        obsoleteStrings = list(localizedStrings.__compare(self))
        troubleStrings = list(self.__compareSizes(localizedStrings))

        print "\n", "=" * 80

        if not len(newStrings):
            if len(obsoleteStrings):
                print "%s is fully translated, but has %s obsolete strings" \
                      % (name, len(obsoleteStrings))
            else:
                print "%s is fully translated" % name
        else:
            existingCount = len(self.strings) - len(newStrings)
            if len(obsoleteStrings):
                print "%s has %s new strings, %s translated, and %s obsolete."\
                      % (name, len(newStrings), existingCount, len(obsoleteStrings))
            else:
                print "%s has %s new strings, with %s already translated."\
                      % (name, len(newStrings), existingCount)
        print "=" * 80

        if len(newStrings):
            print "\n---- %s NEW STRINGS ---\n" % name
            print "\n".join(newStrings)

        if len(obsoleteStrings):
            print "\n---- %s OBSOLETE STRINGS ---\n" % name
            print "\n".join(obsoleteStrings)

        if len(troubleStrings):
            print "\n---- %s TROUBLE STRINGS ---\n" % name

            for source, diff in sorted(troubleStrings, lambda a,b: cmp(b[1], a[1])):
                print "%3d. %s " % (diff, codecs.encode(source, 'utf-8'))
                print "     %s " % codecs.encode(localizedStrings.strings[source], 'utf-8')

        print "\n"

    def mergeReport(self, sourceStrings, translation):
        name = self.name
        updatedStrings = []
        ignoredStrings = []

        for source in sourceStrings.strings:
            sourceEnum = enumerateStringVariables(source)
            if sourceEnum in translation.strings:
                targetEnum = translation.strings[sourceEnum]
                target = denumerateStringVariables(targetEnum)
                if source not in self.strings or target != self.strings[source]:
                    updatedStrings.append(source)
            else:
                ignoredStrings.append(source)

        print "\n", "=" * 80
        print self.path
        print "%d newly translated strings and %d untranslated strings" \
              % (len(updatedStrings), len(ignoredStrings))
        print "=" * 80

        if len(updatedStrings):
            print "\n---- %s NEWLY TRANSLATED STRINGS ---\n" % name
            print "\n".join(updatedStrings)

        if len(ignoredStrings):
            print "\n---- %s UNTRANSLATED STRINGS ---\n" % name
            print "\n".join(ignoredStrings)

    def __makePath(self, path=".", suffix=""):
        fileName = "Localizable%s.strings" % (suffix)
        return os.path.abspath(os.path.join(path, fileName))

    def __parse(self):
        lastIdentical = False
        lastComment = None
        for line in openWithProperEncoding(self.path):
            m = reString.search(line)
            if m:
                source = m.groups()[0]
                target = m.groups()[2]
                self.strings[source] = target
                if lastComment:
                    self.comments[source] = lastComment
                    lastComment = None
                if lastIdentical:
                    lastIdentical = False
            else:
                m = reComment.search(line)
                if m:
                   comment = m.groups()[0].strip()
                   if comment != defaultComment:
                       lastComment = comment

    def __compare(self, other, compareStrings=False):
        for source, target in self.strings.iteritems():
            if source in other.strings:
                target = other.strings[source]
                if compareStrings and target == source:
                    yield source
            else:
                yield source

    def __compareSizes(self, other):
        for source, target in self.strings.iteritems():
            if source in other.strings:
                target = other.strings[source]
                ratio = float(len(target)) / len(source)
                diff = len(target) - len(source)
                if ratio > 1.3 and diff > 5:
                    yield (source, diff)

###################################################################################################

class Translation(object):
    def __init__(self, name):
        self.name = name
        self.path = None
        self.strings = {}
        self.translated = {}
        self.comments = {}

    def open(self, path=".", suffix=""):
        filePath = self.__makePath(path, suffix)
        if os.path.isfile(filePath):
            self.__parse(filePath)

    def save(self, path=None, suffix="", sourceMap=None):
        text = self.generate(sourceMap)
        if text:
            if path:
                filePath = self.__makePath(path, suffix)
            else:
                filePath = self.path

            print "***** Saving %s" % filePath
            #print codecs.encode(text, 'utf-8')

            f = codecs.open(filePath, 'w', 'utf-16')
            f.write(text)
            f.close()

    def generate(self, sourceMap=None):
        lines = []

        global xmlFormat
        prefix = xmlFormat['prefix']

        lines.append('<?xml version="1.0" encoding="utf-16"?>')
        lines.append('<%sexternal>' % prefix)
        lines.append('  <meta>')
        if xmlFormat['appName']:
            lines.append('    <appName>%s</appName>' % xmlFormat['appName'])
        lines.append('    <date>%s</date>' % datetime.datetime.now().strftime('%Y%m%d'))
        lines.append('    <locale>%s</locale>' % self.name)
        lines.append('  </meta>')

        for sourceFileName, sourceFileStrings in self.__invertSourceMap(sourceMap):
            lines.append("  <!-- %s -->" % sourceFileName)
            for source in sourceFileStrings:
                target = self.strings[source]

                lines.append("  <entry>")
                lines.append("    <%ssource>%s</%ssource>" % (prefix, escape(source), prefix))

                if source in self.translated:
                    lines.append("    <%sxtarget>%s</%sxtarget>" % (prefix, escape(target), prefix))
                else:
                    lines.append("    <%starget>%s</%starget>" % (prefix, escape(target), prefix))

                if source in self.comments:
                    lines.append("    <%sdescription>%s</%sdescription>"
                                 % (prefix, escape(self.comments[source]), prefix))

                lines.append("  </entry>")

        lines.append('</%sexternal>' % prefix)

        return "\n".join(lines)

    def __makePath(self, path=".", suffix=""):
        fileName = "%s%s.xml" % (self.name, suffix)
        return os.path.abspath(os.path.join(path, fileName))

    def __parse(self, filePath):
        self.path = filePath

        global xmlFormat
        prefix = xmlFormat['prefix']

        document = minidom.parse(filePath)
        for entry in document.documentElement.childNodes:
            if entry.nodeType == 1:
                source = None
                target = None
                translated = False

                sources = entry.getElementsByTagName("%ssource" % prefix)
                if len(sources):
                    source = sources[0]
                    source = source.childNodes[0].data

                targets = entry.getElementsByTagName("%sxtarget" % prefix)
                if not len(targets):
                    targets = entry.getElementsByTagName("%starget" % prefix)
                    translated = True

                if len(targets):
                    target = targets[0]
                    target = target.childNodes[0].data

                if source and target:
                   self.strings[source] = target
                   if translated:
                       self.translated[source] = True

    def __invertSourceMap(self, sourceMap):
        sourceFileMap = {}

        for sourceEnum in self.strings:
            source = denumerateStringVariables(sourceEnum)
            if source in sourceMap:
                sourcePaths = sourceMap[source]
                for sourcePath in sourcePaths:
                    if sourcePath not in sourceFileMap:
                        sourceFileMap[sourcePath] = []
                    sourceFileMap[sourcePath].append(sourceEnum)
                    break

        for sourceName, sourceFileStrings in sourceFileMap.iteritems():
            sourceFileStrings.sort()

        keys = sourceFileMap.keys()
        keys.sort()

        for key in keys:
            yield key, sourceFileMap[key]

###################################################################################################
##  Helpers

def openProjects(projectDirPaths, sourceLocaleName):
    for projectDirPath in projectDirPaths:
        yield XcodeProject(projectDirPath, sourceLocaleName)

def openWithProperEncoding(path):
    if not os.path.isfile(path):
        return []

    try:
        f = codecs.open(path, 'r', 'utf-16')
        lines = f.read().splitlines()
        f.close()
    except UnicodeError,exc:
        f = codecs.open(path, 'r', 'utf-8')
        lines = f.read().splitlines()
        f.close()

    return lines

def enumerateStringVariables(s):
    i = 1
    for var in reVariable.findall(s):
        s = s.replace("%%%s" % var, "%%%d$%s" % (i, var), 1)
        i += 1
    return s

def denumerateStringVariables(s):
    for var in reEnumeratedVariable.findall(s):
        s = s.replace(var, "%")
    return s

###################################################################################################
##  Main

def parseOptions():
    parser = optparse.OptionParser(usage)
    parser.set_defaults(locale="en", focus=None, build=False, merge=False, diff=False,
                        verbose=False, dryrun=False, appName="", prefix="")

    parser.add_option("-l", "--locale", dest="locale", type="str",
        help = "The name of your source locale.  The default is 'en'.")

    parser.add_option("-f", "--focus", dest="focus", type="str",
        help = "The name of the locale to operate on, excluding all others.")

    parser.add_option("-v", "--verbose", dest="verbose", action="store_true",
        help = "Verbose reporting of activity.")

    parser.add_option("-r", "--dryrun", dest="dryrun", action="store_true",
        help = "Print the output of files instead of saving them.")

    parser.add_option("-b", "--build", dest="build", action="store_true",
        help = "Runs genstrings on each source file in each project.")

    parser.add_option("-d", "--diff", dest="diff", action="store_true",
        help="Generates a diff of each locale against the source locale. Each locale's diff will be stored in a file in the working directory named <locale>.xml.")

    parser.add_option("-m", "--merge", dest="merge", action="store_true",
        help="Merges strings from the <locale>.xml file in the working directory back into the Localized.strings files in each locale.")

    parser.add_option("-p", "--prefix", dest="prefix", type="str",
        help="The prefix to use on the xml tags.")

    parser.add_option("-a", "--appname", dest="appName", type="str",
        help="The name of the application to include in the xml metadata.")

    options, arguments = parser.parse_args()
    paths = ["."] if not len(arguments) else arguments
    if not options.merge:
        options.diff = True

    return options, paths

def main():
    options, projectPaths = parseOptions()
    projectPaths = [os.path.abspath(os.path.expanduser(path)) for path in projectPaths]

    global xmlFormat
    xmlFormat['prefix'] = options.prefix
    xmlFormat['appName'] = options.appName

    projects = list(openProjects(projectPaths, options.locale))

    if options.build:
        print "******* Generating strings *******"
        generateProjects(projects)
        print ""

    if options.merge:
        print "******* Merging *******"
        mergeProjects(projects, options.locale, options.focus, options.verbose, options.dryrun)
        print ""

    if options.diff:
        print "******* Diffing *******"
        diffProjects(projects, options.locale, options.focus, options.verbose, options.dryrun)
        print ""

if __name__ == "__main__":
    main()
