const { Given, When, Then, Before } = require("@cucumber/cucumber");
const { TodoWorld } = require("../support/world");
const assert = require("assert");

let world;

Before(async function () {
  world = new TodoWorld();
});

/* ---- Given steps ---- */

Given("the todo application is loaded", async function () {
  await world.loadApp();
});

Given("there are no todos", function () {
  // localStorage already empty from loadApp; ensure it stays clean
  world.localStorage.setItem("todos-vanilla", JSON.stringify([]));
  world.reload();
});

Given("the todo list has the following items:", function (dataTable) {
  const todos = dataTable.hashes().map((row) => ({
    id: Date.now().toString() + Math.random().toString(36).slice(2),
    title: row.title,
    completed: row.completed === "true",
  }));
  world.localStorage.setItem("todos-vanilla", JSON.stringify(todos));
  world.reload();
});

Given("the user has added a new todo {string}", function (title) {
  const existing = JSON.parse(
    world.localStorage.getItem("todos-vanilla") || "[]"
  );
  existing.push({
    id: Date.now().toString(),
    title: title,
    completed: false,
  });
  world.localStorage.setItem("todos-vanilla", JSON.stringify(existing));
  world.reload();
});

Given("the user has double-clicked the label for {string}", async function (title) {
  // First ensure the todo exists
  const existing = JSON.parse(
    world.localStorage.getItem("todos-vanilla") || "[]"
  );
  if (!existing.find((t) => t.title === title)) {
    existing.push({
      id: Date.now().toString(),
      title: title,
      completed: false,
    });
    world.localStorage.setItem("todos-vanilla", JSON.stringify(existing));
    world.reload();
  }
  // Double-click the label
  const li = world.findTodoItem(title);
  const label = li.querySelector("label");
  label.dispatchEvent(new world.window.Event("dblclick", { bubbles: true }));
  await new Promise((r) => setTimeout(r, 0));
});

Given("{string} is in editing mode", async function (title) {
  // Ensure todo exists
  const existing = JSON.parse(
    world.localStorage.getItem("todos-vanilla") || "[]"
  );
  if (!existing.find((t) => t.title === title)) {
    existing.push({
      id: Date.now().toString(),
      title: title,
      completed: false,
    });
    world.localStorage.setItem("todos-vanilla", JSON.stringify(existing));
    world.reload();
  }
  const li = world.findTodoItem(title);
  li.classList.add("editing");
  const editInput = li.querySelector(".edit");
  if (editInput) editInput.focus();
  await new Promise((r) => setTimeout(r, 0));
  // Assert editing mode is active
  assert.ok(
    li.classList.contains("editing"),
    `Expected "${title}" to be in editing mode`
  );
});

Given("the user has navigated to {string}", function (hash) {
  world.window.location.hash = hash;
  world.window.dispatchEvent(
    new world.window.HashChangeEvent("hashchange")
  );
  world.reload();
});

/* ---- When steps ---- */

When("the user adds a new todo {string}", async function (title) {
  const input = world.document.querySelector(".new-todo");
  input.value = title;
  input.dispatchEvent(
    new world.window.KeyboardEvent("keydown", {
      key: "Enter",
      keyCode: 13,
      bubbles: true,
    })
  );
  await new Promise((r) => setTimeout(r, 0));
});

When("the user clicks {string}", async function (text) {
  const buttons = world.document.querySelectorAll("button");
  for (const btn of buttons) {
    if (btn.textContent.trim() === text) {
      btn.click();
      break;
    }
  }
  await new Promise((r) => setTimeout(r, 0));
});

When("the user clicks the destroy button for {string}", async function (title) {
  const li = world.findTodoItem(title);
  const destroyBtn = li.querySelector(".destroy");
  destroyBtn.click();
  await new Promise((r) => setTimeout(r, 0));
});

When("the user reloads the page", async function () {
  world.reload();
  await new Promise((r) => setTimeout(r, 0));
});

When("the user navigates to {string}", async function (hash) {
  world.window.location.hash = hash;
  world.window.dispatchEvent(
    new world.window.HashChangeEvent("hashchange")
  );
  await new Promise((r) => setTimeout(r, 0));
});

