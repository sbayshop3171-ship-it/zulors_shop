# Zulors Shop Monorepo

This repository contains the full Zulors Shop source in one place so future updates can move through a clean GitHub-based workflow.

## Project Structure

- `Zulors Shop Admin and Web V15.7` - Laravel admin panel and web storefront
- `Zulors Shop User App` - Flutter customer app
- `Zulors Shop Vendor App` - Flutter vendor app

## Live Production Details

- Production domain: `https://shop.zulors.com`
- Web root on server: `/var/www/zulors/data/www/shop.zulors.com`
- GitHub repository: `https://github.com/sbayshop3171-ship-it/zulors_shop`
- Auto-deploy source branch: `main`

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

## Day-To-Day Update Flow

1. Make changes locally.
2. Commit them:
   `git add .`
   `git commit -m "Describe the change"`
3. Push to GitHub:
   `git push origin main`
4. Check the Actions tab for green/red status.
5. The production server auto-checks GitHub every minute and deploys the latest `main` commit when it changes.

## Production Auto-Deploy

The server uses the versioned script below:

- `scripts/zulors-auto-deploy.sh`

Installed production cron:

- `* * * * * /root/zulors-auto-deploy.sh >> /var/log/zulors-auto-deploy.log 2>&1`

Deploy behavior:

- pulls latest `main`
- syncs Laravel app source into the live web root
- preserves `.env` and uploaded files
- runs `composer install`
- runs `php artisan migrate --force`
- refreshes Laravel caches

## Rollback

Fast rollback can be done by reverting a bad commit on `main` and pushing again:

```bash
git revert <bad-commit-sha>
git push origin main
```

The server will auto-deploy the reverted state on the next check.
