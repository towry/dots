Saves the current session messages to disk without ending the session.

This command allows you to persist your conversation progress while continuing to work. Unlike `/handoff`, this command:
- Does NOT generate a summary
- Does NOT end the session
- Can be run multiple times without duplicating messages
- Useful for checkpointing long sessions

The session is saved to `.claude/sessions/<timestamp>-session-<title>-ID_<session_id>.md` in the same format as the automatic session save on exit.