When("the user marks {string} as complete", async function (title) {
  const li = world.findTodoItem(title);
  world.rememberedElement = li;
  const toggle = li.querySelector(".toggle");
  if (!toggle.checked) toggle.click();
  await new Promise((r) => setTimeout(r, 0));
});

When("the user marks {string} as active", async function (title) {
  const li = world.findTodoItem(title);
  world.rememberedElement = li;
  const toggle = li.querySelector(".toggle");
  if (toggle.checked) toggle.click();
  await new Promise((r) => setTimeout(r, 0));
});

When("the user double-clicks the label for {string}", async function (title) {
  const li = world.findTodoItem(title);
  const label = li.querySelector("label");
  label.dispatchEvent(new world.window.Event("dblclick", { bubbles: true }));
  await new Promise((r) => setTimeout(r, 0));
});

When("the user clicks the toggle-all checkbox", async function () {
  world.rememberedElements = Array.from(
    world.document.querySelectorAll(".todo-list li")
  );
  const toggleAll = world.document.querySelector("#toggle-all");
  toggleAll.click();
  await new Promise((r) => setTimeout(r, 0));
});

When(
  "the user changes the edit value to {string} and presses Enter",
  async function (value) {
    const editingLi = world.document.querySelector(".todo-list li.editing");
    const editInput = editingLi.querySelector(".edit");
    editInput.value = value;
    editInput.dispatchEvent(
      new world.window.KeyboardEvent("keydown", {
        key: "Enter",
        keyCode: 13,
        bubbles: true,
      })
    );
    await new Promise((r) => setTimeout(r, 0));
  }
);

When(
  "the user changes the edit value to {string} and clicks outside",
  async function (value) {
    const editingLi = world.document.querySelector(".todo-list li.editing");
    const editInput = editingLi.querySelector(".edit");
    editInput.value = value;
    editInput.dispatchEvent(
      new world.window.Event("blur", { bubbles: true })
    );
    await new Promise((r) => setTimeout(r, 0));
  }
);

When(
  "the user changes the edit value to {string} and presses Escape",
  async function (value) {
    const editingLi = world.document.querySelector(".todo-list li.editing");
    const editInput = editingLi.querySelector(".edit");
    editInput.value = value;
    editInput.dispatchEvent(
      new world.window.KeyboardEvent("keydown", {
        key: "Escape",
        keyCode: 27,
        bubbles: true,
      })
    );
    await new Promise((r) => setTimeout(r, 0));
  }
);

When("the user clears the edit value and presses Enter", async function () {
  const editingLi = world.document.querySelector(".todo-list li.editing");
  const editInput = editingLi.querySelector(".edit");
  editInput.value = "";
  editInput.dispatchEvent(
    new world.window.KeyboardEvent("keydown", {
      key: "Enter",
      keyCode: 13,
      bubbles: true,
    })
  );
  await new Promise((r) => setTimeout(r, 0));
});

/* ---- Then steps ---- */

Then("the todo list displays {string}", function (title) {
  const li = world.findTodoItem(title);
  assert.ok(li, `Expected todo list to display "${title}"`);
});

Then("the todo list does not display {string}", function (title) {
  const li = world.findTodoItem(title);
  assert.ok(!li, `Expected todo list not to display "${title}"`);
});

Then("the todo list has {int} item", function (count) {
  const items = world.document.querySelectorAll(".todo-list li");
  assert.strictEqual(items.length, count);
});

Then("the todo list has {int} items", function (count) {
  const items = world.document.querySelectorAll(".todo-list li");
  assert.strictEqual(items.length, count);
});

Then("the new todo field is empty", function () {
  const input = world.document.querySelector(".new-todo");
  assert.strictEqual(input.value, "");
});

Then("the new todo input is focused", function () {
  const input = world.document.querySelector(".new-todo");
  assert.strictEqual(
    world.document.activeElement,
    input,
    "Expected new todo input to be focused"
  );
});

Then("the main section is hidden", function () {
  const main = world.document.querySelector(".main");
  const style = world.window.getComputedStyle(main);
  assert.strictEqual(
    style.display,
    "none",
    "Expected main section to be hidden"
  );
});

Then("the main section is visible", function () {
  const main = world.document.querySelector(".main");
  const style = world.window.getComputedStyle(main);
  assert.notStrictEqual(
    style.display,
    "none",
    "Expected main section to be visible"
  );
});

