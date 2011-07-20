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

///////////////////////////////////////////////////////////////////////////////////////////////////
// CSS Style helpers

#define TTCSSSTYLESHEET ([[TTDefaultCSSStyleSheet globalCSSStyleSheet] styleSheet])

#define TTCSS_color(_SELECTOR, _STATE) \
                      ([TTCSSSTYLESHEET colorWithCssSelector:_SELECTOR forState:_STATE])

#define TTCSS_backgroundColor(_SELECTOR, _STATE) \
                      ([TTCSSSTYLESHEET backgroundColorWithCssSelector:_SELECTOR forState:_STATE])

#define TTCSS_font(_SELECTOR, _STATE) \
                      ([TTCSSSTYLESHEET fontWithCssSelector:_SELECTOR forState:_STATE])

#define TTCSS_shadowColor(_SELECTOR, _STATE) \
                      ([TTCSSSTYLESHEET textShadowColorWithCssSelector:_SELECTOR forState:_STATE])

#define TTCSS_shadowOffset(_SELECTOR, _STATE) \
                      ([TTCSSSTYLESHEET textShadowOffsetWithCssSelector:_SELECTOR forState:_STATE])

#define TTCSS_shadowRadius(_SELECTOR, _STATE) \
                      ([TTCSSSTYLESHEET textShadowRadiusWithCssSelector:_SELECTOR forState:_STATE])

// _VARNAME must be one of: color, backgroundColor, font, shadowColor, shadowOffset, shadowRadius
#define TTCSSSTATE(_SELECTOR, _VARNAME, _STATE) \
                        TTCSS_##_VARNAME(_SELECTOR, _STATE)

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Retrieve a Full CSS Rule (TTCSSRuleSet) for specified selector.
 */
#define TTCSSRule(selector) (TTCSSRuleSet*)[[TTDefaultCSSStyleSheet\
                              globalCSSStyleSheet] css:selector]

/**
 * Retrieve an value for a property of an Rule Set (TTCSSRuleSet) for specified selector.
 */
#define TTCSS(selector,property) [TTCSSRule(selector) property]

/**
 * Apply an CSS style to specified object.
 * The object must conform with the TTCSSApplyProtocol.
 */
#define TTApplyCSS(selector,object) [[TTDefaultCSSStyleSheet globalCSSStyleSheet]\
                              applyCssFromSelector:selector\
                              toObject:object]
