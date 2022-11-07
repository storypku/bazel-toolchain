#!/bin/bash
# Copyright 2021 The Bazel Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
