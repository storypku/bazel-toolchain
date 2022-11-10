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

load(
    "//toolchain/internal:llvm_distributions.bzl",
    _download_llvm = "download_llvm",
)

def llvm_repo_impl(rctx):
    os = rctx.os.name
    if os != "linux":
        fail("Non-Linux system not supported: {}".format(os))

    rctx.file(
        "BUILD.bazel",
        content = rctx.read(Label("//toolchain:BUILD.llvm_repo")),
        executable = False,
    )
    _download_llvm(rctx)
