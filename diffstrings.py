#!/usr/bin/env python

usage = """usage: %prog [options] path1 path2 ...

diffstrings compares your primary locale with all your other locales to help you determine which new strings need to be translated.  It can also merge translated strings back into the project.

The path arguments supplied to this script should be the path containing your source files.  The file system will be searched to find the .lproj directories containing the Localizable.strings files that the script will read and write.
"""

import os.path, codecs, optparse, re, datetime
from xml.sax.saxutils import escape
 
###################################################################################################

global xmlFormat
xmlFormat = {}

reLprojFileName = re.compile(r'(.+?)\.lproj')
reComment = re.compile(r'/\*(.*?)\*/')
reString = re.compile(r'\s*"((\\.|.)+?)"\s*=\s*"(.+?)";')
reTranslatedString = re.compile(r'\w{2}:\s*"(.*?)"')
reVariable = re.compile(r'%(@|d|f|lld|\d+\.?f|\d+\.\d+f|\d+d)')

defaultComment = "No comment provided by engineer."
stringsFileName = "Localizable.strings"

###################################################################################################
# Diffing

def diffProjectLocales(projectDirPaths, primaryLocaleName):
    primaryLocale, otherLocales = openAllLocales(projectDirPaths, primaryLocaleName)
    print "    * %s has %d total strings." % (primaryLocaleName, len(primaryLocale))

    for localeName, locale in otherLocales.iteritems():
        writeLocaleDiff(localeName, locale, primaryLocaleName, primaryLocale)

def compareLocales(locale1, locale2, compareStrings=False):
    newStrings = {}
    existingStrings = {}
    
    for originalString, (translatedString, comment) in locale1.iteritems():
        if originalString in locale2:
            translatedString, comment2 = locale2[originalString]
            if compareStrings and translatedString == originalString:
                newStrings[originalString] = ("", comment)
            else:
                existingStrings[originalString] = (translatedString, comment)
        else:
            newStrings[originalString] = ("", comment)

    return newStrings, existingStrings

def writeLocaleDiff(localeName, locale, projectLocaleName, projectLocale):
    """ Writes a <locale>.xml file for a locale."""

    global xmlFormat
    prefix = xmlFormat['prefix']
    
    newStrings, existingStrings = compareLocales(projectLocale, locale, True)
    deletedStrings, ignore = compareLocales(locale, projectLocale)
   
    if not len(newStrings):
        if len(deletedStrings):
            print "    * %s is fully translated, but has %s obsolute strings."\
                  % (localeName, len(deletedStrings))
        else:
            print "    * %s is fully translated." % localeName
    else:                                                                      
        fileName = "%s.xml" % localeName
        stringsPath = os.path.abspath(os.path.join(".", fileName))
        f = codecs.open(stringsPath, 'w', 'utf-16')
        
        f.write('<?xml version="1.0" encoding="utf-16"?>\n')
        f.write('<%sexternal>\n' % prefix)

        f.write('  <meta>\n')
        if xmlFormat['appName']:
            f.write('    <appName>%s</appName>\n' % xmlFormat['appName'])
        f.write('    <date>%s</date>\n' % datetime.datetime.now().strftime('%Y%m%d'))
        f.write('    <locale>%s</locale>\n' % localeName)
        f.write('  </meta>\n')
        
        allStrings = dict(newStrings)
        allStrings.update(existingStrings)
        sortedKeys = allStrings.keys()
        sortedKeys.sort(key=unicode.lower)
        
        for originalString in sortedKeys:
            translatedString, comment = allStrings[originalString]
            
            f.write("  <entry>\n")
            f.write("    <%ssource>%s</%ssource>\n" % (prefix, escape(originalString), prefix))
            if translatedString == originalString or not translatedString:
                x = originalString
                originalString = enumerateStringVariables(originalString)
                f.write("    <%starget>%s</%starget>\n"
                        % (prefix, escape(originalString), prefix))
            else:
                f.write("    <%sxtarget>%s</%sxtarget>\n"
                        % (prefix, escape(translatedString), prefix))
            if comment:
                f.write("    <%sdescription>%s</%sdescription>\n"
                        % (prefix, escape(comment), prefix))
            f.write("  </entry>\n")

        f.write('</%sexternal>\n' % prefix)
        f.close()

        if len(deletedStrings):
            print "    * Writing %s.xml: %s new strings, %s already translated, and %s obsolete."\
                  % (localeName, len(newStrings), len(existingStrings), len(deletedStrings))
        else:
            print "    * Writing %s.xml: %s new strings, with %s already translated."\
                  % (localeName, len(newStrings), len(existingStrings))
            