Then("the footer is hidden", function () {
  const footer = world.document.querySelector(".footer");
  const style = world.window.getComputedStyle(footer);
  assert.strictEqual(
    style.display,
    "none",
    "Expected footer to be hidden"
  );
});

Then("the footer is visible", function () {
  const footer = world.document.querySelector(".footer");
  const style = world.window.getComputedStyle(footer);
  assert.notStrictEqual(
    style.display,
    "none",
    "Expected footer to be visible"
  );
});

Then("{string} is marked as completed", function (title) {
  const li = world.findTodoItem(title);
  assert.ok(
    li.classList.contains("completed"),
    `Expected "${title}" to be marked as completed`
  );
});

Then("{string} is not marked as completed", function (title) {
  const li = world.findTodoItem(title);
  assert.ok(
    !li.classList.contains("completed"),
    `Expected "${title}" not to be marked as completed`
  );
});

Then("{string} is not in editing mode", function (title) {
  const li = world.findTodoItem(title);
  assert.ok(
    !li.classList.contains("editing"),
    `Expected "${title}" not to be in editing mode`
  );
});

Then("the edit field for {string} contains {string}", function (title, value) {
  const li = world.findTodoItem(title);
  const editInput = li.querySelector(".edit");
  assert.strictEqual(editInput.value, value);
});

Then("the edit field for {string} is focused", function (title) {
  const li = world.findTodoItem(title);
  const editInput = li.querySelector(".edit");
  assert.strictEqual(
    world.document.activeElement,
    editInput,
    `Expected edit field for "${title}" to be focused`
  );
});

Then("the clear completed button is hidden", function () {
  const btn = world.document.querySelector(".clear-completed");
  const style = world.window.getComputedStyle(btn);
  assert.strictEqual(
    style.display,
    "none",
    "Expected clear completed button to be hidden"
  );
});

Then("the counter shows {string}", function (text) {
  const counter = world.document.querySelector(".todo-count");
  assert.strictEqual(counter.textContent.trim(), text);
});

Then("the {string} filter is selected", function (filter) {
  const links = world.document.querySelectorAll(".filters a");
  for (const link of links) {
    if (link.textContent.trim() === filter) {
      assert.ok(
        link.classList.contains("selected"),
        `Expected "${filter}" filter to be selected`
      );
      return;
    }
  }
  assert.fail(`Filter "${filter}" not found`);
});

Then("the toggle-all checkbox is checked", function () {
  const toggleAll = world.document.querySelector("#toggle-all");
  assert.strictEqual(toggleAll.checked, true, "Expected toggle-all to be checked");
});

Then("the toggle-all checkbox is not checked", function () {
  const toggleAll = world.document.querySelector("#toggle-all");
  assert.strictEqual(toggleAll.checked, false, "Expected toggle-all not to be checked");
});

Then("the todo item for {string} remains the same DOM element", function (title) {
  var el = world.rememberedElement;
  if (!el && world.rememberedElements) {
    // Try to find by title in the remembered array
    for (var i = 0; i < world.rememberedElements.length; i++) {
      var label = world.rememberedElements[i].querySelector("label");
      if (label && label.textContent === title) {
        el = world.rememberedElements[i];
        break;
      }
    }
  }
  assert.ok(el, `Expected a remembered element for "${title}"`);
  assert.ok(el.parentNode, `Expected "${title}" element to remain attached to the DOM`);
  assert.strictEqual(
    world.document.contains(el),
    true,
    `Expected "${title}" element to still be in the document`
  );
});

Then("the checkbox for {string} is hidden", function (title) {
  const li = world.findTodoItem(title);
  const checkbox = li.querySelector(".toggle");
  const style = world.window.getComputedStyle(checkbox);
  assert.strictEqual(
    style.display,
    "none",
    `Expected checkbox for "${title}" to be hidden`
  );
});

Then("the destroy button for {string} is hidden", function (title) {
  const li = world.findTodoItem(title);
  const destroyBtn = li.querySelector(".destroy");
  const style = world.window.getComputedStyle(destroyBtn);
  assert.strictEqual(
    style.display,
    "none",
    `Expected destroy button for "${title}" to be hidden`
  );
});