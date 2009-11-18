/**
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
// A priority-based, debug-only logging interface.
//
// How to use it
// -------------
//
// To output text to the console:
// TTDINFO(@"Logging text with args %@", stringArg);
// or
// TTDPRINT(@"Logging text with args %@", stringArg);
// etc...
//
// Each macro will only display its logging information if its level is below
// TTMAXLOGLEVEL. TTDPRINT is an exception to this in that it will always
// log the text, regardless of log level.  See "Default log level" for more info
// about log levels.
//
// Note: these logging macros will only log if the DEBUG macro is set.
//
// To assert something in debug mode:
// TTDASSERT(value == 4);
//
// Default log level
// -----------------
//
// The default log level for the Three20 project is WARNING. This means that
// only WARNING and ERROR logs will be displayed. Most of the logs in Three20
// are INFO logs, so by default they will not be displayed.
//
// Setting the log level
// ---------------------
//
// You need to set TTMAXLOGLEVEL in your project settings as a preprocessor macro.
// - To do so in Xcode, find the target you wish to configure in the
//   "Groups and Files" view. Right click it and click "Get Info".
// - Under the "Build" tab, look for the Preprocessor Macros setting.
// - Double-click the right-side column and click the "+" button.
// - Type any of the following to set your log level:
//   TTMAXLOGLEVEL=3
//   or
//   TTMAXLOGLEVEL=TTLOGLEVEL_INFO
//   etc...
//
// Available Macros
// ----------------
//
// TTDASSERT(statement) - Jumps into the debugger if statement evaluates to false
//                        Use Cmd-Y in Xcode to ensure gdb is attached.
//
// And the logging functions:
// TTDERROR(text, ...)
// TTDWARNING(text, ...)
// TTDINFO(text, ...)
// TTDPRINT(text, ...) - Generic logging function, similar to deprecated TTLOG
//
// Output format example:
// "/path/to/file(line_number): <message>"
//
//
// ^               ^
// | Informational |
// | - - - - - - - | <- The max log level. Only logs with a level
// |    Warning    |    below this line will be output.
// |               |
// |     Error     |
// |               |
// -----------------

#define TTLOGLEVEL_INFO     5
#define TTLOGLEVEL_WARNING  3
#define TTLOGLEVEL_ERROR    1

#ifndef TTMAXLOGLEVEL
  #define TTMAXLOGLEVEL TTLOGLEVEL_WARNING
#endif

// The general purpose logger. This ignores logging levels.
#ifdef DEBUG
  #define TTDPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __FILE__, __LINE__, ##__VA_ARGS__)
#else
  #define TTDPRINT(xx, ...)  ((void)0)
#endif

// Debug-only assertions.
#ifdef DEBUG
#if TARGET_IPHONE_SIMULATOR
  bool inDebugger(void);
  // We leave the __asm__ in this macro so that when a break occurs, we don't have to step out of
  // a "breakInDebugger" function.
  #define TTDASSERT(xx) { if(!(xx)) { TTDPRINT(@"TTDASSERT failed: %s", #xx); \
                                      if(inDebugger()) { __asm__("int $3\n" : : ); }; } }
#else
  #define TTDASSERT(xx) { if(!(xx)) { TTDPRINT(@"TTDASSERT failed: %s", #xx); } }
#endif
#else
  #define TTDASSERT(xx) ((void)0)
#endif

// Log-level based logging macros.
#if TTLOGLEVEL_ERROR <= TTMAXLOGLEVEL
  #define TTDERROR(xx, ...)  TTDPRINT(xx, ##__VA_ARGS__)
#else
  #define TTDERROR(xx, ...)  ((void)0)
#endif

#if TTLOGLEVEL_WARNING <= TTMAXLOGLEVEL
  #define TTDWARNING(xx, ...)  TTDPRINT(xx, ##__VA_ARGS__)
#else
  #define TTDWARNING(xx, ...)  ((void)0)
#endif

#if TTLOGLEVEL_INFO <= TTMAXLOGLEVEL
  #define TTDINFO(xx, ...)  TTDPRINT(xx, ##__VA_ARGS__)
#else
  #define TTDINFO(xx, ...)  ((void)0)
#endif
