# Zulors Shop Monorepo

This repository contains the full Zulors Shop source in one place so future updates can move through a clean GitHub-based workflow.

## Project Structure

- `Zulors Shop Admin and Web V15.7` - Laravel admin panel and web storefront
- `Zulors Shop User App` - Flutter customer app
- `Zulors Shop Vendor App` - Flutter vendor app

## Production Target

- GitHub repository: `https://github.com/sbayshop3171-ship-it/zulors_shop`
- Canonical branch: `main`
- The previous server config in this repository points to `shop.zulors.com` and `/var/www/zulors/data/www/shop.zulors.com`. Confirm the live virtual host and app root before setting production variables; Actions intentionally has no default deploy path.

## What Is Stored In Git

- Application source code
- Theme files and UI fixes
- CI workflow
- Server auto-deploy script

## What Is Not Stored In Git

- `.env` and server secrets
- Firebase mobile config files
- Laravel runtime storage uploads and cache files
- `vendor`, `node_modules`, and local build artifacts

## Push and CI

Pushes to `main` and pull requests run `.github/workflows/repository-health.yml`. CI validates the Laravel Composer setup, lints PHP, runs PHPUnit, builds Laravel Mix assets, and resolves both Flutter apps' dependencies. A successful push build on `main` stores an immutable Laravel release artifact named for its commit SHA for 90 days.

Pushing does not run a GitHub Actions deployment. The existing server setup documented for this repository lists `* * * * * /root/zulors-auto-deploy.sh >> /var/log/zulors-auto-deploy.log 2>&1`; that cron must be removed or replaced before the first push, or it can still deploy independently of GitHub Actions. The versioned deploy script now exits without an explicit manual-deploy flag, but changing this repository alone does not update a copy already installed under `/root`.

## Manual Production Deployment

Use **Actions → Manual Production Deploy → Run workflow** from `main`. The `confirm_live` checkbox defaults to false. When checked, the workflow selects the latest successful push build from `main`, downloads that run's SHA-matched artifact, verifies its checksum, deploys that exact release, and runs the configured HTTPS health check. Concurrent deployments are serialized.

The `production` GitHub environment must be configured before enabling deployment:

- Environment secrets: `PRODUCTION_HOST`, `PRODUCTION_USER`, `PRODUCTION_SSH_PRIVATE_KEY`, `PRODUCTION_KNOWN_HOSTS`
- Environment variables: `PRODUCTION_DEPLOYMENT_READY`, `PRODUCTION_APP_PATH`, `PRODUCTION_APP_OWNER`, `PRODUCTION_APP_GROUP`, `PRODUCTION_HEALTH_URL`

Set `PRODUCTION_DEPLOYMENT_READY` to `true` only after the server's old auto-deploy cron is disabled, the app root and domain have been verified for this project, `scripts/zulors-auto-deploy.sh` is installed root-owned as `/usr/local/sbin/zulors-manual-deploy`, the deploy user has `sudo -n` permission for that command, and the SSH key is authorized. The app path must point to an existing Laravel root containing `artisan`. No secrets or private keys belong in the repository.

## Release Consistency and Rollback

Each successful `main` build artifact is tied to one commit SHA. A later manual deployment selects one successful build and deploys that complete artifact, so separate pushes cannot be mixed into one release. To roll back, manually deploy an earlier successful artifact after verifying the desired SHA.
