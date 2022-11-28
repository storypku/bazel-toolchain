#!/bin/bash
set -euo pipefail

images=(
"ubuntu:20.04"
)

git_root=$(git rev-parse --show-toplevel)
readonly git_root

for image in "${images[@]}"; do
  docker pull "${image}"
  docker run --rm --entrypoint=/bin/bash --volume="${git_root}:/src:ro" "${image}" -c """
set -exuo pipefail

# Common setup
export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq -y install apt-utils curl pkg-config zip g++ zlib1g-dev unzip python >/dev/null
# The above command gives some verbose output that can not be silenced easily.
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=288778

# Run tests
cd /src
tests/scripts/run_tests.sh -t '@llvm_toolchain_with_sysroot//:cc-toolchain-x86_64-linux'
"""
done
