# Leaderboard

Every submission on the same box: **8 dedicated vCPU / 16 GB**, Postgres 18 on the same box, full seed, the load generator on a separate machine. Score = the most users held for a 5-minute run with p95 < 500 ms, p99 < 1 s and < 1% errors ([how it's scored](README.md#scoring)). The video's four examples were re-run on this same box so everything compares like with like.

| # | Users | Submission | PR | Front | req/s | p95 ms | p99 ms | CPU: app / Postgres | Note |
|--:|--:|---|---|---|--:|--:|--:|---|---|
| 1 | **100,000** | [rust-tokio-Scooter1337](submissions/rust-tokio-Scooter1337) | [#7](https://github.com/arjaythedev/multicore-server-challenge/pull/7) @Scooter1337 | direct | 26,279 | 119 | 185 | 20% / 70% |  |
| 2 | **84,000** | [c-iouring-tigokraft](submissions/c-iouring-tigokraft) | [#10](https://github.com/arjaythedev/multicore-server-challenge/pull/10) @tigokraft | direct | 21,262 | 339 | 421 | 18% / 80% |  |
| 3 | **84,000** | [cobol-gnucobol-benmandrew](submissions/cobol-gnucobol-benmandrew) | [#15](https://github.com/arjaythedev/multicore-server-challenge/pull/15) @benmandrew | direct | 21,292 | 361 | 461 | 20% / 75% |  |
| 4 | **84,000** | [csharp-kestrel-xeonfx](https://github.com/arjaythedev/multicore-server-challenge/pull/8) | [#8](https://github.com/arjaythedev/multicore-server-challenge/pull/8) @XeonFX | direct | 20,906 | 404 | 467 | 25% / 74% | Not merged yet: bcrypt comes from a prebuilt NuGet package; waiting for the source in the folder |
| 5 | **68,000** | [cpp-asio-c-hatton](submissions/cpp-asio-c-hatton) | [#4](https://github.com/arjaythedev/multicore-server-challenge/pull/4) @C-Hatton | direct | 17,887 | 94 | 174 | 27% / 71% |  |
| 6 | **58,000** | [rust-hyper-cknutson12](submissions/rust-hyper-cknutson12) | [#1](https://github.com/arjaythedev/multicore-server-challenge/pull/1) @cknutson12 | direct | 15,075 | 223 | 367 | 29% / 69% |  |
| 7 | **46,000** | [python-uvloop-bensgilbert](https://github.com/arjaythedev/multicore-server-challenge/pull/13) | [#13](https://github.com/arjaythedev/multicore-server-challenge/pull/13) @bensgilbert | direct | 11,572 | 423 | 519 | 38% / 58% | Not merged yet: restarts crashed workers (rule 9). No worker restarted during the run, so the score stands |
| 8 | **32,000** | [elixir-raw-foovoo](submissions/elixir-raw-foovoo) | [#12](https://github.com/arjaythedev/multicore-server-challenge/pull/12) @FooVoo | direct | 7,999 | 323 | 382 | 37% / 48% |  |
| 9 | **20,000** | [swift-hummingbird-denizakya](submissions/swift-hummingbird-denizakya) | [#9](https://github.com/arjaythedev/multicore-server-challenge/pull/9) @denizak | nginx | 5,077 | 339 | 400 | 48% / 40% (+ Nginx 10%) |  |

CPU is the share of the whole box (8 cores) used by your server and by Postgres during the scored 5 minutes. Raw results for every run (each probe and hold, per-endpoint latencies, the box's CPU every second) are kept and can be shared on request.
