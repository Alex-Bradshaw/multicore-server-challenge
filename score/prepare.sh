#!/usr/bin/env bash
# Installs and builds one submission on the benchmark box. Run as root on the box after copying the submission
# folder to /opt/challenge/subs/<name> (score/push.sh does both from a checkout).
#
#   prepare.sh rust-hyper-cknutson12
#
# install.sh runs as root (rule 11: toolchain/runtime on a clean Ubuntu 24.04), build.sh as user `challenge`,
# both in the submission folder. Logs: /root/prepare-<name>.log.
set -euo pipefail
NAME="${1:?usage: prepare.sh <submission folder name>}"
SUB="/opt/challenge/subs/$NAME"
[ -f "$SUB/build.sh" ] || { echo "no $SUB/build.sh"; exit 1; }
LOG="/root/prepare-$NAME.log"
say() { printf '[prepare %s %s] %s\n' "$NAME" "$(date +%T)" "$*" | tee -a "$LOG"; }
: > "$LOG"
rm -f "$SUB/.built"
chown -R challenge:challenge "$SUB"
chmod +x "$SUB"/*.sh   # systemd execs start.sh directly; git may not carry the exec bit
if [ -f "$SUB/install.sh" ]; then
  say "install.sh (root)"; t=$SECONDS
  (cd "$SUB" && DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a bash install.sh) >> "$LOG" 2>&1 || { tail -40 "$LOG"; say "install.sh FAILED"; exit 1; }
  say "  done in $((SECONDS - t)) s"
fi
say "build.sh (challenge)"; t=$SECONDS
runuser -u challenge -- env -i HOME=/home/challenge USER=challenge PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin LANG=C.UTF-8 \
  bash -c "cd '$SUB' && bash build.sh" >> "$LOG" 2>&1 || { tail -40 "$LOG"; say "build.sh FAILED"; exit 1; }
say "  done in $((SECONDS - t)) s"
touch "$SUB/.built"
say "BUILT"
