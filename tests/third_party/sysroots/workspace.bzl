load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def clean_dep(dep):
    return str(Label(dep))

def repo():
    # This sysroot is used by github.com/vsco/bazel-toolchains.
    http_archive(
        name = "chromium_sysroot_linux_x64",
        build_file = clean_dep("//third_party/sysroots:chromium_sysroot.BUILD"),
        sha256 = "84656a6df544ecef62169cfe3ab6e41bb4346a62d3ba2a045dc5a0a2ecea94a3",
        urls = [
            "https://qcraft-web.oss-cn-beijing.aliyuncs.com/cache/packages/debian_stretch_amd64_sysroot.tar.xz",
            "https://commondatastorage.googleapis.com/chrome-linux-sysroot/toolchain/2202c161310ffde63729f29d27fe7bb24a0bc540/debian_stretch_amd64_sysroot.tar.xz",
        ],
    )

    http_archive(
        name = "chromium_sysroot_linux_arm64",
        build_file = clean_dep("//third_party/sysroots:chromium_sysroot.BUILD"),
        sha256 = "0d4ba53fa4aed14e50c07a65131d078f2a3ee2f53e695ed93855facf4860bea5",
        urls = [
            "https://qcraft-web.oss-cn-beijing.aliyuncs.com/cache/packages/debian_stretch_arm64_sysroot.tar.xz",
            "https://commondatastorage.googleapis.com/chrome-linux-sysroot/toolchain/1126d9b629c97385a503debac7a1b59e60a3ab1b/debian_stretch_arm64_sysroot.tar.xz",
        ],
    )
