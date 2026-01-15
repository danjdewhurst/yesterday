# yesterday

List your git commits from yesterday (and today), de-duplicated by message.

## Installation

```bash
# One-liner install
curl -fsSL https://raw.githubusercontent.com/dd-avrillo/yesterday/main/yesterday | sudo tee /usr/local/bin/yesterday > /dev/null && sudo chmod +x /usr/local/bin/yesterday

# Or with wget
wget -qO- https://raw.githubusercontent.com/dd-avrillo/yesterday/main/yesterday | sudo tee /usr/local/bin/yesterday > /dev/null && sudo chmod +x /usr/local/bin/yesterday
```

### From source

```bash
git clone https://github.com/dd-avrillo/yesterday.git
cd yesterday
sudo cp yesterday /usr/local/bin/yesterday
```

## Usage

```bash
# Your commits from yesterday + today (default)
yesterday

# All authors
yesterday -a
yesterday --all-authors

# All time (no date filter)
yesterday -t
yesterday --all-time

# Combine flags
yesterday -a -t

# Custom filters (passed to git log)
yesterday --since="1 week ago"
yesterday --author="john"
```

## Output

```
f0388245  2026-01-14 16:45  Daniel Dewhurst       docs: updates to AML tasks
dab654e5  2026-01-14 15:26  Daniel Dewhurst       docs: tidy up AML tasks
51483f0e  2026-01-14 14:49  Daniel Dewhurst       feat: add new feature
```

## Features

- Filters to your commits by default (uses `git config user.name`)
- Shows commits from yesterday onwards by default
- De-duplicates by commit message (useful when commits exist on multiple branches)
- Searches all branches (`--all`)
- Uses commit date (not author date) for consistent filtering

## License

MIT
