# GitHub Pages setup (one-time, manual)

> Status: **blocked on user action** — required for the `docs` workflow's `deploy` job.

## Symptom

`docs.yml` `deploy` job fails with:

```
##[error]Creating Pages deployment failed
##[error]HttpError: Not Found
##[error]Error: Failed to create deployment (status: 404) ...
##[error]Ensure GitHub Pages has been enabled:
##[error]https://github.com/carcheky/dashboarrcheky/settings/pages
```

The `build` job succeeds — `mkdocs build --strict` produces the artifact fine.
Only the deployment step fails because **GitHub Pages has never been enabled**
on this repository (`GET /repos/.../pages` returns 404).

## Why it's blocked from automation

GitHub does **not** expose an API to enable Pages for the first time. The
PUT endpoint (`PUT /repos/{owner}/{repo}/pages`) returns 404 until the
site has been created via the web UI. So this is a one-time manual click.

## How to fix (owner-only, ~30 seconds)

1. Open <https://github.com/carcheky/dashboarrcheky/settings/pages>.
2. Under **Source**, choose **Deploy from a branch**.
3. Branch: `beta` (or `master` — whatever you want to serve from). The
   workflow pushes to `gh-pages` automatically after this is enabled.
   Directory: `/` (root).
4. Click **Save**.
5. Re-trigger the workflow once (push to `beta` or **Run workflow** from
   the Actions tab). The `deploy` job will now succeed.

After the first deploy, the site lives at
<https://carcheky.github.io/dashboarrcheky/> and `llms.txt` /
`llms-full.txt` are reachable at `/llms.txt` and `/llms-full.txt`.

## Verification

After enabling and re-running:

```bash
gh run list --repo carcheky/dashboarrcheky --workflow docs --limit 1 \
  --json conclusion,displayTitle
# conclusion should be "success"

curl -fsS https://carcheky.github.io/dashboarrcheky/llms.txt | head -10
# should print the sectioned index
```

## Related

- `.github/workflows/docs.yml` — the workflow that deploys
- `docs/adr/0003-docs-strategy.md` — why `llms.txt` exists
- `docs/index.md` — links to the deployed site