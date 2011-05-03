#ifndef YAJL_VERSION_H_
#define YAJL_VERSION_H_

#include <extThree20JSON/yajl_common.h>

#define YAJL_MAJOR 1
#define YAJL_MINOR 0
#define YAJL_MICRO 11

#define YAJL_VERSION ((YAJL_MAJOR * 10000) + (YAJL_MINOR * 100) + YAJL_MICRO)

#ifdef __cplusplus
extern "C" {
#endif

extern int YAJL_API yajl_version(void);

#ifdef __cplusplus
}
#endif

#endif /* YAJL_VERSION_H_ */

