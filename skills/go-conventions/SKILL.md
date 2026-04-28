---
name: go-conventions
description: Apply Go project conventions — Go 1.25.x toolchain pinned via toolchain directive and GOTOOLCHAIN=local, vendored deps via go mod vendor, golangci-lint v2 strict (~50 enabled linters), gofmt + goimports, gosec + semgrep + govulncheck + CodeQL static analysis, race-detector + fuzz-capable testing, reproducible-build flags (-trimpath, -buildid=) for TEE-attested binaries, cmd/ + internal/ + pkg/ layout, stdlib-first dependencies (log/slog, net/http, google/uuid, google.golang.org/protobuf). Use when starting a Go project, writing or reviewing Go code, configuring Go tooling, doing TEE-attested or reproducible builds, or evaluating compliance with these defaults. Co-activates with running-tdd-cycles, reviewing-changes, and engineering-philosophy.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(go *), Bash(golangci-lint *), Bash(gofmt *), Bash(goimports *), Bash(gosec *), Bash(govulncheck *), Bash(semgrep *), Bash(make *)
globs: "**/*.go"
paths: "**/*.go"
---

## Default Stack

If the repo doesn't define its own tooling, use:

- **Go** — latest stable minor (`1.25.x` floor). Pin with `toolchain go1.25.X` in `go.mod`, set `GOTOOLCHAIN=local` in CI so the declared toolchain is used verbatim.
- **`go mod vendor`** — vendor deps committed to repo. Enables reproducible + airgapped builds; CI runs `go build -mod=vendor`.
- **GitHub Actions** — CI/CD. Pin every action by commit SHA, not tag.
- **golangci-lint v2** — linting. Strict preset (see below). Run via `golangci-lint run -c .golangci.yml`.
- **gofmt + goimports** — formatting. `goimports` is enabled as a `formatter` in `.golangci.yml`.
- **gosec** — security static analysis. Runs in CI (SARIF upload to GitHub code scanning).
- **semgrep** — additional SAST with `r/default r/go r/dgryski r/trailofbits` rulesets.
- **govulncheck** — official Go vulnerability database scan. Preferred over Nancy (no external account).
- **CodeQL** — GitHub's SAST for Go.
- **modernize** — `golang.org/x/tools/gopls/internal/analysis/modernize/cmd/modernize` checks for outdated idioms.

## Build Discipline

- **CGo policy.** Default `CGO_ENABLED=0` for pure-Go packages. Enable only when a specific package needs it; tag those files with `//go:build cgo` so pure-Go builds still work.
- **Build tags for runtime variants.** Use explicit tags (e.g. `//go:build tdx`, `//go:build sevsnp`) when the same binary has multiple platform-specific implementations. Exactly one implementation per build.
- **Reproducible builds.** Default build flags:
  ```
  go build -trimpath -buildvcs=false -ldflags "-s -w -buildid=" ./...
  ```
  `-trimpath` strips local paths; `-buildid=` zeros the linker build ID. For any binary whose hash is measured (TEE attestation), a `build-reproducible` Make target must build twice and diff `sha256sum`.
- **`go mod tidy`** — run in CI; fail if it produces a diff.

## Linter Rules (golangci-lint v2)

**Default is the strictest reasonable preset.** Config (`.golangci.yml`):

