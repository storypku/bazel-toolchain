package(default_visibility = ["//visibility:public"])

load("@rules_cc//cc:defs.bzl", "cc_toolchain", "cc_toolchain_suite")
load("%{cc_toolchain_config_bzl}", "cc_toolchain_config")

# Following filegroup targets are used when not using absolute paths and shared
# between different toolchains.

filegroup(
    name = "empty",
    srcs = [],
)

# Tools symlinked through this repo. This target is for internal use in the toolchain only.
filegroup(
    name = "internal-use-symlinked-tools",
    srcs = [
%{symlinked_tools}
    ],
)

# Tools wrapped through this repo. This target is for internal use in the toolchain only.
filegroup(
    name = "internal-use-wrapped-tools",
    srcs = [
        "bin/cc_wrapper.sh",
    ],
)

cc_import(
    name = "omp",
    shared_library = "%{llvm_repo_package}:lib/libomp.so",
)

alias(
    name = "clang-format",
    actual = "%{llvm_repo_package}:bin/clang-format",
)

alias(
    name = "llvm-cov",
    actual = "%{llvm_repo_package}:bin/llvm-cov",
)

%{cc_toolchains}
