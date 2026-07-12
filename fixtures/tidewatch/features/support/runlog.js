const { BeforeAll } = require("@cucumber/cucumber");
const fs = require("fs");
const path = require("path");

BeforeAll(function () {
  const dir = path.join(__dirname, "..", "..", "logs");
  fs.mkdirSync(dir, { recursive: true });
  fs.appendFileSync(
    path.join(dir, "runs.log"),
    JSON.stringify({ t: new Date().toISOString(), argv: process.argv.slice(2) }) + "\n"
  );
});
