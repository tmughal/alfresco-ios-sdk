#!/bin/bash

# Copyright (C) 2005-2014 Alfresco Software Limited.
#
# This file is part of the Alfresco Mobile SDK.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

if [ -z "$ALFRESCO_SDK_SCRIPT" ]; then

   # -----------------------------------------------------------------------------
   # Script Parameters
   #
   BUILD_CONFIGURATION=Release
   LIBRARY_SUFFIX=""
   if [[ "$1" == "Debug" ]] ; then
      BUILD_CONFIGURATION=Debug
      LIBRARY_SUFFIX="-debug"
   fi


   # ---------------------------------------------------------------------------
   # Build environment variables
   #

   # The directory containing this script
   # We need to go there and use pwd so these are all absolute paths
   pushd $(dirname $BASH_SOURCE[0]) >/dev/null
   ALFRESCO_SDK_SCRIPT=$(pwd)
   popd >/dev/null

   # The root directory where the Alfresco SDK for iOS is cloned
   ALFRESCO_SDK_ROOT="$(dirname "$ALFRESCO_SDK_SCRIPT")"
   cd "$ALFRESCO_SDK_ROOT"

   # Path to source files for Alfresco SDK
   ALFRESCO_SDK_SRC=$ALFRESCO_SDK_ROOT/AlfrescoSDK

   # The directory where the target is built
   ALFRESCO_SDK_BUILD=$ALFRESCO_SDK_ROOT/build

   # The name of the Alfresco SDK
   ALFRESCO_SDK_PRODUCT_NAME=AlfrescoSDK

   # The name of the Alfresco SDK for iOS
   ALFRESCO_IOS_SDK_PRODUCT_NAME=AlfrescoSDK-iOS

   # The name of the Alfresco SDK for OS X
   ALFRESCO_OSX_SDK_PRODUCT_NAME=AlfrescoSDK-OSX

   # Extracts the Alfresco SDK Version from the project's xcconfig file.
   ALFRESCO_SDK_VERSION=`sed -ne '/^ALFRESCO_SDK_VERSION=/s/.*=\([\^]*\)/\1/p' "$ALFRESCO_SDK_SRC/AlfrescoSDK.xcconfig"`
   echo Alfresco SDK Version detected: $ALFRESCO_SDK_VERSION

   # The name of the Alfresco SDK for iOS static library
   ALFRESCO_IOS_SDK_LIBRARY_NAME=lib"$ALFRESCO_IOS_SDK_PRODUCT_NAME"v"$ALFRESCO_SDK_VERSION""$LIBRARY_SUFFIX".a

   # The name of the Alfresco SDK for OS X library
   ALFRESCO_OSX_SDK_LIBRARY_NAME=lib"$ALFRESCO_OSX_SDK_PRODUCT_NAME"v"$ALFRESCO_SDK_VERSION""$LIBRARY_SUFFIX".a

   # The directory containing the public header files
   ALFRESCO_IOS_SDK_HEADER_PATH=$ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-iphoneos

   # The directory containing the universal static library for iOS
   ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY_PATH=$ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-universal

   # The directory containing the universal static library for OS X
   ALFRESCO_OSX_SDK_UNIVERSAL_LIBRARY_PATH=$ALFRESCO_SDK_BUILD/$BUILD_CONFIGURATION-macosx

   # The path to the universal static library for iOS
   ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY=$ALFRESCO_IOS_SDK_UNIVERSAL_LIBRARY_PATH/$ALFRESCO_IOS_SDK_LIBRARY_NAME

   # The path to the universal static library for OSX
   ALFRESCO_OSX_SDK_UNIVERSAL_LIBRARY=$ALFRESCO_OSX_SDK_UNIVERSAL_LIBRARY_PATH/$ALFRESCO_OSX_SDK_LIBRARY_NAME

   # The name of the Alfresco SDK for iOS framework
   ALFRESCO_IOS_SDK_FRAMEWORK_NAME=$ALFRESCO_IOS_SDK_PRODUCT_NAME.framework

   # The name of the Alfresco SDK for OS X framework
   ALFRESCO_OSX_SDK_FRAMEWORK_NAME=$ALFRESCO_OSX_SDK_PRODUCT_NAME.framework

   # The path to the built Alfresco SDK for iOS .framework
   ALFRESCO_IOS_SDK_FRAMEWORK=$ALFRESCO_SDK_BUILD/$ALFRESCO_IOS_SDK_FRAMEWORK_NAME

   # The path to the built Alfresco SDK for OS X .framework
   ALFRESCO_OSX_SDK_FRAMEWORK=$ALFRESCO_SDK_BUILD/$ALFRESCO_OSX_SDK_FRAMEWORK_NAME

   # The name of the docset
   ALFRESCO_SDK_DOCSET_NAME=com.alfresco.AlfrescoSDK.docset

   # The directory where the docset is built
   ALFRESCO_SDK_DOCSET_BUILD=$ALFRESCO_SDK_BUILD/Help

   # The path to the framework docs and zip file
   ALFRESCO_SDK_DOCSET=$ALFRESCO_SDK_DOCSET_BUILD/$ALFRESCO_SDK_DOCSET_NAME

   # Xcode build tools
   test -n "$XCODEBUILD"   || XCODEBUILD=$(which xcodebuild)
   test -n "$LIPO"         || LIPO=$(which lipo)
   test -n "$APPLEDOC"     || APPLEDOC=$(which appledoc)


   # ---------------------------------------------------------------------------
   # Build environment functions
   #

   # Echoes a progress message to stderr
   function progress_message() {
      echo "$@" >&2
   }

   # Call this when there is an error. This does not return.
   function die() {
      echo ""
      echo "FATAL: $*" >&2
      exit 1
   }

fi
