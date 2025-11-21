# Fast-Context Skill: Usage Examples

This document provides real-world examples of correct and incorrect usage of the fast-context skill.

## Example 1: Finding a Component with Missing Props

### ❌ Incorrect Usage (What NOT to Do)

**User Request:**
> "Find the UserProfile component that's missing the avatar prop"

**Wrong Agent Response:**
```
⏺ Let me search for the UserProfile component.

⏺ Search(pattern: "UserProfile", type: "tsx", head_limit: 20)
  ⎿  Found 8 files (ctrl+o to expand)

⏺ Search(pattern: "avatar.*prop", type: "tsx", head_limit: 20)
  ⎿  Found 3 files (ctrl+o to expand)
```

**Why This Is Wrong:**
- ❌ Skipped Step 1: Did not check repomix-output.xml freshness
- ❌ Skipped Step 2: Did not search repomix-output.xml
- ❌ Jumped directly to grep/search on source files (`.tsx` files)
- ❌ Violated the mandatory execution checklist

---

### ✅ Correct Usage (What TO Do)

**User Request:**
> "Find the UserProfile component that's missing the avatar prop"

**Correct Agent Response:**
```
✅ Fast-Context Execution Log:

**Step 1: Checking repomix freshness**
⏺ Bash(command: "ls -lh repomix-output.xml")
  Result: -rw-r--r--  1 user  staff   2.3M Nov 15 10:23 repomix-output.xml
  ✓ File exists and is fresh (modified today)

**Step 2: Searching repomix output (PRIMARY METHOD)**
⏺ Bash(command: "rg -n 'UserProfile|userProfile' repomix-output.xml | head -20")

  Found relevant files:
  - Line 1523: src/components/UserProfile.tsx
  - Line 2847: src/pages/ProfilePage.tsx

⏺ Bash(command: "rg -B5 -A10 'avatar' repomix-output.xml | rg -A10 'UserProfile'")

  Key finding: In ProfilePage.tsx, line 45:
  <UserProfile user={currentUser} />

  Missing: avatar prop

**Step 3 (OPTIONAL): Query knowledge graph for context**
⏺ Using mcp__kg__query_graph
  - operation: 'search_memory'
  - query: 'UserProfile component avatar prop patterns'

  Result: Found design pattern documentation showing avatar is required prop

**Step 4: Targeted source file read**
⏺ Read(file_path: "src/components/UserProfile.tsx")

  Found: Component supports `avatar` prop but it's not being passed in ProfilePage

---

✅ Findings:
Issue located! In `src/pages/ProfilePage.tsx`, the `<UserProfile>`
component is missing the `avatar` prop.

Fix: Add the avatar prop:
```tsx
<UserProfile
  user={currentUser}
  avatar={currentUser.avatarUrl}
/>
```
```

**Why This Is Correct:**
- ✅ Step 1: Checked repomix freshness first
- ✅ Step 2: Searched repomix-output.xml (PRIMARY - not source files)
- ✅ Step 3: Used KG optionally for additional design pattern context
- ✅ Step 4: Only read specific source files after narrowing down
- ✅ Documented execution log for transparency
- ✅ Followed the mandatory workflow

---

## Example 2: Understanding Module Architecture

### ❌ Incorrect Usage

**User Request:**
> "use fast context to understand the authentication module"

**Wrong Agent Response:**
```
⏺ Let me search for authentication-related files.

⏺ Glob(pattern: "**/*auth*.ts")
  Found:
  - src/auth/login.ts
  - src/auth/middleware.ts
  - lib/auth/jwt.ts

⏺ Reading all files to understand the module...
```

**Problems:**
- ❌ Used Glob on source files directly
- ❌ No repomix check
- ❌ No repomix search
- ❌ Loading multiple files inefficiently

---

### ✅ Correct Usage

**User Request:**
> "use fast context to understand the authentication module"

