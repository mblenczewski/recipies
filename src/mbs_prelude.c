#include <stdio.h>

#include "mbs_prelude.h"

void str_copy(const struct str_t *in, struct str_t *out) {
	assert(in);
	assert(out);

	out->len = in->len;
	out->str = in->str;
}

b32 try_str_clone(const struct str_t *in, struct str_t *out) {
	assert(in);
	assert(out);

	char *buf = (char*)malloc(in->len * sizeof(char));
	if (!buf) return false;

	strncpy(buf, in->str, in->len);

	out->len = in->len;
	out->str = buf;

	return true;
}

void wstr_copy(const struct wstr_t *in, struct wstr_t *out) {
	assert(in);
	assert(out);

	out->len = in->len;
	out->str = in->str;
}

b32 try_wstr_clone(const struct wstr_t *in, struct wstr_t *out) {
	assert(in);
	assert(out);

	wchar_t *buf = (wchar_t*)malloc(in->len * sizeof(wchar_t));
	if (!buf) return false;

	wcsncpy(buf, in->str, in->len);

	out->len = in->len;
	out->str = buf;

	return true;
}
