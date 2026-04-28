---
purpose: Language-specific scratch-file patterns for ad-hoc exploration during TDD cycles
---

# Scratch testing

Ad-hoc code (one-off API calls, data exploration, "does this work at all?" checks) doesn't belong in production code or in the test suite. It belongs in a gitignored scratch file. The pattern is the same across languages: a single file at the repo root that you append to, comment out, and re-run.

## Python — `test.py`

```python
# Project root: test.py
# Comment out previous experiments; keeps history.

# === 2026-04-28 — verify queue counts ===
# import chromadb
# client = chromadb.HttpClient(host="...", port=...)
# print(client.get_collection("papers").count())

# === current ===
import requests
r = requests.get("https://api.example.com/health")
print(r.status_code, r.json())
```

Run with `uv run python test.py`. Gitignored.

**Never** use inline heredocs (`uv run python << 'EOF' ... EOF`). The file pattern is greppable, restartable, and survives session restarts.

## Go — `test.go` with `//go:build scratch`

```go
//go:build scratch

package main

import "fmt"

func main() {
    fmt.Println("scratch run")
}
```

Run with `go run -tags=scratch ./test.go`. The build tag keeps it out of the regular build.

**Never** pipe Go via `go run -` or heredocs.

## Solidity — `script/Scratch.s.sol` or `chisel`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console} from "forge-std/Script.sol";

contract Scratch is Script {
    function run() public pure {
        console.log("scratch");
    }
}
```

Run with `forge script script/Scratch.s.sol`. Or use `chisel` for one-line REPL experiments.

**Never** use `forge script --via-stdin` or heredocs.

## Why this pattern

- **Restartable.** A scratch file persists across shell sessions; a heredoc evaporates the moment you close the terminal.
- **Greppable.** When you remember "I checked this thing six weeks ago," the file is searchable; a heredoc isn't.
- **Auditable.** A reviewer can see what scratch code you ran. Heredocs are invisible to the permission layer and to your own future self.
- **Mergeable into real code.** When a scratch experiment turns into a feature, you copy the relevant block into a real module — no archaeology needed.
- **Gitignored, not committed.** The point is to keep it local. Commit only the curated, real version.
