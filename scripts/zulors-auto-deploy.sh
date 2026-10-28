#!/usr/bin/env bash

set -euo pipefail

# Safe by default: an existing cron invocation without arguments cannot deploy.
if [[ "$#" -eq 0 ]]; then
  echo "Automatic deployment is disabled. Use the gated GitHub Actions workflow."
  exit 0
fi

if [[ "$#" -ne 6 ]]; then
  echo "Usage: zulors-manual-deploy <commit-sha> <release-archive> <sha256> <app-path> <app-owner> <app-group>" >&2
  exit 2
fi

DEPLOY_SHA="$1"
DEPLOY_ARTIFACT="$2"
DEPLOY_ARCHIVE_SHA256="$3"
LIVE_APP_DIR="$4"
APP_OWNER="$5"
APP_GROUP="$6"

if [[ ! "$DEPLOY_SHA" =~ ^[0-9a-f]{40}$ ]]; then
  echo "Invalid deployment commit SHA." >&2
  exit 1
fi
if [[ ! "$DEPLOY_ARCHIVE_SHA256" =~ ^[0-9a-f]{64}$ ]]; then
  echo "Invalid release checksum." >&2
  exit 1
fi
if [[ ! "$DEPLOY_ARTIFACT" =~ ^/tmp/zulors-release-[0-9a-f]{40}\.tar\.gz$ ]]; then
  echo "Invalid release artifact path." >&2
  exit 1
fi
if [[ "$LIVE_APP_DIR" != /* || "$LIVE_APP_DIR" == "/" || "$LIVE_APP_DIR" == *[[:space:]]* ]]; then
  echo "LIVE_APP_DIR must be an absolute project path without whitespace." >&2
  exit 1
fi
if [[ "$LIVE_APP_DIR" == *"/../"* || "$LIVE_APP_DIR" == */.. || "$LIVE_APP_DIR" == *"/./"* || "$LIVE_APP_DIR" == */. || "$LIVE_APP_DIR" == *"//"* ]]; then
  echo "LIVE_APP_DIR must be a normalized absolute path." >&2
  exit 1
fi
if [[ ! "$APP_OWNER" =~ ^[A-Za-z0-9._-]+$ || ! "$APP_GROUP" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "Invalid app owner or group." >&2
  exit 1
fi
if [[ ! -f "$DEPLOY_ARTIFACT" ]]; then
  echo "Release artifact is missing from the server." >&2
  exit 1
fi
if [[ ! -f "$LIVE_APP_DIR/artisan" ]]; then
  echo "The configured deployment path is not an existing Laravel app root." >&2
  exit 1
fi

mkdir -p /run/lock
LOCK_KEY="$(printf '%s' "$LIVE_APP_DIR" | sha256sum | cut -c1-16)"
exec 9>"/run/lock/zulors-manual-deploy-${LOCK_KEY}.lock"
flock -n 9 || { echo "A deployment is already running for this app path." >&2; exit 1; }

printf '%s  %s\n' "$DEPLOY_ARCHIVE_SHA256" "$DEPLOY_ARTIFACT" | sha256sum --check --status

TEMP_DIR="$(mktemp -d "/tmp/zulors-release-${DEPLOY_SHA}.XXXXXX")"
trap 'rm -rf "$TEMP_DIR"; rm -f "$DEPLOY_ARTIFACT"' EXIT
mkdir -p "$TEMP_DIR/source"

if tar -tzf "$DEPLOY_ARTIFACT" | grep -E '(^/|(^|/)\.\.(/|$))' >/dev/null; then
  echo "Release archive contains an unsafe path." >&2
  exit 1
fi
tar -xzf "$DEPLOY_ARTIFACT" -C "$TEMP_DIR/source"
if [[ ! -f "$TEMP_DIR/source/artisan" ]]; then
  echo "Release archive does not contain the Laravel application root." >&2
  exit 1
fi

export COMPOSER_ALLOW_SUPERUSER=1
rsync -a --delete --chown="$APP_OWNER:$APP_GROUP" \
  --exclude=".git/" \
  --exclude=".env" \
  --exclude="vendor/" \
  --exclude="node_modules/" \
  --exclude="storage/app/" \
  --exclude="storage/framework/cache/" \
  --exclude="storage/framework/sessions/" \
  --exclude="storage/framework/views/" \
  --exclude="storage/logs/" \
  --exclude="public/storage/" \
  "$TEMP_DIR/source/" "$LIVE_APP_DIR/"

cd "$LIVE_APP_DIR"
composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction
php artisan migrate --force
php artisan optimize:clear
php artisan config:cache
php artisan view:cache
if [[ ! -L public/storage ]]; then
  php artisan storage:link || true
fi

chown -R "$APP_OWNER:$APP_GROUP" storage bootstrap/cache
printf '%s\n' "$DEPLOY_SHA" > .deployment-sha
chown "$APP_OWNER:$APP_GROUP" .deployment-sha
echo "Deployed ${DEPLOY_SHA} to the configured Laravel app path."
