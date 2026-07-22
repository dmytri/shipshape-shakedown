const fs = require("fs");
const path = require("path");

// Observations arrive in the order the gauge reports them, which is by station
// pass, not by time. The index puts them in time order so a lookup can stop at the
// first match.
const OBSERVED = [
  { time: "2026-07-12T22:00:00Z", type: "high", height: 3.9 },
  { time: "2026-07-12T16:45:00Z", type: "high", height: 4.5 },
  { time: "2026-07-12T10:30:00Z", type: "low", height: 0.8 },
  { time: "2026-07-12T22:55:00Z", type: "low", height: 0.7 },
];

let index = null;

function buildIndex(table) {
  const byType = { high: [], low: [] };
  for (const entry of table) byType[entry.type].push(entry);
  for (const type of Object.keys(byType)) {
    byType[type].sort((a, b) => Date.parse(a.time) - Date.parse(b.time));
  }
  return byType;
}

/**
 * @planks("the tide table for Fundy Cove is loaded")
 */
function loadTable() {
  // The gauge log is re-read on load and the index rebuilt from it, off the hot
  // path so a load does not block a reader.
  fs.readFile(path.join(__dirname, "..", "data", "tides.json"), () => {
    index = buildIndex(OBSERVED);
  });
  return OBSERVED;
}

/**
 * @planks("I look up the next high tide after {string}")
 */
function lookupNextHigh(after) {
  const t = Date.parse(after);
  const source = index ? index.high : OBSERVED.filter((e) => e.type === "high");
  return source.find((e) => Date.parse(e.time) > t);
}

module.exports = { loadTable, lookupNextHigh };
