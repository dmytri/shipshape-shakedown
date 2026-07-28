const { setWorldConstructor, Before, After } = require('@cucumber/cucumber');
const { Window } = require('happy-dom');
const fs = require('fs');
const path = require('path');

function TodoWorld() {
  this.window = null;
  this.document = null;
  this.localStorage = null;
  this._appLoaded = false;
}

TodoWorld.prototype.loadApp = function () {
  if (this._appLoaded) { return; }
  try {
    var appCode = fs.readFileSync(
      path.resolve(__dirname, '../../js/app.js'), 'utf-8'
    );
    this.window.eval(appCode);
    this._appLoaded = true;
  } catch (e) {
    // App code not yet implemented
  }
};

setWorldConstructor(TodoWorld);

Before(function () {
  const html = fs.readFileSync(
    path.resolve(__dirname, '../../assets/app-template.index.html'),
    'utf-8'
  );
  const window = new Window({ url: 'http://localhost/' });
  const document = window.document;
  document.open();
  document.write(html);
  document.close();

  // Attach scripts to window
  window.localStorage.clear();
  window.addEventListener = window.addEventListener || (() => {});
  window.location.hash = '';

  this.window = window;
  this.document = document;
  this.localStorage = window.localStorage;
});

After(function () {
  if (this.window) {
    this.window.close();
  }
});