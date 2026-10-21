#!/usr/bin/env bash
# Copies submissions from pull requests to the benchmark box, from a checkout of this repo on your machine.
#
#   TARGET=mc-target bash score/push.sh 4 5 7    # PR numbers
#
# Each PR is fetched as pr/<N>, and its submissions/<name>/ folder replaces /opt/challenge/subs/<name> on the box.
# Prints "<N> <name>" per PR (the name is what score/chain.sh and prepare.sh take).
set -euo pipefail
TARGET="${TARGET:-mc-target}"
cd "$(dirname "$0")/.."
for n in "$@"; do
  git fetch -q origin "pull/$n/head:pr/$n" -f
  names=$(git diff --name-only "main...pr/$n" | awk -F/ '$1=="submissions" && NF>2 {print $2}' | sort -u)
  [ -n "$names" ] || { echo "$n -"; continue; }
  for name in $names; do
    git archive "pr/$n" "submissions/$name" | ssh "$TARGET" \
      "rm -rf '/opt/challenge/subs/$name' && tar -x -C /tmp -f - && mv '/tmp/submissions/$name' /opt/challenge/subs/ && rmdir /tmp/submissions 2>/dev/null; true"
    echo "$n $name"
  done
done
