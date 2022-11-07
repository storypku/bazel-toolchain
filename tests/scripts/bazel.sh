#!/bin/bash
if [[ -z "$(command -v bazel)" ]]; then
    echo >&2 "No binary named 'bazel' found. Please install it first."
    exit 1
fi

bazel="$(command -v bazel)"
readonly bazel

readonly common_test_args=(
  --incompatible_enable_cc_toolchain_resolution
  --symlink_prefix=/
  --color=yes
  --keep_going
  --test_output=errors
)
