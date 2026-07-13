const { When } = require("@cucumber/cucumber");

// Tide gauges report on a fixed settling window; the reading is not trustworthy
// until the window has elapsed. The window is real wall-clock time.
const SETTLING_WINDOW_MS = 150000;

When("the tide gauges settle", { timeout: SETTLING_WINDOW_MS + 30000 }, async function () {
  await new Promise((resolve) => setTimeout(resolve, SETTLING_WINDOW_MS));
});
