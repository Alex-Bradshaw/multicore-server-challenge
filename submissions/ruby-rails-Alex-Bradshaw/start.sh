#!/usr/bin/env bash
# Runs Puma in the foreground. Configured only by DATABASE_URL, JWT_SECRET, HOST and PORT (SPEC.md runtime contract).
set -euo pipefail
cd "$(dirname "$0")"
# On the benchmark box (and in CI) Ruby comes from install.sh in /opt/ruby; locally, whatever Ruby is on PATH.
if [ -x /opt/ruby/bin/ruby ]; then export PATH="/opt/ruby/bin:$PATH"; fi
export BUNDLE_PATH=vendor/bundle BUNDLE_WITHOUT=development:test
export RAILS_ENV=production
# Production Rails refuses to boot without a secret_key_base. The API has no sessions or cookies,
# so nothing is signed with it and a fixed value is fine.
export SECRET_KEY_BASE=not-used-this-api-has-no-sessions
exec bundle exec puma -C config/puma.rb
