// Codepunk mobile helpers, evaluated in the page by the game (web build).
//
// * isMobile(): true on phones/tablets (touch is the primary pointer).
//   Add ?mobile=1 (or ?mobile=0) to the URL to force it on (or off).
// * openEditor(): a full-screen HTML code editor. Phone keyboards work far
//   better with a real <textarea> than with a game canvas, so on mobile the
//   game hands the student's code to this editor and gets it back when
//   they're done.
(function () {
  "use strict";
  if (window.codepunkMobile) return;

  const params = new URLSearchParams(window.location.search);
  const forced = params.get("mobile");

  function isMobile() {
    if (forced === "1") return true;
    if (forced === "0") return false;
    return !!(window.matchMedia && window.matchMedia("(pointer: coarse)").matches);
  }

  const CSS = `
    #cp-editor { position: fixed; inset: 0; z-index: 10000; display: flex; flex-direction: column;
      background: #2b1d14; color: #f0e0c0; font-family: Georgia, "Times New Roman", serif;
      height: 100%; height: 100dvh; }
    #cp-editor header { display: flex; align-items: center; gap: 8px; padding: 8px 10px;
      border-bottom: 2px solid #c8a050; }
    #cp-editor header h1 { flex: 1; margin: 0; font-size: 17px; color: #f0d080; white-space: nowrap;
      overflow: hidden; text-overflow: ellipsis; }
    #cp-editor button { font: inherit; font-size: 15px; color: #f0e0c0; background: #5a3e28;
      border: 2px solid #7a5a28; border-radius: 6px; padding: 7px 12px; touch-action: manipulation; }
    #cp-editor button:active { background: #7a5a28; }
    #cp-editor button.cp-run { color: #1a120c; background: #c8a050; border-color: #f0d080; font-weight: bold; }
    #cp-editor .cp-keys { display: flex; gap: 6px; padding: 6px 8px; overflow-x: auto; flex-shrink: 0;
      background: #3d2a1c; border-bottom: 1px solid #7a5a28; -webkit-overflow-scrolling: touch; }
    #cp-editor .cp-keys button { font-family: Menlo, Consolas, "DejaVu Sans Mono", monospace;
      min-width: 40px; padding: 7px 9px; flex-shrink: 0; }
    #cp-editor .cp-body { flex: 1; display: flex; min-height: 0; background: #17110c; }
    #cp-editor .cp-gutter { padding: 10px 6px 10px 8px; color: #7a6a58; text-align: right;
      user-select: none; -webkit-user-select: none; overflow: hidden; white-space: pre;
      font: 16px/1.45 Menlo, Consolas, "DejaVu Sans Mono", monospace; }
    #cp-editor textarea { flex: 1; min-width: 0; margin: 0; border: 0; outline: none; resize: none;
      padding: 10px; background: transparent; color: #e8dcc4; caret-color: #f0d080; tab-size: 4;
      white-space: pre; overflow: auto; font: 16px/1.45 Menlo, Consolas, "DejaVu Sans Mono", monospace; }
  `;

  const KEYS = [
    ["Tab", "    "], ["Untab", null], [":", ":"], ["(", "("], [")", ")"], ["[", "["], ["]", "]"],
    ["{", "{"], ["}", "}"], ["=", "="], ['"', '"'], ["'", "'"], ["_", "_"], [",", ","], [".", "."],
    ["+", "+"], ["-", "-"], ["*", "*"], ["/", "/"], ["%", "%"], ["<", "<"], [">", ">"], ["#", "#"],
  ];

  function el(tag, attrs, text) {
    const node = document.createElement(tag);
    for (const k in attrs || {}) node.setAttribute(k, attrs[k]);
    if (text !== undefined) node.textContent = text;
    return node;
  }

  function insert(area, text) {
    area.focus();
    // execCommand keeps the browser's undo history working; fall back if it's unavailable.
    if (!document.execCommand || !document.execCommand("insertText", false, text)) {
      area.setRangeText(text, area.selectionStart, area.selectionEnd, "end");
      area.dispatchEvent(new Event("input"));
    }
  }

  function currentLine(area) {
    const start = area.value.lastIndexOf("\n", area.selectionStart - 1) + 1;
    return { start: start, text: area.value.slice(start, area.selectionStart) };
  }

  function openEditor(title, code, callback) {
    if (document.getElementById("cp-editor")) return;
    if (!document.getElementById("cp-editor-style")) {
      document.head.appendChild(el("style", { id: "cp-editor-style" }, CSS));
    }
    const root = el("div", { id: "cp-editor" });
    const header = el("header");
    const cancel = el("button", {}, "Cancel");
    const save = el("button", {}, "Save");
    const run = el("button", { class: "cp-run" }, "Run Tests");
    header.append(cancel, el("h1", {}, title), save, run);

    const keys = el("div", { class: "cp-keys" });
    const body = el("div", { class: "cp-body" });
    const gutter = el("div", { class: "cp-gutter" });
    const area = el("textarea", { autocapitalize: "off", autocomplete: "off", autocorrect: "off",
      spellcheck: "false", wrap: "off", "aria-label": "Python code" });
    area.value = code;
    body.append(gutter, area);
    root.append(header, keys, body);

    function updateGutter() {
      const lines = area.value.split("\n").length;
      let text = "";
      for (let i = 1; i <= lines; i++) text += i + "\n";
      gutter.textContent = text;
      gutter.scrollTop = area.scrollTop;
    }

    for (const [label, text] of KEYS) {
      const b = el("button", { type: "button" }, label);
      // Keep focus (and the phone keyboard) in the textarea.
      b.addEventListener("pointerdown", (e) => e.preventDefault());
      b.addEventListener("mousedown", (e) => e.preventDefault());
      b.addEventListener("click", () => {
        if (text !== null) {
          insert(area, text);
          return;
        }
        // Untab: remove up to 4 spaces from the start of the current line.
        const line = currentLine(area);
        const spaces = line.text.match(/^ {1,4}/);
        if (spaces) {
          const caret = area.selectionStart;
          area.setSelectionRange(line.start, line.start + spaces[0].length);
          insert(area, "");
          area.setSelectionRange(caret - spaces[0].length, caret - spaces[0].length);
        }
      });
      keys.appendChild(b);
    }

    // Auto-indent: keep the current indent, and add four spaces after a colon.
    area.addEventListener("beforeinput", (e) => {
      if (e.inputType !== "insertLineBreak" && e.inputType !== "insertParagraph") return;
      e.preventDefault();
      const line = currentLine(area).text;
      let indent = line.match(/^ */)[0];
      if (line.trimEnd().endsWith(":")) indent += "    ";
      insert(area, "\n" + indent);
    });
    area.addEventListener("input", updateGutter);
    area.addEventListener("scroll", () => { gutter.scrollTop = area.scrollTop; });
    // Don't let key presses reach the game underneath.
    for (const type of ["keydown", "keyup", "keypress"]) {
      root.addEventListener(type, (e) => e.stopPropagation());
    }

    function close(action) {
      const text = area.value;
      root.remove();
      callback(text, action);
    }
    cancel.addEventListener("click", () => close("cancel"));
    save.addEventListener("click", () => close("save"));
    run.addEventListener("click", () => close("run"));

    document.body.appendChild(root);
    updateGutter();
    // Godot keeps a hidden text input for keyboard input methods, and when it
    // loses focus it hands focus back to the game canvas. Let that happen now,
    // so it doesn't steal focus from the student's first tap in the editor.
    if (document.activeElement && document.activeElement !== document.body) {
      document.activeElement.blur();
    }
    setTimeout(() => {
      area.focus();
      area.setSelectionRange(0, 0);
    }, 0);
  }

  window.codepunkMobile = {
    isMobile: isMobile,
    devicePixelRatio: function () { return window.devicePixelRatio || 1; },
    openEditor: openEditor,
  };
})();
