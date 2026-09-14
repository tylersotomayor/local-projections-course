# vendor/jel-code: the authors' files for REP01

Four files from the replication package of Jordà and Taylor (2025), "Local
Projections," *Journal of Economic Literature* 63(1), 59–110, copied byte for
byte, with one change: the `cap cd` commands that name the authors' own folders
(lines 5 and 7 of `SSBias_IntcpYLagdiffN_95.do`, lines 7 and 9 of
`all-simulate.do`) are commented out, so that the lab archive contains no
absolute path. Outside the authors' machines those commands failed silently, so
the scripts run as they did before.

| Field | Value |
|---|---|
| Repository | https://github.com/ojorda/JEL-Code |
| Frozen commit | `655696c1c576b7537c5a939d2c261f0a111ae663` (branch `main`) |
| Snapshot | https://codeload.github.com/ojorda/JEL-Code/tar.gz/655696c1c576b7537c5a939d2c261f0a111ae663 |
| Retrieved | 2026-09-13, 16:23 UTC, by the course's replication infrastructure |
| Path in the package | `LP_JEL_Replication/Example1_LongDifferences/` (the supplied `LP_JEL_Replication.zip` is byte-identical to the commit's) |
| License | CC0 1.0 Universal (public-domain dedication), reproduced in `LICENSE` |
| Third-party material | None in these files: Example 1 simulates its data. The package as a whole notes that third-party data may carry their own terms. |

| File | Role in REP01 | SHA-256 |
|---|---|---|
| `SSBias_IntcpYLagdiffN_95.do` | Produces the levels-LP mean of Figure 1a (lines 83–90 and 139–140); run by `replication/rep01.do` when `AUTHOR_CHECK = 1` | shipped copy `2afefb0b1f786fea687ccc29c392c74809812fa1b7b8f91fc75c2d5befd91fc1`; the authors' file `07116508f0d0c633a6a0942e04867290a0fe808f254ea8b7bf3e0c4682a1e7e2` |
| `all-simulate.do` | The authors' driver; lines 18–19 set `nobs 100` and `nreps 10000` | shipped copy `960719e2c52d0b91438a2873f5aa9cfbbb17fa220eae63706c8ab566a77662b1`; the authors' file `730dae2639931ccab9b24cdbc198db8dadf731da6c540bf80065780d0303a6df` |
| `SSBias_IntcpYLagdiffN_95.dta` | The authors' shipped output (saved October 29, 2023): Monte Carlo means `rl` over 10,000 draws and the true response `rt`, $h=0,\dots,10$ | `720462bff571cccca5e504bda2eb7b230cfacc82abfc23c923088c8366f102a4` |
| `LICENSE` | CC0 1.0 text from the repository | `a2010f343487d3f7618affe54f789f5487602331c0a8d03f49e9a7c547cf0499` |

Running `SSBias_IntcpYLagdiffN_95.do` requires the globals `nobs` and `nreps`,
which `all-simulate.do` sets. Its `cap cd` lines, commented out here, pointed
to the authors' Dropbox folders and failed silently elsewhere,
`graph set window fontface "Palatino"`
has no effect in batch mode, and the file exports a PDF to the working folder,
which `rep01.do` sets to `output/rep01-author/`.
