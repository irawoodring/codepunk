// Codepunk <-> Pyodide bridge.
//
// The game evaluates this file in the page (via JavaScriptBridge) when it
// runs as a web export. Python runs inside Pyodide in a Web Worker, so student
// code can't freeze the game: if a run takes too long the worker is
// terminated and a fresh one is started.
//
// Pyodide is loaded from jsDelivr by default. To self-host it (e.g. for a
// school network that blocks CDNs), add ?pyodide=<url-of-pyodide-folder>/ to
// the game's URL.
(function () {
  "use strict";
  if (window.codepunkPython) return;

  const DEFAULT_PYODIDE = "https://cdn.jsdelivr.net/pyodide/v0.26.2/full/";
  const TIMEOUT_MS = 10000;

  const WORKER_SOURCE = `
    let pyodide = null;
    self.onmessage = async (event) => {
      const msg = event.data;
      if (msg.type === "init") {
        try {
          importScripts(msg.indexURL + "pyodide.js");
          pyodide = await loadPyodide({ indexURL: msg.indexURL });
          pyodide.setStdin({ error: true });
          self.postMessage({ type: "ready", version: pyodide.version });
        } catch (err) {
          self.postMessage({ type: "init_error", message: String(err) });
        }
        return;
      }
      if (msg.type === "run") {
        try {
          const root = "/home/pyodide/codepunk";
          const dir = root + "/runs/" + msg.id;
          pyodide.FS.mkdirTree(dir);
          pyodide.FS.writeFile(root + "/harness.py", msg.harness);
          pyodide.FS.writeFile(dir + "/mymodule.py", msg.code);
          pyodide.FS.writeFile(dir + "/test_mymodule.py", msg.tests);
          pyodide.globals.set("_cw_root", root);
          pyodide.globals.set("_cw_dir", dir);
          const json = pyodide.runPython([
            "import importlib.util, json",
            "_spec = importlib.util.spec_from_file_location('codepunk_harness', _cw_root + '/harness.py')",
            "_harness = importlib.util.module_from_spec(_spec)",
            "_spec.loader.exec_module(_harness)",
            "json.dumps(_harness.run_tests(_cw_dir))",
          ].join("\\n"));
          self.postMessage({ type: "result", token: msg.token, json: json });
        } catch (err) {
          self.postMessage({ type: "result", token: msg.token,
            json: JSON.stringify({ status: "crash", message: String(err) }) });
        }
      }
    };
  `;

  const params = new URLSearchParams(window.location.search);
  let indexURL = params.get("pyodide") || DEFAULT_PYODIDE;
  if (!indexURL.endsWith("/")) indexURL += "/";

  let worker = null;
  let status = "idle";          // idle, loading, ready, error
  let detail = "";
  let version = "";
  let pending = null;           // { token, callback, timer }
  let queued = null;            // a run requested while Python was loading
  let nextToken = 1;
  const statusListeners = [];

  function setStatus(s, d) {
    status = s;
    detail = d || "";
    for (const cb of statusListeners) {
      try { cb(status, detail); } catch (e) { console.error(e); }
    }
  }

  function startWorker() {
    const url = URL.createObjectURL(new Blob([WORKER_SOURCE], { type: "text/javascript" }));
    worker = new Worker(url);
    setStatus("loading", "Loading Python...");
    worker.onmessage = (event) => {
      const msg = event.data;
      if (msg.type === "ready") {
        version = msg.version;
        setStatus("ready", "Python " + version + " (Pyodide) is ready");
        if (queued) {
          const q = queued;
          queued = null;
          send(q);
        }
      } else if (msg.type === "init_error") {
        setStatus("error", "Couldn't load Python: " + msg.message);
        if (queued) {
          queued.callback(JSON.stringify({ status: "no_python",
            message: "Python couldn't be loaded in your browser. Check your internet connection and reload the page.\n" + msg.message }));
          queued = null;
        }
      } else if (msg.type === "result" && pending && pending.token === msg.token) {
        clearTimeout(pending.timer);
        const cb = pending.callback;
        pending = null;
        cb(msg.json);
      }
    };
    worker.onerror = (event) => {
      setStatus("error", "Python worker crashed: " + (event.message || "unknown error"));
    };
    worker.postMessage({ type: "init", indexURL: indexURL });
  }

  function send(job) {
    const token = nextToken++;
    pending = {
      token: token,
      callback: job.callback,
      timer: setTimeout(() => {
        // Infinite loop (or very slow code): kill the worker and start over.
        const cb = pending.callback;
        pending = null;
        worker.terminate();
        startWorker();
        cb(JSON.stringify({
          status: "timeout",
          message: "Your code ran for more than " + (TIMEOUT_MS / 1000) + " seconds and was stopped. " +
            "Look for a loop that never ends (a while loop whose condition never becomes False, " +
            "or recursion with no base case), or an approach that's too slow for big inputs " +
            "(like recursion that recomputes the same answers).",
        }));
      }, TIMEOUT_MS),
    };
    worker.postMessage({ type: "run", token: token, id: job.id, harness: job.harness,
      code: job.code, tests: job.tests });
  }

  window.codepunkPython = {
    // Start loading Pyodide in the background.
    init: function () {
      if (!worker) startWorker();
    },
    status: function () { return status; },
    detail: function () { return detail; },
    version: function () { return version; },
    onStatus: function (callback) { statusListeners.push(callback); },
    // callback(jsonString) is called with the harness result.
    run: function (id, harness, code, tests, callback) {
      if (!worker) startWorker();
      const job = { id: id, harness: harness, code: code, tests: tests, callback: callback };
      if (pending) {
        callback(JSON.stringify({ status: "crash", message: "Tests are already running." }));
      } else if (status === "ready") {
        send(job);
      } else if (status === "error") {
        // Loading failed earlier (e.g. the network dropped): try again.
        worker.terminate();
        startWorker();
        queued = job;
      } else {
        queued = job;
      }
    },
  };
})();
