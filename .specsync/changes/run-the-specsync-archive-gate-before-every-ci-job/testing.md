---
change: run-the-specsync-archive-gate-before-every-ci-job
artifact: testing
---

# Testing

- Each edited workflow parses with
  `ruby -e 'require "psych"; Psych.safe_load(File.read(ARGV[0]))'`, and printing
  every job's `needs` shows `archive-gate` with no needs, `build`, `macOS` and
  `trust` needing `archive-gate`, and `deploy` needing `build`.
- `bash .github/scripts/archive-readiness.sh .` from CorvidLabs/spec-sync at the
  pinned commit fails while changes are open and names the first one to archive,
  which is what the Archive job reports in CI.
- On the pull request, the `Archive` check runs first and every other job waits
  for it.
