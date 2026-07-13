const { When, Then } = require("@cucumber/cucumber");
const assert = require("assert");
const { tideRange } = require("../../src/tide");

When("I ask for the tide range on {string}", function (day) {
  this.range = tideRange(this.tides, day);
});

Then("the tide range is {float}", function (expected) {
  assert.equal(this.range, expected);
});
