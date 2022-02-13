#!/bin/sh

TARGET="recipies"

# project root
PWD="$(dirname $0)"

# project directory structure
SRC="$PWD/src"
INC="$PWD/include"
LIB="$PWD/lib"
TEST="$PWD/test"
OBJ="$PWD/obj"
OUT="$PWD/out"

# toolchain
CCX=g++
LD=g++
AR=ar

# toolchain specific flags
CCX_BIN_FLAGS=""
CCX_SO_FLAGS="-shared"

# global toolchain flags
COMMON_CCXFLAGS="$CFLAGS $CCXFLAGS -Wall -Wextra -Wpedantic"
COMMON_CPPFLAGS="$CPPFLAGS -I$INC"
COMMON_LDFLAGS="$LDFLAGS -L$LIB -L$OUT"

# Returns the correct set of flags based on the compilation regime
# NOTE: requires that the given regime has compilation flag variables in the
#       form ${REGIME}_FLAG_ROOT (where FLAG_ROOT = CCXFLAGS, LDFLAGS, etc)
# Requires:
#   $REGIME
# Usage:
#   FLAGS="<common-flags> $(REGIME <flag-root>)"
REGIME() {
	eval "echo \"\$${REGIME}_$1\""
}

DBG_CCXFLAGS="-Og -ggdb"
DBG_CPPFLAGS=""
DBG_LDFLAGS=""

REL_CCXFLAGS="-O3 -flto"
REL_CPPFLAGS="-DNDEBUG"
REL_LDFLAGS="-flto"

CCXFLAGS="$COMMON_CCXFLAGS $(REGIME "CCXFLAGS")"
CPPFLAGS="$COMMON_CPPFLAGS $(REGIME "CPPFLAGS")"
LDFLAGS="$COMMON_LDFLAGS $(REGIME "LDFLAGS")"

[ $VERBOSE ] && echo "global CCXFLAGS: $CCXFLAGS"
[ $VERBOSE ] && echo "global CPPFLAGS: $CPPFLAGS"
[ $VERBOSE ] && echo "global LDFLAGS: $LDFLAGS"

# Executes the given command, echoing it out if the VERBOSE variable is defined
# Overwrites:
#   __TMP_ERRNO
# Usage:
#   EXEC <command...>
EXEC() {
	__TMP_ERRNO=$?; [ $VERBOSE ] && echo "$@"; ( exit $__TMP_ERRNO ) && $@
}

# Echoes the LDFLAGS for the given library
# Usage:
#   LIB <lib-name> <pkg-config-opts...>
LIB() {
	echo "$(pkg-config --libs $@)"
}

# Echoes the CPPFLAGS for the given library
# Usage:
#   INC <lib-name> <pkg-config-opts...>
INC() {
	echo "$(pkg-config --cflags $@)"
}

# Builds object files from the given sources
# Requires:
#   CCX CCXFLAGS CPPFLAGS OUT
# Overwrites:
#   __OBJ_CCXFLAGS __OBJ_CPPFLAGS
# Usage:
#   OBJECTS "<obj-cxxflags>" "<obj-cppflags>" <sources...>
OBJECTS() {
	__OBJ_CCXFLAGS="$1"
	__OBJ_CPPFLAGS="$2"
	shift 2
	for src in $@; do
		EXEC mkdir -p "$(dirname $OBJ/$src)"
		EXEC $CCX -o "$OBJ/$src.o" -c "$src" $CCXFLAGS $__OBJ_CCXFLAGS $CPPFLAGS $__OBJ_CPPFLAGS
		[ $? -eq 0 ] && echo "Compiled $src -> $OBJ/$src.o"
	done
}

# Builds an executable from the given sources or objects
# Requires:
#   CCX CCX_BIN_FLAGS CCXFLAGS CPPFLAGS LDFLAGS OUT
# Overwrites:
#   __TGT_NAME __TGT_CCXFLAGS __TGT_CPPFLAGS __TGT_LDFLAGS
# Usage:
#   EXECUTABLE <tgt-name> "<tgt-cxxflags>" "<tgt-cppflags>" "<tgt-lddflags>" <sources...>
EXECUTABLE() {
	__TGT_NAME=$1
	__TGT_CCXFLAGS="$2"
	__TGT_CPPFLAGS="$3"
	__TGT_LDFLAGS="$4"
	shift 4
	EXEC $CCX $CCX_BIN_FLAGS -o "$OUT/$__TGT_NAME" $CCXFLAGS $__TGT_CCXFLAS $CPPFLAGS $__TGT_CPPFLAGS $LDFLAGS $__TGT_LDFLAGS $@
	[ $? -eq 0 ] && echo "Built executable: $OUT/$__TGT_NAME"
}

# Builds a shared library from the given sources or objects
# Requires:
#   CCX CCX_SO_FLAGS CCXFLAGS CPPFLAGS LDFLAGS OUT
# Overwrites:
#   __TGT_NAME __TGT_CCXFLAGS __TGT_CPPFLAGS __TGT_LDFLAGS
# Usage:
#   SHAREDLIB <tgt-name> "<tgt-cxxflags>" "<tgt-cppflags>" "<tgt-lddflags>" <sources...>
SHAREDLIB() {
	__TGT_NAME=lib$1.so
	__TGT_CCXFLAGS="$2"
	__TGT_CPPFLAGS="$3"
	__TGT_LDFLAGS="$4"
	shift 4
	EXEC $CCX $CCX_SO_FLAGS -o "$OUT/$__TGT_NAME" $CCXFLAGS $__TGT_CCXFLAS $CPPFLAGS $__TGT_CPPFLAGS $LDFLAGS $__TGT_LDFLAGS $@
	[ $? -eq 0 ] && echo "Built shared library: $OUT/$__TGT_NAME"
}

# Builds a static library from the given objects
# Requires:
#   AR OUT
# Overwrites:
#   __TGT_NAME
# Usage:
#   STATICLIB <tgt-name> <objects...>
STATICLIB() {
	__TGT_NAME=lib$1.a
	shift 1
	EXEC $AR rcs "$OUT/$__TGT_NAME" $@
	[ $? -eq 0 ] && echo "Built static library: $OUT/$__TGT_NAME"
}

# Runs the given tests
# Requires:
#   CCX CCXFLAGS CPPFLAGS LDFLAGS LIB OUT TEST
# Overwrites:
#   __TEST_CCXFLAGS __TEST_CPPFLAGS __TEST_LDFLAGS __TEST_TMP
# Usage:
#   TEST "<test-cxxflags>" "<test-cppflags>" "<test-lddflags>" <tests...>
TEST() {
	__TEST_CCXFLAGS="$1"
	__TEST_CPPFLAGS="$2"
	__TEST_LDFLAGS="$3"
	shift 3
	__TEST_TMP=0
	for test_src in $@; do
		EXEC mkdir -p "$(dirname $OUT/$test_src.x)"
		EXEC $CCX -o "$OUT/$test_src.x" "$test_src" -Wno-unused-value $CCXFLAGS $__TEST_CCXFLAGS -I$TEST $CPPFLAGS $__TEST_CPPFLAGS $LDFLAGS $__TEST_LDFLAGS && \
			LD_LIBRARY_PATH="$OUT:$LIB:$LD_LIBRARY_PATH" "$OUT/$test_src.x"
		[ $? -ne 0 ] && __TEST_TMP=1
	done
	echo "Ran tests: $([ $__TEST_TMP -eq 0 ] && echo PASS || echo FAIL)"
}
