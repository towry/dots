---
name: debugger
description: Systematically trace bugs backward through call stack to find original trigger
---

# When to use

- User are frustated about your attemps
- Bugs are blur and not easy to spot

# Debugging process 

- 1. Understanding the issue/bug 
- 2. Fetch a shallow context of the codebase, do not go deep 
- 3. Review what tools or subagents do you have, (fd, rg, kg, git etc)
- 4. Start debugging
  - 4.1 Get debugging idea from `outbox` subagent with ccontext and information from step 2 and step 3, it is important to tell what tool and subagents you have to the `outbox`.
  - 4.2 Follow instructions from `outbox`, trace back to the root cause of the bug/issue 
  - 4.3 Adding logs, tweak code, verify the fix 
  - 4.4 Ask user for confirm of the fix 
- 5. Re-run Step 4 until user have confirmed the bug/issue is resolved

# Real world example 

<user>
The tree city picker does nothing when I click the input 
</user>

<assitant>
I will gather the code modules related to this issue .. 

> next phase 

Ok, I have located the files, now let me check what tools and subagent might help me debugging this issue, and ask `outbox` subagent for ideas.

> next phase 

Great, I will start debugging and verify...

> next phase after code fix have been verified 

Hi, here is the root cause of this issue/bug: 

> -- omit for demo 

Please confirm it
 
</assitant>

<user>
great work!
</user>
