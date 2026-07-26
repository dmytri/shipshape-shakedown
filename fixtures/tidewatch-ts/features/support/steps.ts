import assert from "node:assert";
import { readFileSync } from "node:fs";
import path from "node:path";
import { Given, Then, When } from "@cucumber/cucumber";
import { nextHighTide, type Tide } from "../../src/tide.ts";

let tides: Tide[];
let result: Tide | undefined;
let error: Error | undefined;

Given("the tide table for Fundy Cove", () => {
	const file = path.resolve("data", "tides.json");
	tides = JSON.parse(readFileSync(file, "utf8")) as Tide[];
});

When("I ask for the next high tide after {string}", (after: string) => {
	result = undefined;
	error = undefined;
	try {
		result = nextHighTide(tides, after);
	} catch (e) {
		error = e as Error;
	}
});

Then(
	"the predicted high tide is at {string} with height {float}",
	(time: string, height: number) => {
		assert.equal(result?.time, time);
		assert.equal(result?.height, height);
	},
);

Then("the prediction fails with {string}", (msg: string) => {
	assert.equal(error?.message, msg);
});
