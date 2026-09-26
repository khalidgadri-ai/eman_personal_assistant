'use strict';
// Run with: node --test app.feedback.test.js
// app.js is a browser <script> (no imports/exports), so we load it into a
// sandboxed VM context with minimal document/localStorage/window stubs
// instead of pulling in a DOM testing dependency.
//
// Note: app.js declares its top-level state with `let`/`const` (appData,
// STORAGE_KEY, ...). Per the JS spec those bindings are NOT installed as
// properties on the global object, so we can't read them via `sandbox.appData`.
// Only top-level `function` declarations get installed as global properties
// (and so are callable via `sandbox.fnName(...)`). To read state we run small
// expressions back through the same context with vm.runInContext, where
// `appData` etc. are still in lexical scope.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

function loadApp() {
    const store = {};
    const elements = new Map();

    function element(id) {
        if (!elements.has(id)) {
            elements.set(id, {
                value: '',
                innerText: '',
                innerHTML: '',
                classList: { add() {}, remove() {} },
                addEventListener() {},
            });
        }
        return elements.get(id);
    }

    const sandbox = {
        document: {
            getElementById: element,
            addEventListener() {},
        },
        localStorage: {
            getItem: (key) => (Object.prototype.hasOwnProperty.call(store, key) ? store[key] : null),
            setItem: (key, value) => { store[key] = String(value); },
            removeItem: (key) => { delete store[key]; },
        },
        window: { addEventListener() {} },
        alert: () => {},
        confirm: () => true,
        console,
    };
    vm.createContext(sandbox);
    const code = fs.readFileSync(path.join(__dirname, 'app.js'), 'utf8');
    vm.runInContext(code, sandbox, { filename: 'app.js' });

    return {
        setFieldValue: (id, value) => { element(id).value = value; },
        call: (fnName, ...args) => sandbox[fnName](...args),
        evalExpr: (expr) => vm.runInContext(expr, sandbox),
        rawStorage: store,
    };
}

test('feedbackEntries starts empty by default', () => {
    const app = loadApp();
    // Cross-realm arrays from the vm context aren't reference-equal to a
    // host-realm [] under assert.deepEqual, so compare length instead.
    assert.equal(app.evalExpr('appData.feedbackEntries.length'), 0);
});

test('submitFeedback ignores blank input and does not save an entry', () => {
    const app = loadApp();
    app.setFieldValue('feedback-text', '   ');

    app.call('submitFeedback');

    assert.equal(app.evalExpr('appData.feedbackEntries.length'), 0);
});

test('submitFeedback saves trimmed text and persists it to localStorage', () => {
    const app = loadApp();
    app.setFieldValue('feedback-text', '  التطبيق رائع، أتمنى إضافة تذكيرات صوتية  ');

    app.call('submitFeedback');

    const entries = app.evalExpr('appData.feedbackEntries');
    assert.equal(entries.length, 1);
    assert.equal(entries[0].text, 'التطبيق رائع، أتمنى إضافة تذكيرات صوتية');
    assert.ok(entries[0].id);
    assert.ok(entries[0].date);

    const storageKey = app.evalExpr('STORAGE_KEY');
    const persisted = JSON.parse(app.rawStorage[storageKey]);
    assert.equal(persisted.feedbackEntries.length, 1);
    assert.equal(persisted.feedbackEntries[0].text, 'التطبيق رائع، أتمنى إضافة تذكيرات صوتية');
});

test('loadAppData restores previously saved feedback entries', () => {
    const first = loadApp();
    first.setFieldValue('feedback-text', 'ملاحظة محفوظة مسبقاً');
    first.call('submitFeedback');
    const storageKey = first.evalExpr('STORAGE_KEY');
    const savedRaw = first.rawStorage[storageKey];

    const second = loadApp();
    second.rawStorage[storageKey] = savedRaw;
    second.call('loadAppData');

    const entries = second.evalExpr('appData.feedbackEntries');
    assert.equal(entries.length, 1);
    assert.equal(entries[0].text, 'ملاحظة محفوظة مسبقاً');
});
