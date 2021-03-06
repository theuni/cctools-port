AC_DEFUN([CHECK_LLVM],
[
    AC_ARG_ENABLE([lto],
    AS_HELP_STRING([--enable-lto],
                   [enable link time optimization support]),
    [], [enable_lto=yes])

    if test "x$enable_lto" = "xyes"; then
        AC_PATH_PROGS(LLVM_CONFIG,
            [llvm-config                                     \
             llvm-config-3.6 llvm-config-3.5 llvm-config-3.4 \
             llvm-config-3.3 llvm-config-3.2 llvm-config-3.1 \
             llvm-config36 llvm-config35 llvm-config34       \
             llvm-config33 llvm-config32 llvm-config31],
        no)

        if test "x$LLVM_CONFIG" != "xno"; then
            LLVM_INCLUDE_DIR="`${LLVM_CONFIG} --includedir`"
            LLVM_LIB_DIR="`${LLVM_CONFIG} --libdir`"

            ORIGLDFLAGS=$LDFLAGS
            LDFLAGS="$LDFLAGS -L${LLVM_LIB_DIR}"

            AC_CHECK_LIB([LTO],[lto_get_version],
             [ LTO_LIB="-L${LLVM_LIB_DIR} -lLTO"
               if test "x$rpathlink" = "xyes"; then
                   LTO_RPATH="-Wl,-rpath,$LLVM_LIB_DIR,--enable-new-dtags"
                   LTO_LIB="$LTO_RPATH $LTO_LIB"
               fi
               LTO_DEF=-DLTO_SUPPORT
               # DO NOT include the LLVM include dir directly,
               # it may cause the build to fail.
               `ln -sf $LLVM_INCLUDE_DIR/llvm-c/lto.h include/llvm-c/lto.h 2>/dev/null 1>&2`
               AC_SUBST([LTO_DEF])
               AC_SUBST([LTO_RPATH])
               AC_SUBST([LTO_LIB]) ])

            LDFLAGS=$ORIGLDFLAGS
        else
            AC_MSG_WARN([llvm-config not found, disabling LTO support])
        fi
    fi

    AC_SUBST(LLVM_CONFIG)
    AC_SUBST(LLVM_INCLUDE_DIR)
    AC_SUBST(LLVM_LIB_DIR)
])
