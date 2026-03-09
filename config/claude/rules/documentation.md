# Code Documentation Guidelines

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
