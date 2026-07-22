const tides = require("../data/tides.json");
const stations = require("../data/stations.json");

// Tide height is the sum of harmonic constituents, each a cosine with its own
// speed, amplitude and phase. These are the constituents a standard harmonic
// analysis resolves for a station with a year of observations.
const CONSTITUENTS = [
  { name: "M2", speed: 28.9841042, amp: 2.41, phase: 12.3 },
  { name: "S2", speed: 30.0, amp: 0.68, phase: 41.7 },
  { name: "N2", speed: 28.4397295, amp: 0.52, phase: 3.9 },
  { name: "K1", speed: 15.0410686, amp: 0.44, phase: 191.2 },
  { name: "M4", speed: 57.9682084, amp: 0.21, phase: 55.2 },
  { name: "O1", speed: 13.9430356, amp: 0.31, phase: 176.8 },
  { name: "M6", speed: 86.9523127, amp: 0.11, phase: 98.4 },
  { name: "MK3", speed: 44.0251729, amp: 0.05, phase: 71.6 },
  { name: "S4", speed: 60.0, amp: 0.03, phase: 88.1 },
  { name: "MN4", speed: 57.4238337, amp: 0.08, phase: 47.9 },
  { name: "NU2", speed: 28.5125831, amp: 0.1, phase: 5.2 },
  { name: "S6", speed: 90.0, amp: 0.02, phase: 121.4 },
  { name: "MU2", speed: 27.9682084, amp: 0.07, phase: 359.1 },
  { name: "2N2", speed: 27.8953548, amp: 0.07, phase: 355.4 },
  { name: "OO1", speed: 16.1391017, amp: 0.02, phase: 204.7 },
  { name: "LAM2", speed: 29.4556253, amp: 0.02, phase: 18.6 },
  { name: "S1", speed: 15.0, amp: 0.02, phase: 190.0 },
  { name: "M1", speed: 14.4966939, amp: 0.02, phase: 184.3 },
  { name: "J1", speed: 15.5854433, amp: 0.03, phase: 198.1 },
  { name: "MM", speed: 0.5443747, amp: 0.03, phase: 0.0 },
  { name: "SSA", speed: 0.0821373, amp: 0.04, phase: 0.0 },
  { name: "SA", speed: 0.0410686, amp: 0.06, phase: 0.0 },
  { name: "MSF", speed: 1.0158958, amp: 0.02, phase: 0.0 },
  { name: "MF", speed: 1.0980331, amp: 0.02, phase: 0.0 },
  { name: "RHO", speed: 13.4715145, amp: 0.01, phase: 170.2 },
  { name: "Q1", speed: 13.3986609, amp: 0.06, phase: 163.5 },
  { name: "T2", speed: 29.9589333, amp: 0.04, phase: 40.9 },
  { name: "R2", speed: 30.0410667, amp: 0.01, phase: 42.5 },
  { name: "2Q1", speed: 12.8542862, amp: 0.01, phase: 150.3 },
  { name: "P1", speed: 14.9589314, amp: 0.14, phase: 189.4 },
  { name: "2SM2", speed: 31.0158958, amp: 0.01, phase: 60.2 },
  { name: "M3", speed: 43.4761563, amp: 0.01, phase: 33.8 },
  { name: "L2", speed: 29.5284789, amp: 0.07, phase: 20.4 },
  { name: "2MK3", speed: 42.9271398, amp: 0.03, phase: 66.1 },
  { name: "K2", speed: 30.0821373, amp: 0.19, phase: 39.1 },
  { name: "M8", speed: 115.9364169, amp: 0.01, phase: 140.7 },
  { name: "MS4", speed: 58.9841042, amp: 0.05, phase: 62.3 },
];

const DEG = Math.PI / 180;

function heightAt(hoursFromEpoch, station) {
  const offset = station ? station.phaseOffset : 0;
  const scale = station ? station.amplitudeScale : 1;
  let h = 0;
  for (let i = 0; i < CONSTITUENTS.length; i++) {
    const c = CONSTITUENTS[i];
    h += scale * c.amp * Math.cos((c.speed * hoursFromEpoch - c.phase - offset) * DEG);
  }
  return h;
}

// Published tide tables give times to the minute, so the search runs to the
// minute: a coarser sweep reports a turning point the model does not predict,
// and a finer one reports precision the table does not carry.
const STEP_SECONDS = 60;

// A turning point is a sample whose neighbours are both lower (high water) or
// both higher (low water). The constituents beat against each other, so the
// envelope has no closed form and the year is walked.
function annualTable(year, station) {
  const start = Date.UTC(year, 0, 1) / 1000;
  const end = Date.UTC(year + 1, 0, 1) / 1000;
  const steps = Math.floor((end - start) / STEP_SECONDS);
  const table = [];
  let prev = heightAt((start - STEP_SECONDS) / 3600, station);
  let cur = heightAt(start / 3600, station);
  for (let i = 1; i <= steps; i++) {
    const next = heightAt((start + i * STEP_SECONDS) / 3600, station);
    if (cur > prev && cur > next) {
      table.push({ time: new Date((start + (i - 1) * STEP_SECONDS) * 1000).toISOString().replace(".000", ""), type: "high", height: cur });
    } else if (cur < prev && cur < next) {
      table.push({ time: new Date((start + (i - 1) * STEP_SECONDS) * 1000).toISOString().replace(".000", ""), type: "low", height: cur });
    }
    prev = cur;
    cur = next;
  }
  return table;
}

// The fixed table is the observed record; the harmonic model is the prediction.
// Scenarios that name a table entry read the table they were given.
/**
 * @planks("I ask for the next high tide after {string}")
 */
function nextHighTide(table, after) {
  const next = (table || tides).find(
    (t) => new Date(t.time) > new Date(after) && t.type === "high"
  );
  if (!next) throw new Error("no upcoming high tide in data");
  return next;
}

// Every station the service publishes gets a table for the year. Each station has
// its own phase offset and amplitude scale from its own harmonic analysis, so no
// station's table can be derived from another's.
/**
 * @planks("I generate the annual tide tables for every station in {int}")
 */
function allStationTables(year) {
  const out = {};
  for (const station of stations) {
    out[station.id] = annualTable(year, station);
  }
  return out;
}

module.exports = { nextHighTide, allStationTables, heightAt, stations };
