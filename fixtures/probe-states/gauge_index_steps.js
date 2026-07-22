const assert = require("assert");
const { Given, When, Then } = require("@cucumber/cucumber");
const tide = require("../../src/tide.js");

Given("the tide table for Fundy Cove is loaded", function () {
  this.table = tide.loadTable();
});

When("I look up the next high tide after {string}", async function (after) {
  // Readers run on the next turn of the loop, as a request handler would.
  await new Promise((resolve) => setTimeout(resolve, 2));
  this.result = tide.lookupNextHigh(after);
});

Then("the lookup reports {string}", function (time) {
  assert.ok(this.result, "no lookup result");
  assert.strictEqual(this.result.time, time);
});
