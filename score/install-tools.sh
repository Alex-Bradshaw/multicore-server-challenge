#!/usr/bin/env bash
# Installs the scoring tools on the benchmark box, from a checkout of this repo at /opt/challenge-repo. Run as root.
# /opt/conduit-tools: switch.sh, monitor.sh, prepare.sh, conformance (built from bench/cmd/conformance).
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
install -d /opt/conduit-tools /opt/challenge/subs /root/conduit-monitor
install -m 755 "$REPO/score/switch.sh" "$REPO/score/monitor.sh" "$REPO/score/prepare.sh" /opt/conduit-tools/
(cd "$REPO/bench" && HOME=/root PATH=/usr/local/go/bin:$PATH go build -o /opt/conduit-tools/conformance ./cmd/conformance)
ls -l /opt/conduit-tools
