---
name: go-conventions
description: Apply Go conventions — 1.25.x, vendored, golangci-lint v2, race-detector tests.
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
- **`github.com/stretchr/testify/{require,assert}`** — mandatory in every `_test.go`. Use `require` for preconditions that must abort the test (errors, setup) and `assert` for value comparisons that should keep collecting failures. No hand-written `if err != nil { t.Fatalf(...) }` / `if got != want { t.Errorf(...) }` plumbing.

  | Hand-written                                          | Replace with                                     |
  | ----------------------------------------------------- | ------------------------------------------------ |
  | `if err != nil { t.Fatalf("...: %v", err) }`          | `require.NoError(t, err)`                        |
  | `if err == nil { t.Fatal("want error") }`             | `require.Error(t, err)` / `require.ErrorIs(...)` |
  | `if got != want { t.Fatalf(...) }`                    | `require.Equal(t, want, got)`                    |
  | `if !bytes.Equal(got, want) { t.Fatalf(...) }`        | `assert.Equal(t, want, got)`                     |
  | `if got != want { t.Errorf(...) }` (continues on fail) | `assert.Equal(t, want, got)`                     |
  | `if !reflect.DeepEqual(got, want) { ... }`            | `assert.Equal(t, want, got)`                     |

  Argument order is `(t, want, got)` — expected first, actual second. Reversing it makes failure messages lie. Inside `f.Fuzz(func(t *testing.T, ...))` use `require`/`assert` on the inner `t` the same way.

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

## Protobuf Layout

When the project uses protobuf:

- `.proto` sources live in a top-level `proto/<pkg>/` directory — never co-located with Go code.
- Generated `.pb.go` lives next to its consumer at `internal/<pkg>/<protopkg>/`.
- Name `.proto` files descriptively (`certificate.proto`), not version-only (`v1.proto`) — the proto package and `go_package` option already encode the version.
- Regenerate via `make generate`. Canonical `protoc` invocation:
  ```
  protoc --go_opt=paths=source_relative \
         --go_out=internal/<pkg>/<protopkg> \
         --proto_path=proto/<protopkg> \
         proto/<protopkg>/<file>.proto
  ```
  `paths=source_relative` makes the output path predictable — the generated filename matches the input `.proto`, placed directly under `--go_out`.

## Domain / Codec Separation

Domain types do not import codec-generated symbols. Enums and structs on the domain side are Go-native and live in the same package as the business logic; conversion to and from the wire format happens at the codec boundary.

**Why.** A domain object that embeds `<pbpkg>.Result` (or any wire-format enum) cannot be encoded by anything else — adding CBOR / JSON / a schema rev forces a consumer rewrite. The same applies to `peer.ID` vs raw multihash bytes: domain holds the typed form, codec converts at I/O.

**Layout.**

```
internal/<pkg>/result.go         — domain enum (Go-native)
internal/<pkg>/codec.go          — public domain API + unexported toProtoX / fromProtoX
internal/<pkg>/<fmt>v1/          — pure protoc-gen-go output, no hand-written code
```

Conversion helpers are unexported and the only file importing the codec package is `codec.go`:

```go
// codec.go — the only file that imports certv1.
func toProtoResult(r Result) (certv1.Result, error) { /* switch */ }
func fromProtoResult(r certv1.Result) (Result, error) { /* switch */ }
```

Public APIs (`Sign(epoch, target, result Result)`) take the domain type; the codec converts on the way to the wire. Adding a second wire format later means "add `cbor_codec.go` that reuses the same domain types," not a consumer rewrite.

**Acceptance check.** `git grep -l '<pbpkg>\.' internal/` must return only `codec.go` + generated `.pb.go` files. Any other file naming `<pbpkg>.X` is a leak.

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

## Reference

- [reference/golangci.yaml.example](reference/golangci.yaml.example) — copy-paste starter for the strict golangci-lint v2 config described above.
