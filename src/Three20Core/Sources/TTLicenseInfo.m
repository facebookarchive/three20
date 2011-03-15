//
// Copyright 2009-2011 Facebook
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

#import "Three20Core/TTLicenseInfo.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTLicenseInfo


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString*)nameForLicense:(TTLicense)license {
  switch (license) {

    case TTLicenseApache2_0:
      return @"Apache 2.0";
      break;

    case TTLicenseBSDNew:
      return @"New BSD";
      break;

    default:
      return nil;
      break;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString*)urlPathForLicense:(TTLicense)license {
  switch (license) {

    case TTLicenseApache2_0:
      return @"http://www.apache.org/licenses/LICENSE-2.0.html";
      break;

    case TTLicenseBSDNew:
      return @"http://www.opensource.org/licenses/bsd-license.php";
      break;

    default:
      return nil;
      break;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString*)preambleForLicense: (TTLicense)license
          withCopyrightTimespan: (NSString*)copyrightTimespan
             withCopyrightOwner: (NSString*)copyrightOwner {
  switch (license) {

    case TTLicenseApache2_0:
      return [NSString stringWithFormat:
              @"Copyright %@ %@"
              @"\n"
              @"\nLicensed under the Apache License, Version 2.0 (the \"License\");"
              @" you may not use this file except in compliance with the License."
              @" You may obtain a copy of the License at"
              @"\n"
              @"\nhttp://www.apache.org/licenses/LICENSE-2.0"
              @"\n"
              @"\nUnless required by applicable law or agreed to in writing, software"
              @" distributed under the License is distributed on an \"AS IS\" BASIS,"
              @" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied."
              @" See the License for the specific language governing permissions and"
              @" limitations under the License.",
              copyrightTimespan,
              copyrightOwner];
      break;

    case TTLicenseBSDNew:
      return [NSString stringWithFormat:
              @"Copyright (c) %@, %@"
              @"\nAll rights reserved."
              @"\n"
              @"\nRedistribution and use in source and binary forms, with or without"
              @"modification, are permitted provided that the following conditions are met:"
              @"\n    * Redistributions of source code must retain the above copyright"
              @" notice, this list of conditions and the following disclaimer."
              @"\n    * Redistributions in binary form must reproduce the above copyright"
              @" notice, this list of conditions and the following disclaimer in the"
              @" documentation and/or other materials provided with the distribution."
              @"\n    * Neither the name of the <organization> nor the"
              @" names of its contributors may be used to endorse or promote products"
              @" derived from this software without specific prior written permission."
              @"\n"
              @"\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND"
              @" ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED"
              @" WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE"
              @" DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY"
              @" DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES"
              @" (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;"
              @" LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND"
              @" ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT"
              @" (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS",
              copyrightTimespan,
              copyrightOwner];
      break;

    default:
      return nil;
      break;
  }
}


@end
