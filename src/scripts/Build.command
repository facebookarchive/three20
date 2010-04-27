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

Usage()
{
    builtin echo "iPhone Build Script, version 1.0"
    builtin echo "Usage: Build.command <SDKVersion> <BuildConfiguration>"
    builtin echo "  <SDKVersion>         = A SDK Version"
    builtin echo "    Available          = [3.0, for example]"
    builtin echo "  <BuildConfiguration> = A Build Configuration"
    builtin echo "    Available          = [Debug | Internal | Release]"
    builtin echo ""
}

set -e

# process arguments
if [ $# -eq 1 ]; then
    SELECTED_SDK_VERSION="$1"
    Usage
    exit 1
elif [ $# -eq 2 ]; then
    SELECTED_SDK_VERSION="$1"
    SELECTED_BUILD_CONFIGURATION="$2"
else
    Usage
    exit 1
fi

echo $TARGET_SDK_VERSION
echo $TARGET_SDK_TYPE

# ================================================================================
# Debug | Profile | Release | Adhoc | Distribution
# ================================================================================

export BUILD_CONFIGURATION=$SELECTED_BUILD_CONFIGURATION
export BUILD_SDK_VERSION=$SELECTED_SDK_VERSION


# ================================================================================
# iphoneos[*] | iphonesimulator[*]
# ================================================================================

export BUILD_DEVICE_SDK_NAME=iphoneos
export BUILD_SIMULATOR_SDK_NAME=iphonesimulator

export BUILD_DEVICE_SDK=$BUILD_DEVICE_SDK_NAME$BUILD_SDK_VERSION
export BUILD_SIMULATOR_SDK=$BUILD_SIMULATOR_SDK_NAME$BUILD_SDK_VERSION


# ================================================================================
# Current working directory.
# ================================================================================

export BUILD_ROOT=$PWD/..
export LIBRARIES_ROOT=$PWD/..


# ================================================================================
# Location of Shared Build Directory
# ================================================================================

export BUILD_DIR=../../Build

# ================================================================================
# Location of Shared Build Libraries
# ================================================================================

export BUILD_SDK_DIR=$BUILD_DIR

echo "Xcode Version"
echo "________________________________________________________________________________"
xcodebuild -version
echo ""

echo "Available SDKs"
echo "________________________________________________________________________________"
xcodebuild -showsdks
echo ""

echo "SDK Versions"
echo "________________________________________________________________________________"
xcodebuild -version -sdk $BUILD_DEVICE_SDK
xcodebuild -version -sdk $BUILD_SIMULATOR_SDK
echo ""


echo "Build Configuration"
echo "________________________________________________________________________________"

echo "Build Configuration  =" $BUILD_CONFIGURATION
echo "Build SDK Version    =" $BUILD_SDK_VERSION
echo "Device SDK Name      =" $BUILD_DEVICE_SDK
echo "Simulator SDK Name   =" $BUILD_SIMULATOR_SDK
echo "Root Build Directory =" $BUILD_ROOT
echo "Deployment Directory =" $BUILD_SDK_DIR
echo ""


# ================================================================================
# Clean
# ================================================================================

echo "Cleaning Deployed Libraries"
echo "________________________________________________________________________________"

#rm -dRfv $BUILD_SDK_DIR


# ================================================================================
# Libraries
# ================================================================================ 

Process()
{
  echo "Building " $1
  echo "________________________________________________________________________________"
  cd $LIBRARIES_ROOT/$1

  xcodebuild -sdk $BUILD_DEVICE_SDK -target $2 -configuration $BUILD_CONFIGURATION -project $1.xcodeproj build
  xcodebuild -sdk $BUILD_SIMULATOR_SDK -target $2 -configuration $BUILD_CONFIGURATION -project $1.xcodeproj build
}

Process Three20UI Three20UI
