#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Single tag arg is passed by https://github.com/bazel-contrib/.github/blob/master/.github/workflows/release_ruleset.yaml
TAG="$1"
# Drops the leading 'v' from tag
VERSION="${TAG#v}"
PREFIX="gazelle_cc-${VERSION}"
ARCHIVE="gazelle_cc-$TAG.tar.gz"
git archive --format=tar.gz --prefix=${PREFIX}/ ${TAG} > $ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

cat << EOF
## Using Bzlmod

Paste this snippet into your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "gazelle_cc", version = "${VERSION}")
\`\`\`

## Using WORKSPACE

Paste this snippet into your \`WORKSPACE\` file:

\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "gazelle_cc",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    url = "https://github.com/EngFlow/gazelle_cc/releases/download/${TAG}/${ARCHIVE}",
)
load("@gazelle_cc//:deps.bzl", "gazelle_cc_dependencies")
gazelle_cc_dependencies()
\`\`\`

See https://github.com/EngFlow/gazelle_cc#installation for full setup instructions.
EOF
