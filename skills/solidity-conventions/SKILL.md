---
name: solidity-conventions
description: Apply Solidity project conventions — Foundry only (forge, cast, anvil, chisel; no Hardhat or Truffle), forge fmt with sort_imports, solhint:all strict (--max-warnings=0 --noPoster) extending compiler-version ^0.8.22, fuzz tests via Foundry's built-in fuzzing, invariant tests via forge-std/StdInvariant.sol with handlers, gas snapshots via forge snapshot, coverage via forge coverage --report lcov, and script/Scratch.s.sol or chisel for scratch (never inline forge script heredocs). Use when starting a Solidity project, writing or reviewing Solidity contracts and tests, configuring Foundry or solhint, or evaluating compliance with these defaults. Co-activates with running-tdd-cycles, reviewing-changes, and engineering-philosophy.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(forge *), Bash(cast *), Bash(anvil *), Bash(chisel *), Bash(solhint *), Bash(yarn lint:*), Bash(npm run lint:*)
globs: "**/*.sol"
paths: "**/*.sol"
---

## Default Stack

If the repo doesn't define its own tooling, use:

- **Foundry** — build, test, scripts (`forge`, `cast`, `anvil`, `chisel`)
- **forge fmt** — formatting (`sort_imports = true`, `contract_new_lines = true`, `bracket_spacing = true`)
- **solhint** `^6.0.0` — linting, run with `--max-warnings=0 --noPoster`
- **GitHub Actions** — CI/CD, separate `build_and_test` and `linter` jobs
- **Husky** — `pre-commit` hook runs `npm run lint:check`

## Testing

- **Forge tests only** — `forge test -vvv`. No Hardhat/Truffle unless the repo already uses them.
- **Test files** — `test/**/*.t.sol`, one contract under test per file, named `<ContractOrFeature>.t.sol`.
- **Fuzz tests** — use Foundry's built-in fuzzing: parameterize test inputs (`function testFoo(uint256 x) public`) and let `forge` generate random inputs. Add `vm.assume(...)` for invariants, bound inputs with `bound(x, min, max)` rather than `if`-guards.
- **Invariant tests** — for stateful properties, use `forge-std/StdInvariant.sol` with handler contracts.
- **Gas snapshots** — `forge snapshot` for regression tracking when gas matters.
- **Coverage** — `forge coverage --report lcov` in CI.

## Linter Rules (solhint)

**Default is the strictest available.** Extend `solhint:all` (every rule enabled) and run with `--max-warnings=0` so warnings block CI.

Logic (`.solhint.json`):

```json
{
    "extends": "solhint:all",
    "rules": {
        "compiler-version": ["error", "^0.8.22"]
    }
}
```

Tests (`test/.solhint.json`) — minimum opt-outs for practical Foundry patterns:

```json
{
    "extends": "solhint:all",
    "rules": {
        "compiler-version": ["error", "^0.8.22"],
        "one-contract-per-file": "off",
        "no-console": "off",
        "func-name-mixedcase": "off",
        "reason-string": "off"
    }
}
```

Relax individual rules in-project only when you hit a real conflict — never pre-emptively.

## Scripts

Add to `package.json`:

```json
"lint:check": "yarn lint:version && yarn lint:sol-logic && yarn lint:sol-tests && forge fmt --check",
"lint:fix": "forge fmt && yarn lint:sol-tests --fix && yarn lint:sol-logic --fix",
"lint:sol-logic": "solhint -c .solhint.json 'src/**/*.sol' --max-warnings=0 --noPoster",
"lint:sol-tests": "solhint -c test/.solhint.json 'test/**/*.sol' --max-warnings=0 --noPoster",
"lint:version": "solhint --version"
```

(Swap `src/` ↔ `contracts/` to match the repo's `foundry.toml` `src =`.)

## Scratch Testing

**NEVER use inline Solidity via `forge script --via-stdin` or heredocs.**

For ad-hoc exploration:
- **Chisel** (`chisel`) — REPL for one-off expressions and cheatcode checks.
- **`script/Scratch.s.sol`** — throwaway forge script in repo root's `script/`, run with `forge script script/Scratch.s.sol`. Comment out previous blocks to keep history. Gitignored — never commit; move to a real script if the code should persist.

## Reference

- [solhint.json.example](reference/solhint.json.example) — copy-paste starter.
- [foundry.toml.example](reference/foundry.toml.example) — copy-paste starter.
