---
applyTo: '**'
---

# docs about jj

- revset doc: https://jj-vcs.github.io/jj/latest/revsets/
- template lang doc: https://jj-vcs.github.io/jj/latest/templates/
- jj command doc: https://jj-vcs.github.io/jj/latest/cli-reference/


# Working with jj bash scripts

scripts is maintained in the `./conf/bash/scripts/` directory, please
implement all the utils function in `jj-util.sh` file.

# Apply necessary arguments when run jj command

- Apply `--ignore-working-copy` to avoid jj check current head changes, improve perf.
- Apply `--no-graph` to avoid jj print graph, improve output text parse.
- Apply `--no-pager` to avoid jj use pager, which is suitable in non-interactive environment.

# Shell compatibility lessons learned

## Interactive detection in cross-shell environments

1. **Avoid bash-specific variables**: Don't use `$-` variable for interactive detection as it's bash-specific and doesn't work in fish shell
2. **Use multiple fallback checks**: Implement layered detection:
   - Primary: Terminal file descriptors (`-t 0` and `-t 1`)
   - Secondary: Direct `/dev/tty` access (`-r /dev/tty` and `-w /dev/tty`)
   - Tertiary: Environment variables (`$PS1`, `$TERM_PROGRAM`, `$TERM`)

## User interaction patterns

1. **Prefer simple numbered menus over complex tools**: Use `read` with numbered options instead of fzf for better reliability
2. **Avoid complex I/O redirection**: fzf with `/dev/tty` redirection can be unreliable in subshells and pipelines
3. **Use array-based selection**: Store options in arrays for reliable access after user selection
4. **Implement input validation**: Always validate numeric input and provide clear error messages

## Best practices for utility functions

1. **Single responsibility**: Each function should handle one specific task
2. **Consistent error handling**: Use stderr for errors, return proper exit codes
3. **Input validation**: Check for empty inputs and validate data formats
4. **Graceful fallbacks**: Provide non-interactive alternatives when possible
5. **Clear user feedback**: Show what options are available and guide user selection

## Template and output parsing

1. **Use consistent output formats**: Design templates that produce predictable, parseable output
2. **Filter output reliably**: Use grep with specific patterns to avoid false matches
3. **Handle edge cases**: Check for empty results, malformed data, and unexpected formats
4. **Prefer structured data**: Use tab-separated or other structured formats for easier parsing