**Correct Agent Response:**
```
✅ Fast-Context Execution Log:

**Step 1: Checking repomix**
⏺ Bash: ls -lh repomix-output.xml
  Status: File is 3 days old, regenerating...

⏺ Bash: bunx repomix --output-show-line-numbers --include "src/**/*.ts,lib/**/*.ts"
  Generated: repomix-output.xml (1.8MB)

**Step 2: Searching repomix output (PRIMARY)**
⏺ Bash: rg -n "class.*Auth|export.*auth|authentication" repomix-output.xml | head -30

  Identified core classes:
  - AuthService (line 1234 in repomix)
  - TokenManager (line 2456)
  - AuthMiddleware (line 3678)

⏺ Bash: rg -B5 -A15 "AuthService|TokenManager|AuthMiddleware" repomix-output.xml

  Found module structure:
  - JWT token management (lib/auth/jwt.ts)
  - Login flow (src/auth/login.ts)
  - Auth middleware (src/auth/middleware.ts)
  - Session storage (src/auth/session.ts)

**Step 3 (OPTIONAL): Query knowledge graph for architectural context**
⏺ mcp__kg__query_graph
  - operation: 'search_memory'
  - query: 'authentication module architecture design patterns'

  Result: Found documentation on layered architecture pattern used

**Step 4: Reading specific files**
Based on the structure from repomix, reading the main entry point:
⏺ Read: src/auth/index.ts

---

✅ Findings:
Authentication module consists of:
1. **Core Service** (AuthService): Handles login/logout
2. **Token Management** (JWT): Issues and validates tokens
3. **Middleware** (AuthMiddleware): Protects routes
4. **Session Storage**: Manages user sessions

Architecture follows a layered pattern with clear separation of concerns.
```

---

## Example 3: Debugging a Specific Error

### ❌ Incorrect Usage

**User Request:**
> "Error: 'getUserProfile is not defined'. Use fast context to find where it's called."

**Wrong Agent Response:**
```
⏺ Searching for getUserProfile...

⏺ Grep(pattern: "getUserProfile", path: ".", output_mode: "content")
  Found 15 matches across the codebase...
```

**Problems:**
- ❌ Direct grep on source code
- ❌ No workflow steps followed

---

### ✅ Correct Usage

**User Request:**
> "Error: 'getUserProfile is not defined'. Use fast context to find where it's called."

**Correct Agent Response:**
```
✅ Fast-Context Execution Log:

**Step 1: Repomix check**
⏺ Bash: ls -lh repomix-output.xml
  Status: Fresh (1 hour old) ✓

**Step 2: Search in repomix (PRIMARY)**
⏺ Bash: rg -n "getUserProfile" repomix-output.xml

  Lines found:
  - 1234: export function getUserProfile() { ... }
  - 2456: import { getUserProfile } from '@/services/userService'
  - 3678: const profile = await getUserProfile()  // ❌ No import!

**Step 3 (OPTIONAL): Knowledge graph query for context**
⏺ mcp__kg__query_graph
  - operation: 'search_memory'
  - query: 'getUserProfile function usage patterns imports'

  Result: Function should always be imported from @/services/userService
          Common mistake: forgetting import in Vue components

**Step 4: Examine problematic file**
⏺ Read: [file at line 3678 in repomix]

  Found: src/pages/Dashboard.vue
  Issue: Missing import statement!

---

✅ Findings:
错误原因：`src/pages/Dashboard.vue` 中调用了 `getUserProfile()` 但忘记导入。

修复：添加导入语句：
```js
import { getUserProfile } from '@/services/userService'
```
```

---

## Key Takeaways

### What Makes Usage "Correct"

1. ✅ **Always follow the workflow: Check repomix → Search repomix → (Optional) Query KG**
2. ✅ **Check repomix freshness first**
3. ✅ **Search repomix-output.xml as PRIMARY method, not source files**
4. ✅ **Use KG only when you need semantic/architectural context beyond code**
5. ✅ **Document your execution log**

### Common Mistakes to Avoid

1. ❌ Jumping directly to Grep/Glob on source files
2. ❌ Treating KG query as mandatory instead of optional
3. ❌ Not checking repomix freshness
4. ❌ Searching source files before repomix
5. ❌ Not documenting which steps were completed

### Quick Decision Guide

```
Question: Should I invoke fast-context skill?

├─ Need comprehensive codebase search? → YES, use fast-context
├─ Already know exact file to read? → NO, use Read directly
├─ Want quick grep of 1-2 files? → NO, use Grep directly
└─ Exploring unfamiliar code? → YES, use fast-context
```

---

## Practice Exercise

**User Request:**
> "Find all API endpoints related to user management using fast context"

**Your Turn:** Write out the correct response following the workflow!

<details>
<summary>Click to see the answer</summary>

```
✅ Fast-Context Execution Log:

**Step 1: Check repomix**
⏺ Bash: ls -lh repomix-output.xml
  [Check if exists and is fresh]

**Step 2: Search repomix (PRIMARY)**
⏺ Bash: rg -n "router|@Get|@Post|app\.get|app\.post" repomix-output.xml | rg -i "user"

**Step 3 (OPTIONAL): Query kg if needed**
⏺ mcp__kg__query_graph
  - operation: 'search_memory'
  - query: 'user management API endpoints REST patterns'
  [Only if repomix search needs architectural context]

**Step 4: Extract findings**
[List all user management endpoints found]
```
</details>
