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

# Protect the copied header files from being modified. This is done in an attempt to avoid
# accidentally editing the copied headers.

# Ignore whitespace characters in paths
IFS=$'\n'

# In Xcode 4 Archive builds, there is one extra folder placed between the configuration build
# dir and the public headers path titled "ArchiveIntermediates".
if [[ "$DEPLOYMENT_LOCATION" == "YES" && "$XCODE_VERSION_MAJOR" -ge "0400" ]]; then
  cd ${CONFIGURATION_BUILD_DIR}/..${PUBLIC_HEADERS_FOLDER_PATH}
else
  cd ${CONFIGURATION_BUILD_DIR}${PUBLIC_HEADERS_FOLDER_PATH}
fi

chmod a-w *.h 2>> /dev/null
chmod a-w private/*.h 2>> /dev/null

exit 0
