---
name: sandbox-workflow
description: Create and operate isolated Docker Sandboxes for coding tasks, run OpenCode in a Nix development shell, and retrieve Git results for host review.
---

# Sandbox workflow

Use this skill when a user asks to run development work inside the local Docker Sandbox. Host-side setup and Sandbox work are separate: the coding agent has full access inside the VM, while the host retains control of review and GitHub writes.

- Create and clone with `sandbox-create NAME OWNER/REPOSITORY`. For a failed clone on an existing sandbox, inspect it before retrying with `sandbox-create --clone-only NAME OWNER/REPOSITORY`.
- When the task needs a project-managed external skill and the project provides `apm.yml` and `apm.lock.yaml`, inspect their contents and use `sandbox-restore-skills NAME` to restore and audit it before starting OpenCode. The command adds sandbox-scoped network allows for the PyPI hosts needed to build APM; it does not change the global policy. Do not run it for unrelated tasks.
- Run OpenCode in the project devShell with `sandbox-opencode NAME` (interactive) or `sandbox-opencode NAME run --model MODEL 'TASK'`. Select the model and task according to the user's request; do not assume a particular model is available. Execution may incur provider charges.
- Web search uses Exa by default; search queries are sent to Exa. Fetching pages is limited to allowed hosts, including GitHub, Nix, Rust and Playwright documentation. Report blocked destinations and do not allow arbitrary domains silently.
- The sandbox has no host workspace mount, shared agent skills, or forwarded host SSH agent. Keep those boundaries, the network deny-all policy, and GitHub's read-only token. Do not pass host GitHub credentials into it or weaken network policy to make a task work.
- Use sandbox-side `gh` for available issues and `git` to inspect branches and commits. Check work and tests before reporting. Sandbox changes are not automatically present on the host.
- For results, use `sandbox-bundle NAME BRANCH NEW_OUTPUT_DIRECTORY` to export a branch. The output directory must not already exist. Review in an isolated host clone, for example `git clone --branch BRANCH NEW_OUTPUT_DIRECTORY/result.bundle REVIEW_DIRECTORY`. Treat the bundle as private repository data; do not alter the original host checkout.
- Review in an isolated host clone. Push, PR creation, merging, secret changes, and cleanup require the authorization appropriate to the user's request; creating a sandbox alone does not authorize them. Do not delete an existing sandbox or unreviewed work as automatic cleanup.
- `sbx exec` starts a stopped sandbox. If a command, credential, or dependency fails, report the issue without exposing secrets and avoid silently changing isolation or permissions.
