---
name: northwind-pr
description: Write a pull request description for the current branch in the Northwind team's required format — ticket-prefixed title, what changed, how it was verified, acceptance criteria, and what was deliberately not done. Use when the user asks to write, draft, or fill in a PR description, or invokes /northwind-pr.
---

# /northwind-pr

Write the pull request description for the work on this branch, in the team format below. The output is a title and a description. Writing it does not open, push, or update anything.

## 1. Read before writing

Gather these before you draft a word. If one cannot be found, say so to the user instead of filling the gap from memory.

1. **The diff.** `git diff main...HEAD --stat`, then `git diff main...HEAD` for the files that matter. Also run `git status --short`: uncommitted changes are not in the PR, so do not describe them as if they were.
2. **The log.** `git log main..HEAD --oneline`. This gives the sequence of the work and, usually, the ticket ID.
3. **The ticket.** Take the ID from the branch name or the commit subjects (for example `NWP-101`), then read `docs/tickets/<ID>.md`. Copy its acceptance criteria verbatim. If there is no ticket ID, or no matching file, stop and ask the user which ticket this is.

If `main` is not the base branch for this work, ask which branch it is before diffing.

## 2. Collect the verification evidence

Verification comes from this session, not from the diff. Before writing that section, list what was actually run and what it printed:

- Commands run in this conversation, with their output. Quote the summary line exactly, for example `Tests  35 passed (35)`.
- Things the user says they did and saw, such as a click-through in the browser. Attribute them to the user.

A test file in the diff is evidence that a test exists. It is not evidence that it passed. If nothing was run, offer to run the checks now (for example `npm test`) and use their real output. Do not write that a check ran when it did not.

## 3. Check each acceptance criterion

For every criterion in the ticket, find the code that meets it, and the evidence that shows it works:

- **Met:** the code exists and a step from section 2 shows it working. Tick it.
- **Partial:** part of it is built, or it is built but not verified. Leave it unticked and say which part is missing.
- **Not met:** nothing in the diff does it. Leave it unticked and say so.

Never tick a criterion because the work was intended to meet it.

## 4. Write the description

Title:

```
<TICKET-ID>: <what it does>
```

`<what it does>` is a short, lower-case summary of the behavior, for example `NWP-101: add export options`.

Body, in this order:

```markdown
## What changed

One plain-language paragraph: what someone can do now that they could not before. Not a list of files; the diff already is one.

## How I verified it

The commands that were run and what they output, with the summary lines quoted. What was clicked and what appeared, if anyone did. Anything not checked is stated as not checked.

## Acceptance criteria

- [x] <criterion, verbatim from the ticket>
- [ ] <criterion> — partial: <what is built, what is missing or unverified>

## Deliberately not done

- <out-of-scope item, or one left for a follow-up, and why>
```

If nothing was deliberately left out, write "Nothing." rather than leaving the heading empty.

## 5. Hand it over

Print the title and the description. If the user wants the PR opened or updated, that is a separate step and it needs their go-ahead first.

## Rules

- **Never claim a verification step that was not run.** If it did not happen in this session, or the user did not tell you they did it, it does not go under "How I verified it". Leave it out or state that it was not checked.
- **Quote, don't summarize, test output.** Use real counts, not "tests pass".
- **Honest over complete.** A partial criterion reported as partial is correct. A partial criterion ticked is wrong.
- **Only describe what is in the branch.** Uncommitted or unpushed work is not part of the PR.
- **Plain language.** Write "Ops can now choose which columns to export", not "implemented column selection functionality".
- **Leave unknowns blank or marked as unknown.** Do not guess to fill a section.
