# Commit message Requirements

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
    - `fix`: A fix bugs faced by users
    - `perf`: A code change that improves performance
    - `refactor`: A code change that neither fixes a bug nor adds a feature
    - `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
    - `test`: Adding missing tests or correcting existing tests
- Commits MUST be decided based on how users are affected by the diff
    - For example, MUST NOT make decisions such as using `fix` because you are asked to modify the code
