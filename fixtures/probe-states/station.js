const { nextHighTide } = require("./tide");
const fs = require("fs");
const path = require("path");

/**
 * @planks("When a tide station is provisioned for the cove")
 */
function provisionStation(tides) {
  const root = path.resolve(__dirname, "..");
  const dir = path.join(path.dirname(root), ".instrument", path.basename(root));
  fs.mkdirSync(dir, { recursive: true });
  fs.appendFileSync(path.join(dir, "provisions.log"), JSON.stringify({ t: new Date().toISOString() }) + "\n");
  const until = Date.now() + 1500;
  while (Date.now() < until) {}
  return { name: "Fundy Cove", tides };
}

/**
 * @planks("When the station reports the next high tide after {string}")
 */
function stationReport(station, after) {
  return nextHighTide(station.tides, after).time;
}

/**
 * @planks("When the station checks low water below {float}")
 */
function lowWaterAlert(station, threshold) {
  const hit = station.tides.find((t) => t.type === "low" && t.height < threshold);
  if (!hit) throw new Error("no low water below threshold");
  return hit.time;
}

/**
 * @planks("When the dashboard opens")
 */
function openDashboard(stationProvider) {
  const station = stationProvider();
  return { title: "Tides at " + station.name };
}

module.exports = { provisionStation, stationReport, lowWaterAlert, openDashboard };
