# Container Images

This document covers building, tagging, and publishing Apptainer container images from this repository.

## Local build output

Each agent folder builds its own `.sif` image locally. For example:

```bash
cd copilot-cli
./build_copilot.sh
```

This produces:

```text
copilot-cli/copilot-cli.sif
```

The same pattern is used for the other agent folders.

## Publishing to GitHub Container Registry

Apptainer can push `.sif` images to OCI registries such as GitHub Container Registry using an `oras://` target.

Example:

```bash
apptainer push copilot-cli.sif oras://ghcr.io/robot144/copilot-cli:latest
```

Published image reference:

```text
ghcr.io/robot144/copilot-cli:latest
```

To download the image again:

```bash
apptainer pull copilot-cli.sif oras://ghcr.io/robot144/copilot-cli:latest
```

## Authentication

Before pushing to GHCR, log in with Apptainer:

```bash
apptainer registry login --username YOUR_GITHUB_USERNAME docker://ghcr.io
```

For GHCR, the password is typically a GitHub personal access token rather than your normal GitHub account password.

### Required token scopes

At minimum, the token should have:

- `write:packages`

Often useful as well:

- `read:packages`
- `delete:packages` if you want to remove images later

If you are working with private repositories or organization policies that require broader access, you may also need:

- `repo`

If you push to an organization namespace and the organization requires SSO, you may also need to authorize the token for that organization after creating it.

## Using the helper script

There is a generic helper script in the repository root:

```bash
./push_image.sh ./copilot-cli/copilot-cli.sif oras://ghcr.io/robot144/copilot-cli:latest
```

There is also a `copilot-cli` wrapper with Copilot-specific defaults:

```bash
cd copilot-cli
./push_copilot_image.sh
```

By default it expects:

- image: `copilot-cli/copilot-cli.sif`
- target built from:
  - `GHCR_NAMESPACE`
  - `GHCR_IMAGE_NAME` defaulting to `copilot-cli`
  - `GHCR_TAG` defaulting to `latest`

Example:

```bash
GHCR_NAMESPACE=robot144 ./push_copilot_image.sh
```

You can also pass both the image path and an explicit target:

```bash
./push_image.sh ./copilot-cli/copilot-cli.sif oras://ghcr.io/robot144/copilot-cli:latest
```

## Multiple images

Yes, you can publish multiple container images under the same GitHub account or organization namespace. A common pattern is:

```text
ghcr.io/robot144/copilot-cli:latest
ghcr.io/robot144/codex-cli:latest
ghcr.io/robot144/claude-cli:latest
```

Container image names in GHCR do not have to map one-to-one to Git repositories. Package association with a repository is handled separately by GitHub.

## Notes on URI schemes

With Apptainer, the login and push commands use different URI schemes:

```bash
apptainer registry login --username YOUR_GITHUB_USERNAME docker://ghcr.io
apptainer push copilot-cli.sif oras://ghcr.io/robot144/copilot-cli:latest
```

That difference is expected.

## Common failure

If you see an error like:

```text
DENIED: permission_denied: The token provided does not match expected scopes.
```

that usually means authentication worked, but the token is missing required package scopes such as `write:packages`.
