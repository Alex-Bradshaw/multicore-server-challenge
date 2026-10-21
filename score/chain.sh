#!/usr/bin/env bash
# Runs a batch of submissions one after another, unattended. Run ON the load generator (it has an ssh key into the
# target), under nohup. The submission folders must already be on the target in /opt/challenge/subs/<name>
# (score/push.sh).
#
#   nohup bash chain.sh batch.txt > /root/results/chain.out 2>&1 &
#
# batch.txt: one submission folder name per line ('#' comments ok). Per submission: prepare.sh (install + build) on
# the target, then `conduit-loadgen search` (switch with conformance on the full seed, warm-up, probes, holds).
# A name with results/<name>/SUMMARY.txt already is skipped, so re-launching resumes the batch.
# Progress: /root/results/chain.log, one line per step.
set -u
LIST="${1:?usage: chain.sh <batch.txt>}"
TARGET="${TARGET:-root@167.17.74.133}"
URLS="${URLS:-http://167.17.74.133,http://167.17.74.134,http://167.17.74.135,http://167.17.74.136}"
MAX="${MAX:-250000}"
START="${START:-2000}"
OUT=/root/results
LOG="$OUT/chain.log"
export CONDUIT_JWT_SECRET=multicore-server-challenge
mkdir -p "$OUT"
say() { printf '%s %s\n' "$(date -u +%FT%TZ)" "$*" | tee -a "$LOG"; }

grep -v '^\s*#' "$LIST" | awk 'NF{print $1}' | while read -r name; do
  if [ -s "$OUT/$name/SUMMARY.txt" ]; then say "$name: already scored, skipping"; continue; fi
  say "$name: prepare"
  if ! ssh -n -o BatchMode=yes "$TARGET" "/opt/conduit-tools/prepare.sh '$name'" > "$OUT/$name.prepare.log" 2>&1; then
    say "$name: PREPARE FAILED (see $name.prepare.log)"; continue
  fi
  say "$name: search"
  conduit-loadgen search -target-ssh "$TARGET" -target-url "$URLS" -boxes local=1 -lang "$name" -label "$name" \
    -start "$START" -max "$MAX" -outdir "$OUT/$name" < /dev/null > "$OUT/$name.out" 2>&1
  rc=$?
  if [ -s "$OUT/$name/SUMMARY.txt" ]; then
    say "$name: done rc=$rc: $(grep -m1 '^SCORE' "$OUT/$name/SUMMARY.txt")"
  else
    say "$name: SEARCH FAILED rc=$rc: $(grep -m1 -iE 'fail|error' "$OUT/$name.out" | cut -c1-200)"
  fi
  ssh -n -o BatchMode=yes "$TARGET" 'systemctl stop challenge.service' >/dev/null 2>&1
done
say "batch done"
