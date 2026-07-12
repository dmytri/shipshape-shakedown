const { Given, When, Then } = require("@cucumber/cucumber");
const assert = require("assert");
const fs = require("fs");
const path = require("path");
const { nextHighTide } = require("../../src/tide");

Given("the tide table for Fundy Cove", function () {
  this.tides = JSON.parse(fs.readFileSync(path.join(__dirname, "..", "..", "data", "tides.json"), "utf8"));
});

When("I ask for the next high tide after {string}", function (after) {
  try {
    this.result = nextHighTide(this.tides, after);
  } catch (e) {
    this.error = e;
  }
});

Then("the predicted high tide is at {string} with height {float}", function (time, height) {
  assert.equal(this.result.time, time);
  assert.equal(this.result.height, height);
});

Then("the prediction fails with {string}", function (msg) {
  assert.equal(this.error.message, msg);
});
