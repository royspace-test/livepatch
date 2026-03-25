#!/bin/bash
#
# Auto-run livepatch example: build, start testlive, apply patch, verify.
#
# Prerequisite: binutils-dev (apt-get install binutils-dev) for libbfd.
#
# Usage: ./run_example.sh [livepatch_dir]
#   If livepatch_dir is omitted, use the directory containing this script.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIVEPATCH_DIR="${1:-$SCRIPT_DIR}"
cd "$LIVEPATCH_DIR"

# Build (drop stale testlive.o so Makefile's -fno-ipa-icf rule always applies)
echo "==> Building livepatch, libfoo, testlive..."
rm -f testlive.o testlive
if ! make livepatch libfoo.so testlive; then
	echo "Build failed. Install binutils-dev: apt-get install binutils-dev"
	exit 1
fi

# Patch shared object from Makefile (or override with foo.so)
PATCH_SO1="libfoo.so"
PATCH_SO2="libfoo2.so"
[[ -f foo.so ]] && PATCH_SO1="foo.so"
[[ -f foo2.so ]] && PATCH_SO2="foo2.so"

echo "==> Starting testlive in background..."
./testlive &
TARGET_PID=$!
trap "kill $TARGET_PID 2>/dev/null; wait $TARGET_PID 2>/dev/null; exit" INT TERM

# Give testlive time to start
sleep 10
echo "================================================"
echo "start to apply livepatch"
echo "================================================"


echo "==> Applying livepatch (dl + jmp)..."
{
	echo "dl foo1 $PATCH_SO1"
	echo "jmp func_J \$foo1:func1"
	echo "dl foo2 $PATCH_SO2"
	echo "jmp func_Q \$foo2:func2"
} | sudo ./livepatch "$TARGET_PID" ./testlive

echo "==> Waiting for testlive to complete..."
wait $TARGET_PID 2>/dev/null || true
echo "==> Done."
