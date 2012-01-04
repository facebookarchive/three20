#!/usr/bin/env python
# encoding: utf-8
"""
docs.py

Created by Jeff Verkoeyen on 2010-10-18.
Copyright 2009-2010 Facebook

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

import logging
import re
import os
import sys
from optparse import OptionParser

def main():
	usage = '''%prog [options]

The Three20 Appledoc Generator Script.

EXAMPLES:

    Most common use case:
    > %prog --version 1.0.10-dev --output ../gh-pages
    
'''
	parser = OptionParser(usage = usage)
	
	parser.add_option("-o", "--output", dest="output",
	                  help="Output path")
	
	parser.add_option("-v", "--version", dest="version",
	                  help="Project version")

	parser.add_option("", "--verbose", dest="verbose",
	                  help="Log verbosity level")

	(options, args) = parser.parse_args()

	if options.verbose:
		log_level = logging.INFO
	else:
		log_level = logging.WARNING
        
	logging.basicConfig(level=log_level)

	did_anything = False

	if options.output is not None:
		did_anything = True
       		logging.info("Generating Three20 docset for version " + options.version)

		os.system(sys.path[0] + "/appledoc " + 
              "--project-name Three20 " +
              "--project-company \"Facebook\" " + 
              "--company-id=com.facebook " + 
              "--output " + options.output + " " + 
              "--project-version " + options.version + " " + 
              "--ignore .m --ignore Vendors --ignore UnitTests " + 
              "--keep-undocumented-objects " + 
              "--keep-undocumented-members " + 
              "--warn-undocumented-object " + 
              "--warn-undocumented-member " +
              "--warn-empty-description " + 
              "--warn-unknown-directive " + 
              "--warn-invalid-crossref " +
              "--warn-missing-arg " + 
              "--keep-intermediate-files " +
              "--docset-feed-name \"Three20 " + options.version + " Documentation\" " +
              "--docset-feed-url http://facebook.github.com/three20/api/%DOCSETATOMFILENAME " + 
              "--docset-package-url http://facebook.github.com/three20/api/%DOCSETPACKAGEFILENAME " + 
              "--publish-docset " + 
              "--verbose 3 src/")

		os.system("mkdir -p " + options.output + "/gh-pages/api")
		os.system("cp -r -f " + options.output + "/html/* " + options.output + "/gh-pages/api")
		os.system("cp -r -f " + options.output + "/publish/ " + options.output + "/gh-pages/api")

	if not did_anything:
		parser.print_help()


if __name__ == "__main__":
	sys.exit(main())
