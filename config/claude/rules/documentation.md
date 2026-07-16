# Code Documentation Guidelines

- Comments MUST be meaningful
- Comments MUST explain WHY NOT an alternative approach was chosen, rather than WHAT the code does
- You MUST NOT write comments that merely restate what the code does
- You MUST NOT write comments that are obvious from reading the code
- You MUST NOT write step-marker comments such as `// Arrange`, `// Act`, `// Assert`
- Instead of dividing the file contents with comments, you SHOULD consider whether it can be achieved in another way, such as dividing the code into separate files
- Test code SHOULD clearly describe WHAT is being tested
- Commit messages MUST include WHY the change was made
- All public APIs MUST have language-specific documentation
    - e.g. jsdoc for typescript

## Language Requirements

- All documentation, comments, and commit messages MUST be written in English unless specified by the user or spec

## Japanese Text

When writing Japanese text, spacing around adjacent alphanumeric characters must be controlled logically rather than by hand.

- You MUST NOT insert spaces before or after alphanumeric characters that are adjacent to Japanese characters
    - Inserting such spaces manually was long a common practice only because there had been no logical way to control the margin around alphanumeric characters within Japanese text
    - CSS Text Module Level 4 defines the `text-autospace` property, which provides a logical way to control the margin between Japanese characters and adjacent alphanumeric characters, so manual spacing is no longer warranted
