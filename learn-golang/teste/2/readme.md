# Challenge 2: Investigate HTTP middleware

## Goal

This Go package contains HTTP middleware. Its implementation contains a behavioral defect. Run the supplied tests, investigate the failure, and correct the implementation without changing the package's existing interfaces or unrelated behavior.

This is a library, not an executable program. Running its tests also compiles the package.

## Task

1. From this directory, run the supplied tests before making changes:

   ```sh
   GOCACHE=/tmp/go-build go test -count=1 .
   ```

2. Identify the cause of the failing test and fix it in `route_headers.go`.
3. Run the same command again. All supplied tests must pass.

A test assertion failure is expected in the initial state. If the package does not compile or the command fails because of a tool, environment, or permission problem, stop and report the exact command and output instead of repairing the environment.

## Workspace rules

- Modify only `route_headers.go` and create `REPORT.md`.
- **Do not create new tests.** Do not modify, delete, skip, or disable the supplied tests. Do not change this README or `LICENSE`.
- Preserve existing interfaces and working behavior. Do not hardcode test inputs or outputs.
- Use only the Go standard library, the installed toolchain, and the existing parent Go module. Do not create module files, install tools, clear caches, or change Go, Zed, or sandbox settings.
- Use a fresh agent thread. Do not read other challenge folders, previous model conversations, evaluator reports, or `do_not_open`. Do not look up the original issue, fix, patch, or a ready-made solution for this challenge. General Go documentation is allowed.

## Report

Create `REPORT.md` in English. Explain the failure, its cause, and your change. Include the exact test command and its results before and after your change. List any documentation actually consulted, or state that you did not consult any. Report any checks you could not run.

## Source

This fixture is an isolated excerpt from [go-chi/chi](https://github.com/go-chi/chi); it is not the full upstream project. The supplied tests are from a later upstream revision. See `LICENSE` for attribution and terms.
