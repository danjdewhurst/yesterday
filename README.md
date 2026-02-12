<div align="center">

# yesterday

**What did I work on yesterday?**

A tiny, zero-dependency bash CLI for daily standups.\
Lists your git commits from yesterday and today, de-duplicated by message.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-4.0%2B-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows%20(WSL)-blue)]()
[![GitHub last commit](https://img.shields.io/github/last-commit/danjdewhurst/yesterday)](https://github.com/danjdewhurst/yesterday/commits/main)
[![GitHub stars](https://img.shields.io/github/stars/danjdewhurst/yesterday?style=flat)](https://github.com/danjdewhurst/yesterday/stargazers)

---

```
$ yesterday
f0388245  2025-01-14 16:45  Daniel Dewhurst  docs: update API reference
dab654e5  2025-01-14 15:26  Daniel Dewhurst  fix: resolve auth timeout
51483f0e  2025-01-13 14:49  Daniel Dewhurst  feat: add user preferences
```

[Installation](#installation) · [Usage](#usage) · [AI Summaries](#ai-summarization) · [Multi-repo](#multi-repo-scanning) · [Testing](#testing)

</div>

## Features

- **Smart defaults** — Filters to your commits using `git config user.name`
- **Workday-aware** — On Mondays, shows Friday's commits instead of Sunday's
- **De-duplication** — Same commit on multiple branches? Shows once
- **All branches** — Searches across your entire repo
- **Consistent dates** — Uses commit date, not author date
- **Multi-repo scanning** — Scan all repos in a directory with `-d`
- **AI summaries** — Get plain-English standup summaries with `--ai`

## Installation

**curl** (recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/danjdewhurst/yesterday/main/yesterday \
  | sudo tee /usr/local/bin/yesterday > /dev/null && sudo chmod +x /usr/local/bin/yesterday
```

<details>
<summary><strong>Other methods</strong></summary>

**wget**
```bash
wget -qO- https://raw.githubusercontent.com/danjdewhurst/yesterday/main/yesterday \
  | sudo tee /usr/local/bin/yesterday > /dev/null && sudo chmod +x /usr/local/bin/yesterday
```

**From source**
```bash
git clone https://github.com/danjdewhurst/yesterday.git
cd yesterday
sudo cp yesterday /usr/local/bin/yesterday
```

</details>

## Usage

```bash
yesterday                       # Your commits from yesterday + today
yesterday -a                    # All authors
yesterday -t                    # All time
yesterday -l                    # Literal yesterday (disable Monday → Friday)
yesterday -d ~/Projects         # Scan all repos in a directory
yesterday -at                   # All authors, all time (combined flags)
yesterday --ai                  # Your commits with AI summary
yesterday -ai                   # All authors with AI summary
yesterday --since="1 week ago"  # Custom time range
yesterday --author="john"       # Custom author filter
```

| Flag | Description |
|------|-------------|
| `-a`, `--all-authors` | Show commits from all authors |
| `-t`, `--all-time` | Remove the date filter |
| `-l`, `--literal` | Use literal yesterday (disable workday logic) |
| `-d`, `--directory DIR` | Scan all git repos in DIR |
| `-i`, `--ai` | Summarize commits with AI (configure with `--setup`) |
| `--setup` | Configure AI provider and API keys |
| `-h`, `--help` | Show help message |

> Flags are case-insensitive and can be combined (e.g., `-at`, `-ai`, `-atd ~/Projects`).\
> Any additional arguments are passed directly to `git log`.

### Multi-repo scanning

Use `-d` to scan all git repos in a directory at once — perfect for standup prep when your work spans multiple repos:

```
$ yesterday -d ~/Projects
[yesterday]  f0388245  2025-01-14 16:45  Daniel Dewhurst  docs: update API reference
[my-api]     dab654e5  2025-01-14 15:26  Daniel Dewhurst  fix: resolve auth timeout
```

If the path is itself a git repo, it runs in single-repo mode on that repo.

### AI Summarization

Add `--ai` (or `-i`) to get a plain-English summary of your commits, powered by an LLM:

```
$ yesterday --ai
f0388245  2025-01-14 16:45  Daniel Dewhurst  docs: update API reference
dab654e5  2025-01-14 15:26  Daniel Dewhurst  fix: resolve auth timeout
51483f0e  2025-01-13 14:49  Daniel Dewhurst  feat: add user preferences

AI Summary (openai/gpt-4o-mini):
- Updated the API documentation
- Fixed a login timeout issue
- Added a way for users to save their preferences
```

Run `yesterday --setup` to choose your provider and enter your API key. Configuration is stored in `~/.config/yesterday/config` (permissions `600`).

**Supported providers:**

| Provider | Default model | Requirements |
|----------|--------------|--------------|
| OpenAI | `gpt-4o-mini` | API key |
| Claude (Anthropic) | `claude-sonnet-4-20250514` | API key |
| Gemini (Google) | `gemini-2.0-flash` | API key |
| Ollama | `llama3.2` | Local Ollama install |

> Requires `curl` and either `jq` or `python3` for JSON handling.\
> Combined flags work naturally — `yesterday -ai` shows all authors' commits with an AI summary.

## Testing

Tests use [BATS](https://github.com/bats-core/bats-core) (Bash Automated Testing System), included as git submodules.

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/danjdewhurst/yesterday.git

# Or init submodules in an existing clone
git submodule update --init --recursive

# Run all tests
./test/libs/bats-core/bin/bats test/

# Run a single test file
./test/libs/bats-core/bin/bats test/flag_parsing.bats
```

## Platform Support

| Platform | Status |
|----------|--------|
| Linux | Native |
| macOS | Native |
| Windows | Via Git Bash or WSL |

## License

[MIT](https://opensource.org/licenses/MIT)
