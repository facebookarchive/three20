//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/*
 * This file contains developer-specific preprocessor definitions.  It exists mostly to prevent
 * Joe from continually checking in debugging code.  If you modify this file, run this command
 * to tell git to ignore your changes:
 *
 *    git update-index --assume-unchanged src/Three20/developer.h
 */
 
#define JOE 1

#define TEST_URL @"tt://styledTextTableTest"
