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
import shutil
import errno
import git

# Three20 Python Objects
import Paths

from optparse import OptionParser

def generate_appledoc(version):
	logging.info("Generating appledoc")
		
	os.system("appledoc " + 
              "--project-name Three20 " +
              "--project-company \"Facebook\" " + 
              "--company-id=com.facebook " + 
              "--output Docs/ " + 
              "--project-version " + version + " " + 
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
              "--docset-feed-name \"Three20 " + version + " Documentation\" " +
              "--docset-feed-url http://facebook.github.com/three20/api/%DOCSETATOMFILENAME " + 
              "--docset-package-url http://facebook.github.com/three20/api/%DOCSETPACKAGEFILENAME " + 
              "--publish-docset " + 
              "--verbose 5 src/")

def publish_ghpages(version):
		
	logging.info("Cloning and checking out gh-pages")
	os.system("git clone git@github.com:facebook/three20.git Docs/gh-pages")
	os.system("cd Docs/gh-pages && git pull")
	os.system("cd Docs/gh-pages && git checkout gh-pages")
			
	logging.info("Copying docset into gh-pages folder")
		
	os.system("cp -r -f Docs/html/* Docs/gh-pages/api")
	os.system("cp -r -f Docs/publish/ Docs/gh-pages/api")
			
	logging.info("Committing new docs")
	os.system("cd Docs/gh-pages && git add -A .")
	os.system("cd Docs/gh-pages && git commit -am  \"Three20 " + version + " Documentation\"")
	os.system("cd Docs/gh-pages && git push origin gh-pages")
			

def main():
	usage = '''%prog [options]


The Three20 Appledoc Generator Script.
Use this script to generate appledoc
--generate will generate the docs
--publish will publish the new docs into the three20's gh-pages branch

EXAMPLES:

    Most common use case:
    > %prog --version 1.0.10-dev --generate
    
'''
	parser = OptionParser(usage = usage)
	
	parser.add_option("-o", "--generate", dest="generate",
	                  help="Generate appledoc",
	                  action="store_true")

	parser.add_option("-p", "--publish", dest="publish",
	                  help="publish gh-pages",
	                  action="store_true")
	
	parser.add_option("-v", "--version", dest="version",
	                  help="Project version")

	parser.add_option("", "--verbose", dest="verbose",
	                  help="Display verbose output",
	                  action="store_true")
  
	(options, args) = parser.parse_args()

	if options.verbose:
		log_level = logging.INFO
	else:
		log_level = logging.WARNING
        
	logging.basicConfig(level=log_level)

	did_anything = False

	if options.generate:
		did_anything = True

		generate_appledoc(options.version)

	if options.publish:
		did_anything = True
		publish_ghpages(options.version)

	if not did_anything:
		parser.print_help()


if __name__ == "__main__":
	sys.exit(main())
