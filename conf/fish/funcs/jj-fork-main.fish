# 1. create new rev from main trunk.
# 2. create new bookmark from that rev.
# 3. take the rev description as bookmark name.
# 4. use  `jj-mega-merge -t m-m -f <bookmark>` to merge it into mega merge rev.
# 5. if ollama is installed, use it to generate a commit message for the mega merge rev.
# 6. otherwise, create bookmark name by `towry/jj-<year-month-day-hour-minute>`
