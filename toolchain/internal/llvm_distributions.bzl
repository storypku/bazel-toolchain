# Copyright 2018 The Bazel Authors.
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

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "read_netrc", "use_netrc")
load("//toolchain/internal:common.bzl", _attr_dict = "attr_dict", _python = "python")

# If a new LLVM version is missing from this list, please add the shasum here
# and send a PR on github. To compute the shasum block, you can use the script
# utils/llvm_checksums.sh
_llvm_distributions = {
    # 13.0.1
    "clang+llvm-13.0.1-aarch64-linux-gnu.tar.xz": "15ff2db12683e69e552b6668f7ca49edaa01ce32cb1cbc8f8ed2e887ab291069",
    "clang+llvm-13.0.1-x86_64-linux-gnu-ubuntu-18.04.tar.xz": "84a54c69781ad90615d1b0276a83ff87daaeded99fbc64457c350679df7b4ff0",

    # 14.0.0
    "clang+llvm-14.0.0-aarch64-linux-gnu.tar.xz": "1792badcd44066c79148ffeb1746058422cc9d838462be07e3cb19a4b724a1ee",
    "clang+llvm-14.0.0-amd64-pc-solaris2.11.tar.xz": "a708470fdbaadf530d6cfd56f92fde1328cb47ef8439ecf1a2126523e7c94a50",
    "clang+llvm-14.0.0-amd64-unknown-freebsd12.tar.xz": "7eaff7ee2a32babd795599f41f4a5ffe7f161721ebf5630f48418e626650105e",
    "clang+llvm-14.0.0-amd64-unknown-freebsd13.tar.xz": "b68d73fd57be385e7f06046a87381f7520c8861f492c294e6301d2843d9a1f57",
    "clang+llvm-14.0.0-armv7a-linux-gnueabihf.tar.xz": "17d5f60c3d5f9494be7f67b2dc9e6017cd5e8457e53465968a54ec7069923bfe",
    "clang+llvm-14.0.0-i386-unknown-freebsd12.tar.xz": "5ed9d93a8425132e8117d7061d09c2989ce6b2326f25c46633e2b2dee955bb00",
    "clang+llvm-14.0.0-i386-unknown-freebsd13.tar.xz": "81f49eb466ce9149335ac8918a5f02fa724d562a94464ed13745db0165b4a220",
    "clang+llvm-14.0.0-powerpc64-ibm-aix-7.2.tar.xz": "4ad5866de6c69d989cbbc989201b46dfdcd7d2b23a712fcad7baa09c204f10de",
    "clang+llvm-14.0.0-powerpc64le-linux-rhel-7.9.tar.xz": "7a31de37959fdf3be897b01f284a91c28cd38a2e2fa038ff58121d1b6f6eb087",
    "clang+llvm-14.0.0-powerpc64le-linux-ubuntu-18.04.tar.xz": "2d504c4920885c86b306358846178bc2232dfac83b47c3b1d05861a8162980e6",
    "clang+llvm-14.0.0-sparcv9-sun-solaris2.11.tar.xz": "b342cdaaea3b44de5b0f45052e2df49bcdf69dcc8ad0c23ec5afc04668929681",
    "clang+llvm-14.0.0-x86_64-apple-darwin.tar.xz": "cf5af0f32d78dcf4413ef6966abbfd5b1445fe80bba57f2ff8a08f77e672b9b3",
    "clang+llvm-14.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz": "61582215dafafb7b576ea30cc136be92c877ba1f1c31ddbbd372d6d65622fef5",
    "clang+llvm-14.0.0-x86_64-linux-sles12.4.tar.xz": "78f70cc94c3b6f562455b15cebb63e75571d50c3d488d53d9aa4cd9dded30627",
}

# Note: Unlike the user-specified llvm_mirror attribute, the URL prefixes in
# this map are not immediately appended with "/". This is because LLVM prebuilt
# URLs changed when they switched to hosting the files on GitHub as of 10.0.0.
_llvm_distributions_base_url = {
    "13.0.1": "https://github.com/llvm/llvm-project/releases/download/llvmorg-",
    "14.0.0": "https://github.com/llvm/llvm-project/releases/download/llvmorg-",
}

