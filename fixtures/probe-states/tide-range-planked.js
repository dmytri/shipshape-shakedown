/**
 * @planks("I ask for the next high tide after {string}")
 */
function nextHighTide(tides, after) {
  const next = tides.find((t) => new Date(t.time) > new Date(after) && t.type === "high");
  if (!next) throw new Error("no upcoming high tide in data");
  return next;
}

/**
 * @planks("I ask for the tide range on {string}")
 */
function tideRange(tides, day) {
  const heights = tides.filter((t) => t.time.startsWith(day)).map((t) => t.height);
  return Math.round((Math.max(...heights) - Math.min(...heights)) * 10) / 10;
}

module.exports = { nextHighTide, tideRange };
