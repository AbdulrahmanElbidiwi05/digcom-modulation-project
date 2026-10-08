#!/usr/bin/env bash
# Usage: ./setup_github.sh <repo-name> <teammate1-github-user> <teammate2-github-user>
# Requires: git, GitHub CLI (gh) logged in:  gh auth login
set -euo pipefail
REPO="${1:-digcom-modulation-project}"
git init -b main
git add .
git commit -m "Initial skeleton: shared conventions, BPSK reference, stubs"
gh repo create "$REPO" --private --source=. --remote=origin --push
for u in "${@:2}"; do
  gh api -X PUT "repos/$(gh api user -q .login)/$REPO/collaborators/$u" -f permission=push
done
# Starter branches, one per member
for b in m1/bpsk-qpsk m2/8psk-16qam m3/bfsk; do
  git branch "$b" && git push -u origin "$b"
done
echo "Done. Teammates must accept the email invitation."
