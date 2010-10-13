#
# Copyright 2009-2010 Facebook
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Installs the project and source file templates. Overwrites any existing files.

mkdir -p ~/Library/Application\ Support/Developer/Shared/Xcode/Project\ Templates/Three20\ Application
cp -r projects3.2.4/ ~/Library/Application\ Support/Developer/Shared/Xcode/Project\ Templates/Three20\ Application

mkdir -p ~/Library/Application\ Support/Developer/Shared/Xcode/File\ Templates
cp -r source/ ~/Library/Application\ Support/Developer/Shared/Xcode/File\ Templates