def _get_auth(rctx, urls):
    """
    Given the list of URLs obtain the correct auth dict.

    Based on:
    https://github.com/bazelbuild/bazel/blob/793964e8e4268629d82fabbd08bf1a7718afa301/tools/build_defs/repo/http.bzl#L42
    """
    netrcpath = None
    if rctx.attr.netrc:
        netrcpath = rctx.attr.netrc
    else:
        if "HOME" in rctx.os.environ:
            netrcpath = "%s/.netrc" % (rctx.os.environ["HOME"])
            print(netrcpath)

    if netrcpath and rctx.path(netrcpath).exists:
        netrc = read_netrc(rctx, netrcpath)
        return use_netrc(netrc, urls, rctx.attr.auth_patterns)

    return {}

def download_llvm(rctx):
    urls = []
    if rctx.attr.urls:
        urls, sha256, strip_prefix, key = _urls(rctx)
    if not urls:
        urls, sha256, strip_prefix = _distribution_urls(rctx)

    res = rctx.download_and_extract(
        urls,
        sha256 = sha256,
        stripPrefix = strip_prefix,
        auth = _get_auth(rctx, urls),
    )

    updated_attrs = _attr_dict(rctx.attr)
    if not sha256 and key:
        # Only using the urls attribute can result in no sha256.
        # Report back the sha256 if the URL came from a non-empty key.
        updated_attrs["sha256"].update([(key, res.sha256)])

    return updated_attrs

def _urls(rctx):
    key = _host_os_key(rctx)

    urls = rctx.attr.urls.get(key, default = rctx.attr.urls.get("", default = []))
    if not urls:
        print("llvm archive urls missing for host OS key '%s' and no default provided; will try 'distribution' attribute" % (key))
    sha256 = rctx.attr.sha256.get(key, "")
    strip_prefix = rctx.attr.strip_prefix.get(key, "")

    return urls, sha256, strip_prefix, key

def _distribution_urls(rctx):
    llvm_version = rctx.attr.llvm_version

    if rctx.attr.distribution == "auto":
        basename = _llvm_release_name(rctx, llvm_version)
    else:
        basename = rctx.attr.distribution

    if basename not in _llvm_distributions:
        fail("Unknown LLVM release: %s\nPlease ensure file name is correct." % basename)

    urls = []
    url_suffix = "{0}/{1}".format(llvm_version, basename).replace("+", "%2B")
    if rctx.attr.llvm_mirror:
        urls.append("{0}/{1}".format(rctx.attr.llvm_mirror, url_suffix))
    if rctx.attr.alternative_llvm_sources:
        for pattern in rctx.attr.alternative_llvm_sources:
            urls.append(pattern.format(llvm_version = llvm_version, basename = basename))
    urls.append("{0}{1}".format(_llvm_distributions_base_url[llvm_version], url_suffix))

    sha256 = _llvm_distributions[basename]

    strip_prefix = basename[:(len(basename) - len(".tar.xz"))]

    return urls, sha256, strip_prefix

def _host_os_key(rctx):
    exec_result = rctx.execute([
        _python(rctx),
        rctx.path(rctx.attr._os_version_arch),
    ])
    if exec_result.return_code:
        fail("Failed to detect host OS name and version: \n%s\n%s" % (exec_result.stdout, exec_result.stderr))
    if exec_result.stderr:
        print(exec_result.stderr)
    return exec_result.stdout.strip()

def _llvm_release_name(rctx, llvm_version):
    exec_result = rctx.execute([
        _python(rctx),
        rctx.path(rctx.attr._llvm_release_name),
        llvm_version,
    ])
    if exec_result.return_code:
        fail("Failed to detect host OS LLVM archive: \n%s\n%s" % (exec_result.stdout, exec_result.stderr))
    if exec_result.stderr:
        print(exec_result.stderr)
    return exec_result.stdout.strip()
