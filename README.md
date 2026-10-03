# FolkDiscordBot

A bot to make things easier on the Folk Discord

- Uploads a message (and attachments) to the relevant wiki newsletter page.

## Setup

```
make setup
```

Then open `.env` and fill out the environment variables

- `DISCORD_TOKEN` can be found on the "Bot" page under your application in the Discord Developer Portal. Hit the "Reset Token" button to reveal it.
- `DOKUWIKI_TOKEN` is on the user profile page on the wiki
  - `remote` must be enabled in the Admin configuration
  - `remoteuser` must contain this username, or group this user belongs to
  - this user must at least have access to Upload in the newsletters namespace

## Run

```
make
```
