load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def clean_dep(dep):
    return str(Label(dep))

def repo(use_local = True):
    if use_local:
        native.new_local_repository(
            name = "openssl",
            path = "/usr/include/openssl",
            build_file = clean_dep("//third_party/openssl:openssl.BUILD"),
        )
    else:
        http_archive(
            name = "openssl",
            build_file = clean_dep("//openssl:openssl.bazel"),
            sha256 = "f6fb3079ad15076154eda9413fed42877d668e7069d9b87396d0804fdb3f4c90",
            strip_prefix = "openssl-1.1.1c",
            urls = ["https://www.openssl.org/source/openssl-1.1.1c.tar.gz"],
        )

# For testing rules_go.

