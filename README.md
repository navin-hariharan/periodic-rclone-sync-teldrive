# Rclone Cron Docker

A Docker-based scheduled runner for [Rclone](https://rclone.org/). Configure an Rclone operation, source, destination, options, and schedule using environment variables.

## Features

- Runs Rclone on a configurable schedule.
- Streams Rclone output to the container logs.
- Configures the operation using environment variables.
- Supports persistent Rclone configuration through a mounted volume.
- Runs in Docker, making it suitable for Docker Compose and container platforms.

## Quick start

### 1. Create the files

Keep these files in the same directory:

```text
.
├── Dockerfile
├── entrypoint.sh
├── compose.yaml
├── README.md
└── LICENSE
```

### 2. Configure Rclone

Place your `rclone.conf` file in `./config/`. The Compose example mounts this directory at `/config/rclone`.

Make sure your configured remotes and credentials are available to Rclone. Mount the local source directory into the container at the path used by `SOURCE`.

### 3. Configure Docker Compose

Example `compose.yaml`:

```yaml
services:
  rclone-cron:
    build: .
    container_name: rclone-cron
    restart: unless-stopped
    environment:
      MODE: "copy"
      SOURCE: "/media_drive"
      TARGET: "teldrive:test-data"
      OPTIONS: "--transfers 4 --checkers 8"
      CRON: "0 2 * * *"
      TZ: "Asia/Kolkata"
    volumes:
      - ./config:/config/rclone:ro
      - /path/to/media_drive:/media_drive:ro
```

Replace `/path/to/media_drive` with the actual host directory. Adjust the config mount if your Rclone configuration is stored elsewhere.

### 4. Build and start

```bash
docker compose up -d --build
```

Follow container output:

```bash
docker compose logs -f rclone-cron
```

Rclone's output should be written to standard output/error so it is visible in Docker logs.

## Environment variables

| Variable | Required | Description | Example |
|---|---:|---|---|
| `MODE` | Yes | Rclone operation, such as `copy` or `sync` | `copy` |
| `SOURCE` | Yes | Source path or remote | `/media_drive` |
| `TARGET` | Yes | Destination path or remote | `teldrive:test-data` |
| `OPTIONS` | No | Additional Rclone command-line flags | `--transfers 4 --checkers 8` |
| `CRON` | No | Schedule in five-field cron format, if supported by the scheduler implementation | `0 2 * * *` |
| `TZ` | No | Container timezone used to interpret the schedule | `Asia/Kolkata` |

### Schedule examples

Standard five-field cron examples:

| Schedule | Meaning |
|---|---|
| `* * * * *` | Every minute |
| `0 2 * * *` | Daily at 2:00 AM |
| `0 4 * * 0` | Sundays at 4:00 AM |
| `*/30 * * * *` | Every 30 minutes |
| `0 1 * * 1-5` | Weekdays at 1:00 AM |

**Important:** These examples describe standard cron syntax. Confirm that the scheduler implementation in your `entrypoint.sh` supports the expression you choose. A simple custom loop may support only a subset of cron syntax; use a real cron daemon or a cron-expression parser for full support.

## `copy` versus `sync`

- `copy` copies new and changed files without deleting destination-only files.
- `sync` makes the destination match the source and can delete files from the destination.

Use `sync` only when that deletion behavior is intended. Consider testing against a temporary destination first.

## Logging and troubleshooting

View logs:

```bash
docker compose logs -f rclone-cron
```

Check container status:

```bash
docker compose ps
```

If no Rclone output appears:

1. Check that the container is running.
2. Verify `CRON`, `MODE`, `SOURCE`, and `TARGET`.
3. Confirm the source directory is mounted and readable.
4. Confirm `rclone.conf` contains the named remote and is readable.
5. Check the schedule and timezone.
6. Ensure the entrypoint forwards Rclone output to stdout/stderr.

## Security notes

- Do not commit `rclone.conf`, access tokens, passwords, or other credentials.
- Prefer read-only mounts where appropriate.
- Use `copy` rather than `sync` if destination-only files must be preserved.
- The `OPTIONS` variable is passed as command-line arguments by the entrypoint; only set it to trusted values.
- Review installation scripts before executing them during a Docker build.

## License and credit

This project is available for use, modification, and redistribution under the terms in [`LICENSE`](LICENSE).

Credit: **navin_hariharan**.
