---
change: run-the-specsync-archive-gate-before-every-ci-job
artifact: plan
---

# Plan

## Approach

Add an `archive-gate` job, displayed as `Archive`, at the top of `jobs:` in every
workflow that triggers on `pull_request` or `push`, and make every other job depend
on it. The job checks out the pull request head (or the pushed commit) without
persisted credentials and runs `CorvidLabs/spec-sync` pinned at
106aaa43d0bcf049f19b173ddb63815a25c3f931 with `archive-gate-only: 'true'`.

## Out of scope

- Archiving, approving or otherwise touching the open changes CHG-0001, CHG-0002
  and CHG-0003.
- The org ruleset that requires the `Archive` check.
- Any change to build, test, documentation or trust steps.

## Steps

1. Add the `archive-gate` job to `docs.yml`, `macOS.yml` and `trust.yml`, using
   `ubuntu-latest` (all existing jobs run on GitHub-hosted runners) and the same
   `actions/checkout@v5` each workflow already uses.
2. Add `needs: archive-gate` to `build` (docs.yml), `macOS` (macOS.yml) and
   `trust` (trust.yml). `deploy` already needs `build`, so it depends on the gate
   transitively.
3. Parse each workflow and print each job's needs to confirm the graph.

## Risks

- While any change is open, every other job is skipped. This is the intended
  behavior, but it means CI stays red until open changes are archived.
- The pin is a commit on `main`, not a release; it should move to the first
  release that ships the gate.

## Constraints consulted

- AGENTS.md (CorvidLabs trust toolchain): the trust gate in `trust.yml` is kept in
  place and not weakened; it only runs after the Archive job now. Module specs are
  unaffected because no source changes.
