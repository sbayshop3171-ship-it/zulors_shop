#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/sbayshop3171-ship-it/zulors_shop.git"
BRANCH="main"
REPO_CACHE_DIR="/root/zulors-deploy-cache/zulors_shop"
APP_SOURCE_SUBDIR="Zulors Shop Admin and Web V15.7"
LIVE_APP_DIR="/var/www/zulors/data/www/shop.zulors.com"
LAST_DEPLOY_FILE="/root/zulors-deploy-cache/zulors_shop.last_deployed"
APP_OWNER="zulors"
APP_GROUP="zulors"

mkdir -p "$(dirname "$REPO_CACHE_DIR")"

if [ ! -d "$REPO_CACHE_DIR/.git" ]; then
  git clone --branch "$BRANCH" --depth 1 "$REPO_URL" "$REPO_CACHE_DIR"
else
  git -C "$REPO_CACHE_DIR" fetch origin "$BRANCH" --depth 1
  git -C "$REPO_CACHE_DIR" reset --hard "origin/$BRANCH"
  git -C "$REPO_CACHE_DIR" clean -fd
fi

CURRENT_SHA="$(git -C "$REPO_CACHE_DIR" rev-parse HEAD)"
if [ -f "$LAST_DEPLOY_FILE" ] && [ "$(cat "$LAST_DEPLOY_FILE")" = "$CURRENT_SHA" ]; then
  exit 0
fi

SOURCE_DIR="$REPO_CACHE_DIR/$APP_SOURCE_SUBDIR"
if [ ! -f "$SOURCE_DIR/artisan" ]; then
  echo "Laravel source directory not found: $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$LIVE_APP_DIR"

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
  "$SOURCE_DIR/" "$LIVE_APP_DIR/"

cd "$LIVE_APP_DIR"

composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction
php artisan migrate --force
php artisan optimize:clear
php artisan config:cache
php artisan view:cache
php artisan storage:link || true

chown -R "$APP_OWNER:$APP_GROUP" storage bootstrap/cache

echo "$CURRENT_SHA" > "$LAST_DEPLOY_FILE"
