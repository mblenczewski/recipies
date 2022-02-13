#ifndef MBS_PRELUDE_H
#define MBS_PRELUDE_H

/* Standard includes */
#include <assert.h>
#include <errno.h>
#include <stdalign.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>

/* Wide character support */
#include <locale.h>
#include <wchar.h>
#include <wctype.h>

/* Macros */
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define ARRLEN(arr) (sizeof(arr) / sizeof(arr[0]))

/* Integral types */
typedef uint32_t b32;

typedef uint8_t  u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

typedef int8_t   s8;
typedef int16_t  s16;
typedef int32_t  s32;
typedef int64_t  s64;

typedef float    f32;
typedef double   f64;

/* String types */
struct str_t {
	char *str; /* null terminated */
	size_t len;
};

/* performs a shallow copy of the given string in "in" to the string in "out"
 * ---
 *  in: a pointer to the original string
 *  out: a pointer to the shallow copy of the original string
 */
extern void str_copy(const struct str_t *in, struct str_t *out);

/* attempts to deep copy the given string in "in" to the string in "out"
 * ---
 *  in: a pointer to the original string
 *  out: a pointer to the deep copy of the original string
 */
extern b32 try_str_clone(const struct str_t *in, struct str_t *out);

struct wstr_t {
	wchar_t *str; /* null terminated */
	size_t len;
};

/* performs a shallow copy of the given string in "in" to the string in "out"
 * ---
 *  in: a pointer to the original string
 *  out: a pointer to the shallow copy of the original string
 */
extern void wstr_copy(const struct wstr_t *in, struct wstr_t *out);

/* attempts to deep copy the given string in "in" to the string in "out"
 * ---
 *  in: a pointer to the original string
 *  out: a pointer to the deep copy of the original string
 */
extern b32 try_wstr_clone(const struct wstr_t *in, struct wstr_t *out);

#ifndef NDEBUG
/* prints out the given format string to standard error
 * ---
 *  fmt: the format string to print
 *  ...: the variadic arguments to fprintf
 */
#define dbglog(...) fprintf(stderr, __VA_ARGS__)
#else
/* if NDEBUG is defined, this function will do nothing
 */
#define dbglog(...)
#endif

#endif /* MBS_PRELUDE_H */
