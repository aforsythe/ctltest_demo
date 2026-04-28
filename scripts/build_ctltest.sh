#!/usr/bin/env bash
# Clone the pinned CTL fork, build the ctltest binary, print its path.

set -euo pipefail

: "${CTL_REPO:=https://github.com/aforsythe/CTL.git}"
: "${CTL_REF:=3ff847d552a5e008d0b828a3b8a5ad795660e95d}"

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
default_dir="$(cd "$repo_root/.." && pwd)/ctl-fork"
: "${CTLTEST_DEMO_CTL_DIR:=$default_dir}"

if [ ! -d "$CTLTEST_DEMO_CTL_DIR/.git" ]; then
  echo "==> cloning $CTL_REPO -> $CTLTEST_DEMO_CTL_DIR" >&2
  git clone --filter=blob:none "$CTL_REPO" "$CTLTEST_DEMO_CTL_DIR"
fi

cd "$CTLTEST_DEMO_CTL_DIR"
git fetch --depth 50 origin >/dev/null 2>&1 || true
git checkout -q "$CTL_REF"

build_dir="$CTLTEST_DEMO_CTL_DIR/build"
if [ ! -f "$build_dir/CMakeCache.txt" ]; then
  cmake -B "$build_dir" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCTL_BUILD_MODULETEST=ON \
    -DCTL_USE_SLEEF=OFF >&2
fi

cmake --build "$build_dir" -j --target ctltest >&2

bin="$build_dir/moduletest/cli/ctltest"
if [ ! -x "$bin" ]; then
  echo "ERROR: build did not produce $bin" >&2
  exit 1
fi
echo "$bin"
