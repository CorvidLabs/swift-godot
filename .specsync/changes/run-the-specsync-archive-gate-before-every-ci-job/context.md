---
change: run-the-specsync-archive-gate-before-every-ci-job
artifact: context
---

# Context

This change is part of the org-wide rollout of CorvidLabs/spec-sync#832, approved
by 0xLeif. That pull request (merged as 106aaa43d0bcf049f19b173ddb63815a25c3f931)
added an archive gate to the spec-sync GitHub Action: with `archive-gate-only: 'true'`
it runs only `.github/scripts/archive-readiness.sh` (bash and python3, no binary
download) and fails while any change under `.specsync/changes/` is still open.
Every SpecSync change must be archived before a pull request merges, and CI should
run nothing else until it is.

Published releases up to v6.1.1 ignore the `archive-gate-only` input, so the step
pins the merge commit instead of a release tag. Move the pin to the first release
that ships the gate once it is published.

A skipped job counts as passing for GitHub, so merge blocking relies on an org
ruleset that requires a check named `Archive`. That ruleset is configured
separately and is not part of this repository.

When this change was created, three earlier changes (CHG-0001, CHG-0002, CHG-0003)
were still open on `main` in the accepted state, waiting for `change archive`. They
belong to other work and are left untouched; the Archive check stays red until
their owners archive them.
