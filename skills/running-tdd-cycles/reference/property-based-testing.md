---
purpose: Property-based testing patterns across Python, JS/TS, Rust, Haskell, and Solidity
---

# Property-based testing

Example-based tests pin down specific input/output pairs. Property-based tests pin down *invariants* — properties that should hold for **any** input the framework can generate. They find bugs example tests miss (boundary cases, weird Unicode, large inputs, unexpected combinations).

Default to property-based for: parsers, serialisers, arithmetic, reversible transformations, sort/dedup/merge logic, idempotent operations, anything with a clear algebraic property (commutativity, associativity, identity, monotonicity).

Use example-based for: documenting a specific bug regression, demonstrating one concrete edge case, or when the property is genuinely hard to express.

## Python — Hypothesis

```python
from hypothesis import given, strategies as st

@given(xs=st.lists(st.integers()))
def test_sorted_is_idempotent(xs):
    assert sorted(sorted(xs)) == sorted(xs)

@given(xs=st.lists(st.integers()))
def test_sorted_preserves_length(xs):
    assert len(sorted(xs)) == len(xs)
```

Use `@given(...)` decorators, `strategies` for generators, `assume(...)` for invariants the framework should respect. Keep a shared `tests/strategies.py` for domain types (`valid_address`, `trade_strategy`, etc.) and import from it instead of writing inline strategies.

## JS/TS — fast-check

```ts
import fc from 'fast-check';

test('reverse is its own inverse', () => {
    fc.assert(
        fc.property(fc.array(fc.integer()), (xs) => {
            expect(xs.slice().reverse().reverse()).toEqual(xs);
        }),
    );
});
```

`fc.property(generator, predicate)` is the core. `fc.array`, `fc.integer`, `fc.string`, `fc.record({...})` for composite types. Custom shrinking via `fc.commands` for stateful tests.

## Rust — quickcheck or proptest

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn parse_then_serialize_roundtrips(s in "\\PC*") {
        let parsed = parse(&s);
        if let Ok(v) = parsed {
            prop_assert_eq!(serialize(&v), s);
        }
    }
}
```

`proptest!` macro with `in` clauses for strategies. Use `prop_assert!` / `prop_assert_eq!` so shrinking still runs.

## Haskell — QuickCheck (the original)

```haskell
prop_reverse :: [Int] -> Bool
prop_reverse xs = reverse (reverse xs) == xs

main = quickCheck prop_reverse
```

Custom generators via `Arbitrary` instance. `==>` for conditional properties.

## Solidity — Foundry built-in fuzzing

```solidity
function testTransferPreservesTotalSupply(uint256 amount) public {
    vm.assume(amount <= token.balanceOf(alice));
    uint256 totalBefore = token.totalSupply();
    vm.prank(alice);
    token.transfer(bob, amount);
    assertEq(token.totalSupply(), totalBefore);
}
```

Parametric tests with `function test...(T x, T y)` signatures auto-fuzz. `vm.assume(...)` for invariants. **Bound inputs with `bound(x, min, max)` rather than `if`-guards** — bound steers the fuzzer toward the valid range, `if`-guards waste runs. For stateful properties use `forge-std/StdInvariant.sol` with handler contracts.

## Common patterns

- **Roundtrip.** `decode(encode(x)) == x` — the most productive single property type.
- **Idempotence.** `f(f(x)) == f(x)` — sorting, normalising, deduping.
- **Invariance.** Operation preserves some quantity (total supply, length, set membership).
- **Commutativity / associativity.** `f(a, b) == f(b, a)`, `f(f(a, b), c) == f(a, f(b, c))`.
- **Monotonicity.** `a <= b → f(a) <= f(b)`.
- **Oracle.** A simpler / slower / reference implementation; `f(x) == reference_f(x)` for any `x`.

## Limits

- Properties find counterexamples; they don't prove correctness.
- A passing property test on 1000 random inputs is weaker than a passing example test on the *one* edge case you know matters — keep both.
- Shrinking helps only as much as your generators expose interesting structure; tune `min_size`/`max_size` and bias appropriately.
- Don't rely on the framework to find adversarial inputs (e.g., security-relevant strings, unicode normalisation bugs); pair with `fuzz` and explicit example tests.
