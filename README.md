# FolkDiscordBot

A bot to make things easier on the Folk Discord

- Uploads a message (and attachments) to the relevant wiki newsletter page.
- Reacts with ✅ once a message is saved, and skips messages it has already saved.

## Setup

```
make setup
```

Then open `.env` and fill out the environment variables

- `DISCORD_TOKEN` can be found on the "Bot" page under your application in the Discord Developer Portal. Hit the "Reset Token" button to reveal it.
  - The bot needs the "Add Reactions" and "Read Message History" permissions in the channels it watches
- `DOKUWIKI_TOKEN` is on the user profile page on the wiki
  - `remote` must be enabled in the Admin configuration
  - `remoteuser` must contain this username, or group this user belongs to
  - this user must at least have access to Upload in the newsletters namespace

## Run

```
make
```
