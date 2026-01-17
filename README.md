# yesterday

> What did I work on yesterday?

A tiny CLI for daily standups. Lists your git commits from yesterday and today, de-duplicated by message.

```
$ yesterday
f0388245  2025-01-14 16:45  Daniel Dewhurst  docs: update API reference
dab654e5  2025-01-14 15:26  Daniel Dewhurst  fix: resolve auth timeout
51483f0e  2025-01-13 14:49  Daniel Dewhurst  feat: add user preferences
```

## Installation

**curl**
```bash
curl -fsSL https://raw.githubusercontent.com/danjdewhurst/yesterday/main/yesterday | sudo tee /usr/local/bin/yesterday > /dev/null && sudo chmod +x /usr/local/bin/yesterday
```

**wget**
```bash
wget -qO- https://raw.githubusercontent.com/danjdewhurst/yesterday/main/yesterday | sudo tee /usr/local/bin/yesterday > /dev/null && sudo chmod +x /usr/local/bin/yesterday
```

**From source**
```bash
git clone https://github.com/danjdewhurst/yesterday.git
cd yesterday
sudo cp yesterday /usr/local/bin/yesterday
```

## Usage

```bash
yesterday                       # Your commits from yesterday + today
yesterday -a                    # All authors
yesterday -t                    # All time
yesterday -at                   # All authors, all time (combined flags)
yesterday --since="1 week ago"  # Custom time range
yesterday --author="john"       # Custom author filter
```

| Flag | Description |
|------|-------------|
| `-a`, `--all-authors` | Show commits from all authors |
| `-t`, `--all-time` | Remove the date filter |
| `-h`, `--help` | Show help message |

Flags are case-insensitive and can be combined (e.g., `-at`, `-TA`).

Any additional arguments are passed directly to `git log`.

## Features

- **Smart defaults** — Filters to your commits using `git config user.name`
- **De-duplication** — Same commit on multiple branches? Shows once.
- **All branches** — Searches across your entire repo
- **Consistent dates** — Uses commit date, not author date

## Platform Support

| Platform | Status |
|----------|--------|
| Linux | Native |
| macOS | Native |
| Windows | Via Git Bash or WSL |

## License

MIT
