# Hytale Authentication Refresh Workflow

This GitHub Action automatically refreshes Hytale authentication tokens every 30 minutes and allows for initial authentication setup via manual workflow dispatch.

## Features

- **Automatic Refresh**: Runs every 30 minutes to keep authentication tokens fresh
- **Interactive Initial Setup**: Manually trigger with your Hytale access token
- **Secure Storage**: Automatically updates GitHub secrets with refreshed tokens
- **Container Rebuild**: Optionally rebuilds the hytale-auth container after authentication

## Initial Setup

### Prerequisites

1. **Personal Access Token (PAT)**: Create a GitHub PAT with `repo` and `secrets` permissions
   - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with these scopes:
     - `repo` (Full control of private repositories)
     - `admin:repo_hook` (Full control of repository hooks)
   - Add this token as a repository secret named `PAT_TOKEN`

2. **Hytale Access Token**: Obtain your Hytale access token from the Hytale developer portal

### First Run

1. Navigate to **Actions** tab in your repository
2. Select **Hytale Auth Token Refresh** workflow
3. Click **Run workflow**
4. Fill in the required inputs:
   - **Hytale Access Token**: Your Hytale access token (required for first run)
   - **Hytale Refresh Token**: Optional, if you have one
   - **Force rebuild**: Check this to rebuild the container immediately
5. Click **Run workflow**

The workflow will:
- Validate your authentication credentials
- Store them securely in GitHub secrets (`HYTALE_ACCESS_TOKEN` and `HYTALE_REFRESH_TOKEN`)
- Optionally trigger a rebuild of the hytale-auth container
- Begin automatic 30-minute refresh cycles

## Automatic Operation

After initial setup, the workflow will:
- Run automatically every 30 minutes
- Use the stored tokens from GitHub secrets
- Refresh the tokens if needed
- Update the secrets with new token values
- Ensure your Hytale authentication stays valid

## Manual Refresh

You can manually trigger a refresh at any time:
1. Go to **Actions** → **Hytale Auth Token Refresh**
2. Click **Run workflow**
3. Leave inputs empty to use stored tokens, or provide new tokens to update
4. Check **Force rebuild** if you want to rebuild the container

## Troubleshooting

### Authentication Failed

If you see "Authentication failed!" in the workflow logs:
1. Verify your Hytale access token is still valid
2. Manually run the workflow with a new access token
3. Check that the `HYTALE_ACCESS_TOKEN` secret exists in your repository

### Secrets Not Updating

If secrets aren't being updated:
1. Ensure you have created the `PAT_TOKEN` secret with proper permissions
2. Verify the PAT has `repo` and `admin:repo_hook` scopes
3. Check the workflow logs for detailed error messages

### Container Not Rebuilding

If the container isn't rebuilding when expected:
1. Make sure `force_rebuild` is checked when running manually
2. Verify the `hytale-auth.yml` workflow exists
3. Check that `PAT_TOKEN` has permissions to trigger workflows

## Architecture

The workflow consists of these steps:

1. **Setup Authentication**: Determines whether to use manual input or stored secrets
2. **Refresh Token**: Downloads hytale-downloader and validates/refreshes credentials
3. **Update Secrets**: Encrypts and updates GitHub repository secrets with new tokens
4. **Rebuild Container**: Optionally triggers the hytale-auth container build
5. **Summary**: Provides a summary of the operation

## Security Notes

- Tokens are stored as encrypted GitHub repository secrets
- Temporary credential files are deleted after use
- The workflow uses libsodium for secure secret encryption
- Only users with repository write access can trigger the workflow manually

## Schedule

The workflow runs on this schedule:
- **Frequency**: Every 30 minutes
- **Cron Expression**: `*/30 * * * *`
- **Time Zone**: UTC

## Related Workflows

- [`hytale-auth.yml`](.github/workflows/hytale-auth.yml) - Builds the hytale-auth container
- This workflow can trigger that workflow when needed
