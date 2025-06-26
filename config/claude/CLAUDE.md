# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code.

The request level is defined in the following sentence:

```txt
Network Working Group                                         S. Bradner
Request for Comments: 2119                            Harvard University
BCP: 14                                                       March 1997
Category: Best Current Practice


        Key words for use in RFCs to Indicate Requirement Levels

Status of this Memo

   This document specifies an Internet Best Current Practices for the
   Internet Community, and requests discussion and suggestions for
   improvements.  Distribution of this memo is unlimited.

Abstract

   In many standards track documents several words are used to signify
   the requirements in the specification.  These words are often
   capitalized.  This document defines these words as they should be
   interpreted in IETF documents.  Authors who follow these guidelines
   should incorporate this phrase near the beginning of their document:

      The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
      NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and
      "OPTIONAL" in this document are to be interpreted as described in
      RFC 2119.

   Note that the force of these words is modified by the requirement
   level of the document in which they are used.

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

## Language Requirements

- All documentation, comments, and commit messages MUST be written in English

## Commit message Requirements

- DO NOT staging without specifying a file, such as `git add .`
- Commit message MUST be the below format:

    ```txt
    <type>[optional scope]: <description>

    [optional body]

    [optional footer(s)]
    ```

- Commit type MUST be one of follows:
    - `build`: Changes that affect the build system or external dependencies
    - `ci`: Changes to our CI configuration files and scripts
    - `docs`: Documentation only changes
    - `feat`: A new feature
    - `fix`: A bug fix
    - `perf`: A code change that improves performance
    - `refactor`: A code change that neither fixes a bug nor adds a feature
    - `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
    - `test`: Adding missing tests or correcting existing tests
