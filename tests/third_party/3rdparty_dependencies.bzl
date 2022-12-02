load("//third_party/sysroots:workspace.bzl", sysroots = "repo")
load("//third_party/openssl:workspace.bzl", openssl = "repo")
load("//third_party/libevent:workspace.bzl", libevent = "repo")

def init_3rdparty_deps():
    openssl()
    sysroots()
    libevent()
