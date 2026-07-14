# Oracle harness fixes (operator-side only; roles never see this directory)

Applied to the pinned tastejs/todomvc clone (ff43b02e59dfa604386bb382034b2cd07c2bcd8a)
AFTER cloning, BEFORE the first grading run:

    git -C <oracle-clone> apply /home/exedev/shipshape-shakedown/fixtures/oracle/spy-reset.patch

## spy-reset.patch — why this is legal and does not weaken the bar

`checkItemSaved()` in cypress/e2e/spec.cy.js calls `spy.invoke('reset')` on a
`cy.spy()` of `localStorage.setItem`. Sinon removed `spy.reset()` in sinon 5
(2018); modern Cypress bundles modern sinon where only `resetHistory()` exists.

The bug is unreachable for every framework upstream maintains: the
`noLocalStorageSpyCheck` map (which spreads `noLocalStorageCheck`) contains the
ENTIRE modern "main set" (angular, preact, react, react-redux, svelte, vue —
in-memory apps that persist nothing) and all the legacy apps the tests/README
lists as passing. Those apps `return` before the spy line. Only a NEW framework
name that genuinely persists to localStorage — exactly what app-spec.md requires
— executes it, and then fails with "property `reset` does not exist on your
subject" AFTER `.should('have.been.called')` has already PASSED. The oracle was
failing the pilot app for correctly implementing persistence, on a code path no
reference app exercises and upstream CI never runs.

Evidence chain (2026-07-14, pilot #2 attempt 2): 3 residual failures held
byte-identical across 3 grading runs; two QM iterations found no production
defect; error text shows the called-assertion passing and the invoke failing;
map contents verified in the pinned spec source. Fix validated by re-grading
the same unmodified app before/after the one-line patch (see METRICS.md).

The patch changes NO assertion. `resetHistory()` is the same-semantics rename
of `reset()`: clear call history between assertions so the NEXT
`checkItemSaved()` is meaningful. If anything it makes grading STRICTER —
with the broken call, tests died early instead of running their later spy
assertions. Grades stay comparable with prior pilots.

Do NOT add pilot framework names to `noLocalStorageSpyCheck`/`knownIssues.js`
to route around failures — that weakens the bar. Harness-internal API repairs
with this level of evidence are the only sanctioned oracle edit, and each one
needs its own patch file + rationale here.
