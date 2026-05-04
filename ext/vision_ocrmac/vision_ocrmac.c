#include <ruby.h>
#include <errno.h>
#include <sys/stat.h>
#include "VisionOcrmac-Swift.h"

static VALUE rb_vision_ocrmac_recognize(VALUE self, VALUE path) {
    const char *c_path = StringValueCStr(path);
    struct stat st;
    if (stat(c_path, &st) != 0) {
        rb_syserr_fail(errno, c_path);
    }
    char *result = vision_ocrmac_recognize(c_path);
    if (result == NULL) {
        return rb_utf8_str_new_cstr("");
    }
    VALUE rb_result = rb_utf8_str_new_cstr(result);
    vision_ocrmac_free(result);
    return rb_result;
}

void Init_vision_ocrmac(void) {
    VALUE module = rb_define_module("VisionOcrmac");
    rb_define_singleton_method(module, "recognize", rb_vision_ocrmac_recognize, 1);
}
