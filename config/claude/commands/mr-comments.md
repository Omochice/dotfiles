---
allowed_tools: Bash(glab:*)
description: Get comments from a GitLab merge request
---

Please analyze and fix the GitLab Merge Request.

Follow these steps:

1. Fetch the MR number from the branch you are currently in

    ```sh
    glab mr list --source-branch="$(git branch --show-current)"
    ```

2. Understand the problem described in the issue

    ```sh
    glab mr view {iid}
    ```

3. Collect comments on MRs

    ```sh
    glab api /projects/:id/merge_requests/{iid}/notes | jq '[.[] | select(.system == false)]'
    ```

4. Triage comments based on whether or not they need to be addressed
5. Receive input from the user and respond based on the above information
