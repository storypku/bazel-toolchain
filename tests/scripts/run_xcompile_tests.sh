#!/bin/bash
set -euo pipefail

scripts_dir="$(dirname "${BASH_SOURCE[0]}")"
source "${scripts_dir}/bazel.sh"
"${bazel}" version

cd "${scripts_dir}"

binpath="$("${bazel}" info bazel-bin)/stdlib_test"

function check_with_image() {
  local image="$1"
  docker run --rm --mount "type=bind,source=${binpath},target=/stdlib_test" "${image}" /stdlib_test
}

echo ""
echo "Testing static linked user libraries and dynamic linked system libraries"
build_args=(
  --incompatible_enable_cc_toolchain_resolution
  --platforms=@com_grail_bazel_toolchain//platforms:linux-x86_64
  --extra_toolchains=@llvm_toolchain_with_sysroot//:cc-toolchain-x86_64-linux
  --symlink_prefix=/
  --color=yes
  --show_progress_rate_limit=30
)
set -x
"${bazel}" --bazelrc=/dev/null build "${build_args[@]}" //:stdlib_test
set +x
file "${binpath}" | tee /dev/stderr | grep -q ELF
check_with_image "frolvlad/alpine-glibc" # Need glibc image for system libraries.

echo ""
echo "Testing static linked user and system libraries"
build_args+=(
  --features=fully_static_link
)
"${bazel}" --bazelrc=/dev/null build "${build_args[@]}" //:stdlib_test
file "${binpath}" | tee /dev/stderr | grep -q ELF
check_with_image "alpine"
