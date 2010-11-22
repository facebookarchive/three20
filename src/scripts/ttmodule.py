#!/usr/bin/env python
# encoding: utf-8
"""
ttmodule.py

Most of the documentation is found in Pbxproj.py.

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
import sys
from optparse import OptionParser

# Three20 Python Objects
import Paths
from Pbxproj import Pbxproj

def print_dependencies(name):
	pbxproj = Pbxproj.get_pbxproj_by_name(name)
	print str(pbxproj)+"..."
	if pbxproj.dependencies():
		[sys.stdout.write("\t"+x+"\n") for x in pbxproj.dependencies()]

def get_dependency_modules(dependency_names):
	dependency_modules = {}
	if not dependency_names:
		return dependency_modules

	for name in dependency_names:
		project = Pbxproj.get_pbxproj_by_name(name)
		dependency_modules[project.uniqueid()] = project

		dependencies = project.dependencies()
		if dependencies is None:
			print "Failed to get dependencies; it's possible that the given target doesn't exist."
			sys.exit(0)

		submodules = get_dependency_modules(dependencies)
		for guid, submodule in submodules.items():
			dependency_modules[guid] = submodule

	return dependency_modules

def add_modules_to_project(module_names, project, configs):
	logging.info(project)
	logging.info("Checking dependencies...")
	if project.dependencies() is None:
		logging.error("Failed to get dependencies. Check the error logs for more details.")
		sys.exit(0)
	if len(project.dependencies()) == 0:
		logging.info("\tNo dependencies.")
	else:
		logging.info("Existing dependencies:")
		[logging.info("\t"+x) for x in project.dependencies()]

	modules = get_dependency_modules(module_names)

	logging.info("Requested dependency list:")
	[logging.info("\t"+str(x)) for k,x in modules.items()]
	
	logging.info("Adding dependencies...")
	failed = []
	for k,v in modules.items():
		if v.name == 'Three20UI':
			project.add_framework('QuartzCore.framework')
		if v.name == 'Three20Core':
			project.add_bundle()

		if not project.add_dependency(v):
			failed.append(k)

	if configs:
		for config in configs:
			project.add_header_search_path(config)

			for k,v in modules.items():
				project.add_build_setting(config, 'OTHER_LDFLAGS', '"-force_load '+project.get_rel_path_to_products_dir()+'/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/'+v._product_name+'"')

	if len(failed) > 0:
		logging.error("Some dependencies failed to be added:")
		[logging.error("\t"+str(x)+"\n") for x in failed]

def main():
	usage = '''%prog [options] module(s)

The Three20 Module Script.
Easily add Three20 modules to your projects.

Modules may take the form <module-name>(:<module-target>)

module-target defaults to module-name if it is not specified
module-name may be a path to a .pbxproj file.

Examples:
  Print all dependencies for the Three20UI module
  > %prog -d Three20UI

  Print all dependencies for the Three20 module's Three20-Xcode3.2.5 target.
  > %prog -d Three20:Three20-Xcode3.2.5

  Add the Three20 project settings to the Debug and Release configurations.
  This includes adding the header search path and linker flags.
  > %prog -p path/to/myApp.xcodeproj -c Debug -c Release

  Add the extThree20XML module and all of its dependencies to the myApp project.
  > %prog -p path/to/myApp.xcodeproj extThree20XML

  Add a specific target of a module to a project.
  > %prog -p path/to/myApp.xcodeproj extThree20JSON:extThree20JSON+SBJSON'''
	parser = OptionParser(usage = usage)
	parser.add_option("-d", "--dependencies", dest="print_dependencies",
	                  help="Print dependencies for the given modules",
	                  action="store_true")
	parser.add_option("-v", "--verbose", dest="verbose",
	                  help="Display verbose output",
	                  action="store_true")
	parser.add_option("-p", "--project", dest="projects",
	                  help="Add the given modules to this project", action="append")
	parser.add_option("-c", "--config", dest="configs",
	                  help="The configurations to add Three20 settings to (example: Debug)", action="append")

	(options, args) = parser.parse_args()

	if options.verbose:
		log_level = logging.INFO
	else:
		log_level = logging.WARNING

	logging.basicConfig(level=log_level)

	did_anything = False

	if options.print_dependencies:
		[print_dependencies(x) for x in args]
		did_anything = True

	if options.projects is not None:
		did_anything = True
		for name in options.projects:
			project = Pbxproj.get_pbxproj_by_name(name)
			add_modules_to_project(args, project, options.configs)

	if not did_anything:
		parser.print_help()


if __name__ == "__main__":
	sys.exit(main())
