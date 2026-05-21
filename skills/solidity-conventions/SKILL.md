---
name: solidity-conventions
description: Apply Solidity conventions — Foundry only, forge fmt, solhint:all, fuzz tests.
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

## Events and Logging

Events are the on-chain logging primitive; they are public and permanent. Treat them as part of the contract's external API.

- **Emit for every state-changing externally-callable function.** Name in past tense (`Transferred`, `RegistryUpdated`, `EpochAnchored`), not present tense (`Transfer`, `UpdateRegistry`).
- **Indexed parameters for filterable keys.** Whatever a downstream indexer or wallet will filter on (operator address, token id, registry id, parameter id) goes in an `indexed` slot. The cap is three indexed slots per event.
- **Emit after store**, not before. State mutation first, `emit` second. Reversed ordering invites reentrancy / race confusion and breaks downstream consumers that expect the event payload to reflect post-mutation state.
- **Do not emit raw blobs already public on chain** (raw quote bytes, PCK certificates, full snapshots, big calldata copies). Off-chain consumers can recover them from indexed state cheaper than via log data; emitting bloats every indexer's storage and creates a free data-exfiltration surface.
- **Do not emit values downstream code would have to re-derive.** Emit the derived value (the id, not the keccak inputs).
- **`console2.log` is test-only.** It must not appear in production contracts; it inflates bytecode and is dead code in prod. Keep it gated to `test/` files; lint or grep for it in `src/`.
- **Event signature changes are ABI changes.** Update the relevant spec docs (governance-parameters.md, node-registry.md, etc.) in the same commit as the contract; indexer consumers read the spec, not the ABI.

## NatSpec

- **`@inheritdoc` on impl with a matching interface entry.** When a public state variable, function, or modifier in the implementation matches an interface signature, use `/// @inheritdoc IThing` rather than restating the `@notice` / `@dev` prose inline. The interface is the single source of truth; duplicating the prose in the impl invites drift (one side gets updated, the other does not) and reviewers flag it as "documentation inconsistency". This is the convention in OpenZeppelin, Aave, Compound, and Uniswap.
- **`@notice` directly** when there is no interface counterpart: constants, internal helpers, modifiers without an interface, custom errors. `@inheritdoc` cannot resolve, so write the prose inline.
- **Document `@param` / `@return` once**: in the interface for public-surface functions; in the impl for internal helpers.
- **No `@author` on every file.** Once at the project / module level if at all; per-file noise.

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