###################################################################################################
##  Merging

def mergeProjectLocales(projectDirPaths, primaryLocaleName):  
    primaryLocale, otherLocales = openAllLocales(projectDirPaths, primaryLocaleName)
    translations = openAllTranslations(otherLocales.keys())
    mergeTranslations(primaryLocale, otherLocales, translations)

    for projectDirPath in projectDirPaths:
        writeProjectTranslations(projectDirPath, primaryLocaleName, translations)

def mergeTranslations(primaryLocale, otherLocales, translations):
    for localeName, locale in otherLocales.iteritems():
        if localeName not in translations:
            print "WARNING: No translation exist for %s" % localeName
        else:
            print "    * Merging %s.xml" % localeName
            
            translation = translations[localeName]
            for originalString in primaryLocale:
                if originalString in translation:
                    translatedString = translation[originalString]
                    if originalString in locale:
                        (localeTranslatedString, comment) = locale[originalString]
                    else:
                        (localeTranslatedString, comment) = ("", None)
                    if localeTranslatedString != translatedString:
                        locale[originalString] = (translatedString, comment)

def writeProjectTranslations(projectDirPath, primaryLocaleName, translations):
    """Writes translations back to the strings file for each locale in a project."""
    
    primaryStringsPath = pathForLocaleStrings(primaryLocaleName, projectDirPath)
    projectPrimaryLocale = parseLocaleFile(primaryStringsPath)
    stringsDirPath = os.path.abspath(os.path.join(primaryStringsPath, "..", ".."))
    
    for localeName,translation  in translations.iteritems():
        lines = []
        for originalString in projectPrimaryLocale:
            translatedString = translation[originalString]
            (ignore, comment) = projectPrimaryLocale[originalString]

            if comment:
                lines.append("/* %s */" % comment)
            if not translatedString:
                line = '"%s" = "%s";\n' % (originalString, originalString)
            else:
                line = '"%s" = "%s";\n' % (originalString, translatedString)
            lines.append(line)
        
        localeDirName = "%s.lproj" % localeName
        stringsPath = os.path.join(stringsDirPath, localeDirName, stringsFileName)
        print "    * Writing %s" % stringsPath
        
        f = codecs.open(stringsPath, 'w', 'utf-16')
        f.write("\n".join(lines))
        f.close()
    
###################################################################################################
##  Opening Locales
               
def openLocale(localeName, projectDirPath="."):
    localeStringsPath = pathForLocaleStrings(localeName, projectDirPath)
    return parseLocaleFile(localeStringsPath)

def openAllLocales(projectDirPaths, primaryLocaleName):
    primaryLocale = None
    allLocales = {}
    
    for projectDirPath in projectDirPaths:
        localeDirPath = findLocaleDirPath(primaryLocaleName, projectDirPath)
        if not localeDirPath:
            print "WARNING: %s does not have a '%s' locale."\
                  % (projectDirPath, primaryLocaleName)
            continue

        for localeName, locale in iterLocales(os.path.dirname(localeDirPath)):
            if not localeName in allLocales:
                allLocales[localeName] = {}
            allLocales[localeName].update(locale)

    if not primaryLocaleName in allLocales:
        primaryLocale = {}
    else:
        primaryLocale = allLocales[primaryLocaleName] 
        del allLocales[primaryLocaleName]
    
    return primaryLocale, allLocales

