---
id: run-the-specsync-archive-gate-before-every-ci-job
state: draft
type: operations
base_commit: 84551f24387ee3937029915e9688e229b47658b0
---

# Run the SpecSync archive gate before every CI job

## Intent

Run the SpecSync archive gate before every CI job

## Affected Canonical Specs

- None

## Acceptance Criteria

- Each CI workflow that runs on pull_request or push (docs.yml, macOS.yml, trust.yml) has an archive-gate job named Archive at the top of jobs that runs CorvidLabs/spec-sync pinned at 106aaa43d0bcf049f19b173ddb63815a25c3f931 with archive-gate-only 'true', and every other job needs it directly or transitively, so no other job runs while any change under .specsync/changes/ is still open.

## No-spec Rationale

CI workflow ordering only; no canonical spec owns .github/workflows
