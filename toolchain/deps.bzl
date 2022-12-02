load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//third_party/llvm_repo:workspace.bzl", llvm_repo = "repo")

def bazel_toolchain_dependencies():
    # Load rules_cc if the user has not defined them.
    if not native.existing_rule("rules_cc"):
        http_archive(
            name = "rules_cc",
            sha256 = "b6f34b3261ec02f85dbc5a8bdc9414ce548e1f5f67e000d7069571799cb88b25",
            strip_prefix = "rules_cc-726dd8157557f1456b3656e26ab21a1646653405",
            urls = ["https://github.com/bazelbuild/rules_cc/archive/726dd8157557f1456b3656e26ab21a1646653405.tar.gz"],
        )

    if not native.existing_rule("llvm_repo"):
        llvm_repo(use_local = True)