def iterLocales(projectDirPath):
    for dirName in os.listdir(projectDirPath):
        m = reLprojFileName.match(dirName)
        if m:
            localeName = m.groups()[0]
            yield localeName, openLocale(localeName, projectDirPath)

def parseLocaleFile(stringsPath):
    strings = {}
    
    lastComment = None
    for line in openWithProperEncoding(stringsPath):
        m = reString.search(line)
        if m:
            originalString = m.groups()[0]
            translatedString = m.groups()[2]
            strings[originalString] = (translatedString, lastComment)
            lastComment = None
        else:
            m = reComment.search(line)
            if m:
               comment = m.groups()[0].strip()
               if comment != defaultComment:
                   lastComment = comment
               
               
    return strings
    ###################################################################################################
## Opening translations

def openTranslation(localeName):
    translationFileName = "%s.xml" % localeName
    translationFilePath = os.path.abspath(os.path.join(".", translationFileName))
    return parseTranslationsFile(translationFilePath)

def openAllTranslations(localeNames):
    translations = {}

    for localeName in localeNames:
        translations[localeName] = openTranslation(localeName)
    
    return translations

def parseTranslationsFile(stringsPath):
    strings = {}
    
    originalString = None
    for line in openWithProperEncoding(stringsPath):
        m = reTranslatedString.search(line)
        if m:
            string = m.groups()[0]
            if not originalString:
                originalString = string
            else:
                strings[originalString] = string
                originalString = None

    return strings

def enumerateStringVariables(s):
    i = 1
    for var in reVariable.findall(s):
        s = s.replace("%%%s" % var, "%%%d$%s" % (i, var))
        i += 1
    return s
    
###################################################################################################
##  File System Helpers

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

def pathForLocaleStrings(localeName, projectDirPath, fileName=stringsFileName):
    localeDirPath = findLocaleDirPath(localeName, projectDirPath)
    return os.path.join(localeDirPath, fileName)

def findLocaleDirPath(localeName, projectDirPath):
    localeDirName = "%s.lproj" % localeName
    localeDirPath = os.path.join(projectDirPath, localeDirName)
    if os.path.isdir(localeDirPath):
        return localeDirPath

    for name in os.listdir(projectDirPath):
        path = os.path.join(projectDirPath, name)
        if os.path.isdir(path):
            localeDirPath = findLocaleDirPath(localeName, path)
            if localeDirPath:
                return localeDirPath
            
    return None

###################################################################################################
##  genstrings

def runGenstrings(projectDirPaths, primaryLocaleName):
    cwd = os.getcwd()

    for projectDirPath in projectDirPaths:
        os.chdir(projectDirPath)
        localeDirPath = findLocaleDirPath(primaryLocaleName, projectDirPath)
        command = "genstrings *.m -o %s" % localeDirPath

        print "   ", command
        os.system(command)
    
    os.chdir(cwd)

###################################################################################################
##  Main

def parseOptions():
    parser = optparse.OptionParser(usage)
    parser.set_defaults(locale="en", genstrings=False, merge=False, diff=False, appName="",
                        prefix="")

    parser.add_option("-l", "--locale", dest="locale", type="str",
        help = "The name of your primary locale.  The default is 'en'.")

    parser.add_option("-g", "--genstrings", dest="genstrings", action="store_true",
        help = "Runs 'genstrings *.m' on each project before diffing or merging. WARNING: This will overwrite the Localized.strings file in your primary locale.")

    parser.add_option("-d", "--diff", dest="diff", action="store_true",
        help="Generates a diff of each locale against the primary locale. Each locale's diff will be stored in a file in the working directory named <locale>.xml.")

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
    
    if options.genstrings:
        print "*** Generating strings"
        runGenstrings(projectPaths, options.locale)
        print ""
        
    if options.merge:
        print "*** Merging"
        mergeProjectLocales(projectPaths, options.locale)
        print ""
    
    if options.diff:
        print "*** Diffing"
        diffProjectLocales(projectPaths, options.locale)
        print ""

if __name__ == "__main__":
    main()
