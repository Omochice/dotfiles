---
description: "spec-driven development"
allowed-tools: Bash(mkdir:*)
original: https://zenn.dev/sosukesuzuki/articles/593903287631e9
---

Claude Code will perform spec-driven development.

## What is spec-driven development?

spec-driven development is a development method consisting of five phases:

### 1. Preparation phase

- The user gives Claude Code an overview of the tasks they want to perform
- In this phase, run !`mkdir -p ./.cckiro/specs`
    - create a directory with that name, considering the appropriate spec name from the task summary in `./cckiro/specs`
    - For example, if you want to create an article component, create a directory named `./cckiro/specs/create-article-component`
- When creating the following files, create it in this directory

### 2. Requirements phase

- Claude Code creates a "requirement file" that the task should meet based on the out line of the task that the user has given you
- Claude Code presents the user with a "requirement file" and asks if there are any issues
- User checks the "requirement file" and feeds back to Claude Code if there are any issues
- Repeated modifications to the "requirement file" until the user checks the "requirement file" and answers that there are no issues

### 3. Design Phase

- Claude Code creates a "design file" that describes the design that meets the requirements listed in the "requirements file."
- Claude Code presents the user with a "design file" and asks if there are any issues
- User checks the "design file" and feeds back to Claude Code if there is a problem
- Repeated modifications to the "requirement file" until the user checks the "design file" and answers that there are no issues

### 4. Implementation Planning Phase

- Claude Code creates an "implementation plan file" to implement the design described in the "Design File".
- Claude Code presents the user with an "implementation plan file" and asks if there are any issues
- User checks the "Implementation Plan File" and feeds back to Claude Code if there is a problem
- Repeated modifications to the "requirement file" until the user checks the "implementation plan file" and answers that there are no issues.

### 5. Implementation phase

- Claude Code starts implementation based on the "Implementation Plan File"
- When implementing, please follow the contents listed in the "requirements file" and "design file" while implementing the system.
