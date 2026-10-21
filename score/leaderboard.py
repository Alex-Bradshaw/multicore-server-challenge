#!/usr/bin/env python3
"""Writes LEADERBOARD.md from the benchmark results.

    python3 score/leaderboard.py results/ > LEADERBOARD.md

results/<name>/SUMMARY.json is what `conduit-loadgen search` writes for one submission (or example-<lang> for the
video's examples). results/notes.json (optional) maps <name> to a short note shown next to the score, and
results/failed.json maps <name> to why it wasn't scored. Pull request numbers and authors come from `gh`.
"""
import json, subprocess, sys
from pathlib import Path

REPO = "arjaythedev/multicore-server-challenge"
res = Path(sys.argv[1] if len(sys.argv) > 1 else "results")


def load(name):
    p = res / name
    return json.loads(p.read_text()) if p.exists() else {}


notes, failed = load("notes.json"), load("failed.json")

prs = {}
out = subprocess.run(["gh", "pr", "list", "-R", REPO, "--state", "all", "--limit", "500",
                      "--json", "number,author,state,files"], capture_output=True, text=True, check=True).stdout
for pr in sorted(json.loads(out), key=lambda p: p["number"]):
    for f in pr["files"]:
        parts = f["path"].split("/")
        if parts[0] == "submissions" and len(parts) > 2:
            prev = prs.get(parts[1])
            # a merged PR wins over closed or open ones for the same folder, then the newest
            if not prev or pr["state"] == "MERGED" or prev["state"] != "MERGED":
                prs[parts[1]] = pr

rows = []
for d in sorted(res.iterdir()):
    s = d / "SUMMARY.json"
    if not s.is_file():
        continue
    j = json.loads(s.read_text())
    if j.get("status") != "ok" or not j.get("score_users"):
        continue
    rows.append((d.name, j))
rows.sort(key=lambda r: -r[1]["score_users"])


def who(name):
    if name.startswith("example-"):
        lang = name.split("-", 1)[1]
        return f"[{lang} example](examples/{lang}) (the video's server)", "—"
    pr = prs.get(name)
    if not pr:
        return f"`{name}`", "—"
    link = f"[{name}](submissions/{name})" if pr["state"] == "MERGED" else f"[{name}](https://github.com/{REPO}/pull/{pr['number']})"
    return link, f"[#{pr['number']}](https://github.com/{REPO}/pull/{pr['number']}) @{pr['author']['login']}"


def front(name):
    # switch.sh logs the Front it read from the README
    log = res / name / "switch.log"
    if log.exists():
        for f in ("direct", "nginx"):
            if f"Front: {f}" in log.read_text():
                return f
    return ""


print("# Leaderboard\n")
print("Every submission on the same box: **8 dedicated vCPU / 16 GB**, Postgres 18 on the same box, full seed, "
      "the load generator on a separate machine. Score = the most users held for a 5-minute run with p95 < 500 ms, "
      "p99 < 1 s and < 1% errors ([how it's scored](README.md#scoring)). The video's four examples were re-run on this "
      "same box so everything compares like with like.\n")
print("| # | Users | Submission | PR | Front | req/s | p95 ms | p99 ms | CPU: app / Postgres | Note |")
print("|--:|--:|---|---|---|--:|--:|--:|---|---|")
for i, (name, j) in enumerate(rows, 1):
    link, pr = who(name)
    cpu = j.get("target_cpu") or {}
    # despite the names these are shares of the whole box (search.go averages the monitor's *_box columns)
    app, db, ngx = (cpu.get(k) for k in ("app_pct_of_one_core", "db_pct_of_one_core", "nginx_pct_of_one_core"))
    split = f"{app:.0f}% / {db:.0f}%" if app is not None and db is not None else ""
    if ngx:
        split += f" (+ Nginx {ngx:.0f}%)"
    print(f"| {i} | **{j['score_users']:,}** | {link} | {pr} | {front(name)} | {j['rps']:,.0f} | {j['p95_ms']:.0f} | "
          f"{j['p99_ms']:.0f} | {split} | {notes.get(name, '')} |")
if failed:
    print("\n## Not scored\n")
    print("| Submission | PR | Why |")
    print("|---|---|---|")
    for name, why in sorted(failed.items()):
        link, pr = who(name)
        print(f"| {link} | {pr} | {why} |")
print("\nCPU is the share of the whole box (8 cores) used by your server and by Postgres during the scored 5 minutes. "
      "Raw results for every run (each probe and hold, per-endpoint latencies, the box's CPU every second) are kept "
      "and can be shared on request.")
