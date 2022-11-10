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
load("//toolchain/internal:common.bzl", _arch = "arch")

# Note: Unlike the user-specified llvm_mirror attribute, the URL prefixes in
# this map are not immediately appended with "/". This is because LLVM prebuilt
# URLs changed when they switched to hosting the files on GitHub as of 10.0.0.
_LLVM_DIST_BASE_URL = "https://github.com/llvm/llvm-project/releases/download/llvmorg-"
_QCRAFT_OSS_URL = "https://qcraft-web.oss-cn-beijing.aliyuncs.com/cache/packages"

def _download_llvm(rctx):
    llvm_version = rctx.attr.llvm_version
    arch = _arch(rctx)

    urls, sha256, strip_prefix = _distribution_urls(arch, llvm_version)

    rctx.download_and_extract(
        urls,
        sha256 = sha256,
        stripPrefix = strip_prefix,
    )

def _distribution_urls(arch, llvm_version):
    llvm_dists = {
        "aarch64-13.0.1": [
            "clang+llvm-13.0.1-x86_64-linux-gnu-ubuntu-18.04.tar.xz",
            "84a54c69781ad90615d1b0276a83ff87daaeded99fbc64457c350679df7b4ff0",
        ],
        "aarch64-14.0.0": [
            "clang+llvm-14.0.0-aarch64-linux-gnu.tar.xz",
            "1792badcd44066c79148ffeb1746058422cc9d838462be07e3cb19a4b724a1ee",
        ],
        "x86_64-13.0.1": [
            "clang+llvm-13.0.1-aarch64-linux-gnu.tar.xz",
            "15ff2db12683e69e552b6668f7ca49edaa01ce32cb1cbc8f8ed2e887ab291069",
        ],
        "x86_64-14.0.0": [
            "clang+llvm-14.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz",
            "61582215dafafb7b576ea30cc136be92c877ba1f1c31ddbbd372d6d65622fef5",
        ],
    }
    key = "{}-{}".format(arch, llvm_version)
    if key not in llvm_dists:
        fail("Unknown arch-version index:{}".format(key))

    basename, sha256 = llvm_dists[key]

    urls = _llvm_mirror_urls(basename, llvm_version)
    strip_prefix = basename[:(len(basename) - len(".tar.xz"))]
    return urls, sha256, strip_prefix

def _llvm_mirror_urls(basename, llvm_version):
    basename = basename.replace("+", "%2B")
    urls = [
        "{}/{}".format(_QCRAFT_OSS_URL, basename),
        "{}{}/{}".format(_LLVM_DIST_BASE_URL, llvm_version, basename),
    ]
    return urls

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
