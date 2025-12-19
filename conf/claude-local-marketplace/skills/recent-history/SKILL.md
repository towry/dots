---
name: "recent-history"
description: "This skill should be used when retrieving recent chat history, in case you are lost the context of what the user are talking about"
---

## Steps to retrieving the context of recent chat history

## Step 1: Prepare the history file

This command should run in current project root dir.

```bash
bunx repomix --header-text "file path parent dir: .claude/sessions/" --quiet --no-dot-ignore --no-gitignore --no-git-sort-by-changes --no-file-summary --no-directory-structure .claude/sessions/ -o .claude/sessions/history.xml >/dev/null 2>&1 && echo "history exist" || echo "no history file"
```

If the command output is "no history file", just quit, because there are no session history to look up. Otherwise, please go to step 2.

## Step 2: Query history (sessions are ordered old→new in the file)

### Quick Overview: List all sessions with line numbers

```bash
# List all session titles with line numbers (shows where each session starts)
rg -n '<file path="' .claude/sessions/history.xml | head -20

# Cleaner output: line number + filename only
rg -no '<file path="[^"]+' .claude/sessions/history.xml | sed 's/<file path="/  /'

# List all session titles (no line numbers)
rg -o '<file path="[^"]+' .claude/sessions/history.xml | sed 's/<file path="//'
```

### Get Recent Sessions (recommended for "what have we done")

```bash
# Get last 3 session titles with line numbers
rg -no '<file path="[^"]+' .claude/sessions/history.xml | tail -3

# Get last N lines of history (recent content, adjust N as needed)
tail -500 .claude/sessions/history.xml

# Get content of last session only
tac .claude/sessions/history.xml | sed -n '1,/<file path=/p' | tac
```

### Extract Specific Line Range (after finding line numbers)

```bash
# Extract lines 1500-1800 from history file
sed -n '1500,1800p' .claude/sessions/history.xml

# Extract from line 1500 to end
sed -n '1500,$p' .claude/sessions/history.xml

# Extract 100 lines starting from line 1500
sed -n '1500,1600p' .claude/sessions/history.xml
```

### Keyword Search in Recent History (with line numbers and context)

```bash
# Search keyword in last 1000 lines with line numbers and 3 lines context
tail -1000 .claude/sessions/history.xml | rg -n -C 3 "keyword"

# Search with more context (5 lines before/after)
tail -1000 .claude/sessions/history.xml | rg -n -C 5 "keyword"

# Case-insensitive search with context
tail -1000 .claude/sessions/history.xml | rg -n -i -C 3 "keyword"

# Show only 2 lines after match (useful for user/agent messages)
tail -1000 .claude/sessions/history.xml | rg -n -A 2 "keyword"
```

### Full File Keyword Search (with line numbers and context)

```bash
# Basic keyword search with line numbers
rg -n "keyword" .claude/sessions/history.xml

# With context lines (3 before/after) and line numbers
rg -n -C 3 "keyword" .claude/sessions/history.xml

# Case-insensitive with context
rg -n -i -C 3 "keyword" .claude/sessions/history.xml

# Search multiple keywords (OR) with line numbers
rg -n -e "keyword1" -e "keyword2" .claude/sessions/history.xml

# Search with both keywords (AND) with line numbers
rg -n "keyword1" .claude/sessions/history.xml | rg "keyword2"

# Show only matching parts with line numbers (useful for long lines)
rg -n -o ".{0,50}keyword.{0,50}" .claude/sessions/history.xml

# Count matches per file
rg -c "keyword" .claude/sessions/history.xml

# Search with regex pattern and line numbers
rg -n "error|warning|failed" .claude/sessions/history.xml

# Show 5 lines after each match (good for reading full responses)
rg -n -A 5 "keyword" .claude/sessions/history.xml

# Show 2 lines before and 5 after
rg -n -B 2 -A 5 "keyword" .claude/sessions/history.xml
```

### Extract Specific Session by Date/Topic

```bash
# Get current date in session filename format (YYYYMMDD)
date +%Y%m%d

# Find today's sessions
rg -A 100 "<file path=\"$(date +%Y%m%d)" .claude/sessions/history.xml

# Find session by specific date pattern (e.g., 20251212)
rg -A 100 '<file path="20251212' .claude/sessions/history.xml | head -150

# Find sessions from this week
date +%Y%m%d  # Today
date -v-1d +%Y%m%d  # Yesterday (macOS)
date -d "yesterday" +%Y%m%d  # Yesterday (Linux)

# Find session by topic keyword in filename
rg -o '<file path="[^"]*litellm[^"]*' .claude/sessions/history.xml
```

## Recommended Workflow

1. **"What have we done?"** → Use `tail -500` or list recent session titles with line numbers
2. **"Find specific topic"** → Use keyword search with `rg -n -C 3`
3. **"Continue previous work"** → Search for keywords in recent history (`tail -1000 | rg -n -C 3`)
4. **"Extract full session"** → Get line numbers, then use `sed -n 'START,ENDp'`

## Practical Example: Complete Workflow

```bash
# Step 1: Find where "litellm" was discussed (with line numbers)
rg -n -C 2 "litellm" .claude/sessions/history.xml | head -20
# Output: 162:<file path="20251212-215454-session-nixhmlitellm...
#         165:@nix/hm/litellm/ we have a litellm running well...

# Step 2: Get all session boundaries with line numbers
rg -no '<file path="[^"]+' .claude/sessions/history.xml | tail -5
# Output: 5175:<file path="20251219-101237-summary.txt
#         5179:<file path="20251219-104149-session...
#         5245:<file path="20251219-104733-session...
#         5334:<file path="20251219-112255-session...

# Step 3: Extract specific session (lines 5245-5333)
sed -n '5245,5333p' .claude/sessions/history.xml

# Step 4: Search within that extracted session
sed -n '5245,5333p' .claude/sessions/history.xml | rg -n -C 2 "keyword"
```
