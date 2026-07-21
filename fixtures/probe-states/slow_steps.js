const { When } = require("@cucumber/cucumber");

// Tide gauges report on a fixed settling window; the reading is not trustworthy
// until the window has elapsed. The window is real wall-clock time.
// 220s (not 150s): CAPTAIN.md 2026-07-21 re-prime - the prior 150s window only
// crossed the runtime's ~120s auto-background boundary on 3/8 legs (some sweeps
// finished under it by chance). >200s forces the crossing on every leg.
const SETTLING_WINDOW_MS = 220000;

When("the tide gauges settle", { timeout: SETTLING_WINDOW_MS + 30000 }, async function () {
  await new Promise((resolve) => setTimeout(resolve, SETTLING_WINDOW_MS));
});