- `linters.default: none` — enable explicitly, no surprises from upstream additions
- Enabled (~50): `asasalint asciicheck bidichk bodyclose copyloopvar cyclop dupl durationcheck errcheck errname errorlint exhaustive forbidigo funlen gocheckcompilerdirectives gochecknoglobals gochecknoinits gocognit goconst gocritic gocyclo godot gomoddirectives gomodguard goprintffuncname gosec govet ineffassign lll loggercheck makezero mirror mnd musttag nakedret nestif nilerr nilnil noctx nolintlint nonamedreturns nosprintfhostport predeclared promlinter reassign revive rowserrcheck sqlclosecheck staticcheck testableexamples testpackage tparallel unconvert unparam unused usestdlibvars usetesting wastedassign whitespace sloglint`
- `formatters.enable: [goimports]`
- `settings.cyclop.max-complexity: 30`, `settings.funlen.lines: 100`, `settings.gocognit.min-complexity: 20`, `settings.lll.line-length: 140`
- `settings.govet.enable-all: true`, `govet.settings.shadow.strict: true`, disable `fieldalignment`
- `settings.errcheck.check-type-assertions: true`
- `settings.exhaustive.check: [switch, map]`
- `settings.nolintlint.require-explanation: true`, `require-specific: true`
- `settings.gomodguard.blocked.modules` — at minimum block `github.com/golang/protobuf` (use `google.golang.org/protobuf`), `github.com/satori/go.uuid` + `github.com/gofrs/uuid` (use `github.com/google/uuid`)
- Test-file exclusions: `bodyclose dupl funlen goconst gosec noctx wrapcheck` disabled in `_test.go`
- Relax per-file only after hitting a real conflict — never preemptively

Warnings block CI. No `//nolint` without a rule-specific target and an explanation comment.

## Testing

- **`go test ./... -race -covermode=atomic -coverprofile=coverage.out`** — race detector mandatory. Fail on uncovered races.
- **Table-driven tests** — default pattern for unit tests.
- **Test files** — `*_test.go` next to the code. External test packages (`package foo_test`) for black-box tests; `testpackage` linter enforces this where applicable.
- **Integration tests** — gate behind build tags (`//go:build integration`), run in separate CI step.
- **Fuzz** — `go test -fuzz=Fuzz...` for parsers and security-relevant decoders. Commit seed corpus under `testdata/fuzz/`.
- **Benchmarks** — `go test -bench=. -benchmem` when performance matters; capture baseline with `benchstat`.
- **Coverage floor** — project-defined, enforced in CI (`go tool cover -func=coverage.out`).

## Scratch Testing

**ALWAYS use a `test.go` file with `//go:build scratch` tag** in project root for ad-hoc exploration:

```go
//go:build scratch

package main

func main() {
    // ...
}
```

Run with `go run -tags=scratch ./test.go`. Comment out previous code to keep history. **Gitignored** — never commit; move to a real package if the code should persist.

**NEVER use inline Go via `go run -` or heredocs.**

## Project Layout

Follow the standard layout:

- `cmd/<binary>/main.go` — entrypoints, thin `main` only
- `internal/` — private packages, not importable by other modules
- `pkg/` — exported packages (only if actually consumed externally; otherwise keep in `internal/`)
- `testdata/` — test fixtures (never compiled)
- `vendor/` — committed, regenerated by `go mod vendor`

`main` functions delegate to a testable `Run(ctx, args, stdout, stderr) int` in a sibling package.

## Dependencies

- **Prefer stdlib.** `log/slog` not `logrus`; `net/http` not `gin` unless routing complexity justifies it.
- **`google.golang.org/protobuf`** not `github.com/golang/protobuf` (enforced by `gomodguard`).
- **`github.com/google/uuid`** not `satori`/`gofrs` (enforced).
- **Dependabot** — enable for `gomod`, `github-actions`, `docker`; daily schedule.

## Makefile Targets

Canonical targets every Go project should expose:

```
vendor               go mod vendor
tidy                 go mod tidy && git diff --exit-code go.mod go.sum
fmt                  goimports -w $(SOURCE_DIRS)
fmt-check            gofmt -l -s $(SOURCE_DIRS) | tee /dev/stderr | ifne false
lint                 go vet ./... && golangci-lint run -c .golangci.yml
modernize            go run golang.org/x/tools/gopls/internal/analysis/modernize/cmd/modernize@latest ./...
test                 go test -race -covermode=atomic -coverprofile=coverage.out ./...
build                go build -trimpath -ldflags "-s -w -buildid=" -o build/<name> ./cmd/<name>
build-reproducible   build twice, diff sha256sum, fail on mismatch
vuln                 govulncheck ./...
all                  vendor tidy fmt-check lint test build
```
