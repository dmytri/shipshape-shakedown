const assert = require("assert");
const { Given, When, Then } = require("@cucumber/cucumber");
const tide = require("../../src/tide.js");

Given("the tide service is published", function () {
  assert.ok(Array.isArray(tide.stations) && tide.stations.length > 0, "no published stations");
  this.stations = tide.stations;
});

When("I generate the annual tide tables for every station in {int}", { timeout: 600000 }, function (year) {
  this.tables = tide.allStationTables(year);
});

Then("every published station has a table", function () {
  for (const station of this.stations) {
    const table = this.tables[station.id];
    assert.ok(table, `no table for ${station.id}`);
    // Two high waters and two low waters a day, near enough, over a year.
    assert.ok(table.length > 1200, `${station.id} table has only ${table.length} entries`);
  }
});

Then("each table alternates high and low water", function () {
  for (const station of this.stations) {
    const table = this.tables[station.id];
    for (let i = 1; i < table.length; i++) {
      assert.notStrictEqual(
        table[i].type,
        table[i - 1].type,
        `${station.id} repeats ${table[i].type} at ${table[i].time}`
      );
      assert.ok(
        Date.parse(table[i].time) > Date.parse(table[i - 1].time),
        `${station.id} table is not in time order at ${table[i].time}`
      );
    }
  }
});

Then("the stations do not share a single first high water", function () {
  const firsts = new Set(
    this.stations.map((s) => this.tables[s.id].find((e) => e.type === "high").time)
  );
  assert.ok(firsts.size > 1, "every station reported the same first high water");
});
