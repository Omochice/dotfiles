# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code.

The request level is defined in the following sentence:

```txt
1. MUST   This word, or the terms "REQUIRED" or "SHALL", mean that the
   definition is an absolute requirement of the specification.

2. MUST NOT   This phrase, or the phrase "SHALL NOT", mean that the
   definition is an absolute prohibition of the specification.

3. SHOULD   This word, or the adjective "RECOMMENDED", mean that there
   may exist valid reasons in particular circumstances to ignore a
   particular item, but the full implications must be understood and
   carefully weighed before choosing a different course.

4. SHOULD NOT   This phrase, or the phrase "NOT RECOMMENDED" mean that
   there may exist valid reasons in particular circumstances when the
   particular behavior is acceptable or even useful, but the full
   implications should be understood and the case carefully weighed
   before implementing any behavior described with this label.
```

The original version is [rfc2119](https://www.ietf.org/rfc/rfc2119.txt).

## Code Documentation Guidelines

- Comments SHOULD explain WHY NOT an alternative approach was chosen, rather than WHAT the code does
- Test code SHOULD clearly describe WHAT is being tested
- Commit messages MUST include WHY the change was made
- All public APIs MUST have language-specific documentation
    - e.g. jsdoc for typescript
- Comments MUST be meanfull
    - comments that are obvious when looking at the code
    - Don't write comments that explain steps like `// Arrange`, `// Act`, `// Assert`
    - Instead of dividing the file contents with comments, you SHOULD consider whether it can be achieved in another way, such as dividing the code into separate files

## Language Requirements

- All documentation, comments, and commit messages MUST be written in English unless specified by the user or spec

## Commit message Requirements

- Commits MUST be divided into the smallest meaningful units
- DO NOT staging without specifying a file, such as `git add .`
- DO NOT use `git commit --amend` for adding existed commit, Use `git commit --fixup`
- Commit message MUST be the below format:

    ```txt
    <type>[optional scope]: <description>

    [optional body]

    [optional footer(s)]
    ```

- Commit type MUST be one of follows:
    - `build`: Changes that affect the build system
    - `ci`: Changes to our CI configuration files and scripts
    - `chore`: Changes tool configuration or external dependencies
    - `docs`: Documentation only changes
    - `feat`: A new feature
    - `fix`: A bug fix
    - `perf`: A code change that improves performance
    - `refactor`: A code change that neither fixes a bug nor adds a feature
    - `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
    - `test`: Adding missing tests or correcting existing tests
- Commits MUST be decided based on how users are affected by the diff
    - For example, MUST NOT make decisions such as using `fix` because you are asked to modify the code
