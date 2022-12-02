#!/bin/bash
    # --symlink_prefix=/ \
/usr/bin/bazel \
     --bazelrc=/dev/null build \
    --incompatible_enable_cc_toolchain_resolution \
    --platforms=@com_grail_bazel_toolchain//platforms:linux-aarch64-cross \
    --extra_toolchains=@llvm_toolchain_with_sysroot//:cc-toolchain-aarch64-linux \
    --color=yes \
    //:stdlib_test \
    //examples:sha256_test \
    //third_party/libevent:hello
