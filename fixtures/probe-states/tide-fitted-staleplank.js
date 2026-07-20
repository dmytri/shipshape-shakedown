/**
 * @planks("I ask for the next high tide after {date}")
 */
function nextHighTide(tides, after) {
  const next = tides.find((t) => new Date(t.time) > new Date(after) && t.type === "high");
  if (!next) throw new Error("no upcoming high tide in data");
  return next;
}

module.exports = { nextHighTide };
