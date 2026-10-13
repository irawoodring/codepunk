"""Clockwork Codex test harness.

Runs a student's ``mymodule.py`` against a pytest-style ``test_mymodule.py``
and prints a single JSON result line prefixed with MARKER.

    python harness.py <run_dir>

Works whether or not pytest is installed: when it's missing, a small shim
providing ``approx``, ``raises``, ``fail`` and ``mark.parametrize`` stands in.
The tests run in a child process so infinite loops can be stopped.
"""
import ast
import contextlib
import io
import itertools
import json
import linecache
import os
import re
import subprocess
import sys
import traceback
import types

MARKER = "@@CLOCKWORK_RESULT@@"
TIMEOUT_SECONDS = 10
MAX_TEXT = 1500


def emit(result):
    print(MARKER + json.dumps(result, ensure_ascii=True))
    sys.stdout.flush()


def clip(text, limit=MAX_TEXT):
    text = str(text)
    return text if len(text) <= limit else text[:limit] + "\n... (output trimmed)"


# --------------------------------------------------------------------------
# Parent process: run the child with a timeout.
# --------------------------------------------------------------------------

def run_parent(run_dir):
    env = dict(os.environ, PYTHONIOENCODING="utf-8", PYTHONDONTWRITEBYTECODE="1")
    try:
        proc = subprocess.run(
            [sys.executable, os.path.abspath(__file__), "--child", run_dir],
            capture_output=True, text=True, encoding="utf-8", errors="replace",
            timeout=TIMEOUT_SECONDS, cwd=run_dir, env=env,
        )
    except subprocess.TimeoutExpired:
        emit({
            "status": "timeout",
            "message": "Your code ran for more than %d seconds and was stopped. "
                       "Look for a loop that never ends (a while loop whose "
                       "condition never becomes False, or recursion with no "
                       "base case)." % TIMEOUT_SECONDS,
        })
        return
    for line in proc.stdout.splitlines():
        if line.startswith(MARKER):
            print(line)
            return
    emit({"status": "crash",
          "message": clip((proc.stderr or proc.stdout or "No output.").strip())})


# --------------------------------------------------------------------------
# pytest shim (only used when pytest isn't installed)
# --------------------------------------------------------------------------

def install_pytest_shim():
    try:
        import pytest  # noqa: F401
        return
    except ImportError:
        pass

    mod = types.ModuleType("pytest")

    class Failed(Exception):
        pass

    def fail(msg="", pytrace=True):
        raise Failed(msg)

    def _close(actual, expected, rel, abs_tol):
        tol = max(rel * abs(expected), abs_tol)
        return abs(actual - expected) <= tol

    class approx:
        def __init__(self, expected, rel=None, abs=None):
            self.expected = expected
            self.rel = 1e-6 if rel is None else rel
            self.abs = 1e-12 if abs is None else abs

        def _match(self, actual, expected):
            if isinstance(expected, dict):
                return (isinstance(actual, dict) and actual.keys() == expected.keys()
                        and all(self._match(actual[k], expected[k]) for k in expected))
            if isinstance(expected, (list, tuple)):
                return (isinstance(actual, (list, tuple)) and len(actual) == len(expected)
                        and all(self._match(a, e) for a, e in zip(actual, expected)))
            if isinstance(expected, bool) or isinstance(actual, bool):
                return actual == expected
            try:
                return _close(actual, expected, self.rel, self.abs)
            except TypeError:
                return actual == expected

        def __eq__(self, actual):
            return self._match(actual, self.expected)

        def __ne__(self, actual):
            return not self == actual

        __hash__ = None

        def __repr__(self):
            return "approx(%r)" % (self.expected,)

    class RaisesContext:
        def __init__(self, expected, match=None):
            self.expected = expected
            self.match = match
            self.value = None
            self.type = None

        def __enter__(self):
            return self

        def __exit__(self, exc_type, exc, tb):
            names = (self.expected.__name__ if isinstance(self.expected, type)
                     else " or ".join(e.__name__ for e in self.expected))
            if exc_type is None:
                raise Failed("Expected %s to be raised, but no error happened." % names)
            if not issubclass(exc_type, self.expected):
                return False
            if self.match is not None and not re.search(self.match, str(exc)):
                raise Failed("%s was raised, but its message %r doesn't match %r."
                             % (exc_type.__name__, str(exc), self.match))
            self.value, self.type = exc, exc_type
            return True

    def raises(expected, *args, match=None, **kwargs):
        ctx = RaisesContext(expected, match)
        if args:
            with ctx:
                args[0](*args[1:], **kwargs)
        return ctx

    class Mark:
        def __init__(self, name, args, kwargs):
            self.name, self.args, self.kwargs = name, args, kwargs

    class MarkGenerator:
        def __getattr__(self, name):
            def factory(*args, **kwargs):
                def decorate(fn):
                    fn.pytestmark = list(getattr(fn, "pytestmark", [])) + [Mark(name, args, kwargs)]
                    return fn
                return decorate
            return factory

    mod.Failed = Failed
    mod.fail = fail
    mod.approx = approx
    mod.raises = raises
    mod.mark = MarkGenerator()
    sys.modules["pytest"] = mod


# --------------------------------------------------------------------------
# Friendlier assertion messages: rewrite `assert a OP b` so a failure says
# what each side actually was.
# --------------------------------------------------------------------------

OPS = {ast.Eq: "==", ast.NotEq: "!=", ast.Lt: "<", ast.LtE: "<=", ast.Gt: ">",
       ast.GtE: ">=", ast.Is: "is", ast.IsNot: "is not", ast.In: "in", ast.NotIn: "not in"}


def _explain(left, right, op, msg):
    def r(v):
        return clip(repr(v), 300)
    if msg:
        return str(msg)
    if op == "==":
        return "Expected %s but got %s" % (r(right), r(left))
    return "Check failed: %s %s %s" % (r(left), op, r(right))


class AssertRewriter(ast.NodeTransformer):
    def visit_Assert(self, node):
        test = node.test
        if not (isinstance(test, ast.Compare) and len(test.ops) == 1
                and type(test.ops[0]) in OPS):
            return node
        op = OPS[type(test.ops[0])]
        left = ast.Name("_cw_left", ast.Store())
        right = ast.Name("_cw_right", ast.Store())
        new = [
            ast.Assign([left], test.left),
            ast.Assign([right], test.comparators[0]),
            ast.Assert(
                ast.Compare(ast.Name("_cw_left", ast.Load()), test.ops,
                            [ast.Name("_cw_right", ast.Load())]),
                ast.Call(ast.Name("_cw_explain", ast.Load()),
                         [ast.Name("_cw_left", ast.Load()), ast.Name("_cw_right", ast.Load()),
                          ast.Constant(op), node.msg or ast.Constant(None)], []),
            ),
        ]
        for n in new:
            ast.copy_location(n, node)
        return new


# --------------------------------------------------------------------------
# Child process: import, collect and run tests.
# --------------------------------------------------------------------------

def frame_line(tb, filename):
    """Line number of the deepest traceback frame in `filename`, or None."""
    line = None
    for frame, lineno in traceback.walk_tb(tb):
        if os.path.basename(frame.f_code.co_filename) == filename:
            line = lineno
    return line


def describe_error(exc, run_dir):
    tb = exc.__traceback__
    test_line = frame_line(tb, "test_mymodule.py")
    code_line = frame_line(tb, "mymodule.py")
    name = type(exc).__name__
    if isinstance(exc, AssertionError):
        message = str(exc).strip()
        if not message and test_line:
            src = linecache.getline(os.path.join(run_dir, "test_mymodule.py"), test_line).strip()
            message = "Check failed: " + src
        return message or "Check failed.", None
    if name == "Failed":
        return str(exc), None
    if isinstance(exc, RecursionError):
        return ("RecursionError: your function kept calling itself forever. "
                "Is there a base case that stops the recursion?"), code_line
    text = "%s: %s" % (name, exc)
    if code_line:
        text += "  (in your code, line %d)" % code_line
    return text, code_line


def _label(value):
    text = getattr(value, "__name__", None) or repr(value)
    return text if len(text) <= 24 else text[:21] + "..."


def collect(module):
    """Yield (name, callable) for each test, expanding parametrize marks."""
    for name, obj in list(vars(module).items()):
        if not name.startswith("test") or not callable(obj):
            continue
        marks = [m for m in getattr(obj, "pytestmark", []) if m.name == "parametrize"]
        if not marks:
            yield name, obj
            continue
        param_sets = []
        for mark in marks:
            argnames, argvalues = mark.args[0], mark.args[1]
            if isinstance(argnames, str):
                argnames = [a.strip() for a in argnames.split(",") if a.strip()]
            rows = []
            for values in argvalues:
                values = getattr(values, "values", values)  # pytest.param
                if len(argnames) == 1:
                    values = (values,)
                rows.append(dict(zip(argnames, values)))
            param_sets.append(rows)
        for combo in itertools.product(*param_sets):
            kwargs = {}
            for part in combo:
                kwargs.update(part)
            label = ", ".join(_label(v) for v in kwargs.values())
            yield "%s[%s]" % (name, label), (lambda f=obj, k=kwargs: f(**k))


def run_child(run_dir):
    sys.path.insert(0, run_dir)
    os.chdir(run_dir)
    sys.setrecursionlimit(3000)
    install_pytest_shim()

    student_path = os.path.join(run_dir, "mymodule.py")
    test_path = os.path.join(run_dir, "test_mymodule.py")
    with open(student_path, encoding="utf-8") as f:
        student_src = f.read()
    with open(test_path, encoding="utf-8") as f:
        test_src = f.read()

    # 1. Syntax check the student's code first for a clear message.
    try:
        compile(student_src, student_path, "exec")
    except SyntaxError as e:
        emit({"status": "syntax_error", "line": e.lineno or 0,
              "message": "SyntaxError on line %s: %s" % (e.lineno, e.msg)})
        return

    # 2. Import the test module (which imports the student's module).
    captured = io.StringIO()
    tree = ast.fix_missing_locations(AssertRewriter().visit(ast.parse(test_src, test_path)))
    test_module = types.ModuleType("test_mymodule")
    test_module.__file__ = test_path
    test_module._cw_explain = _explain
    sys.modules["test_mymodule"] = test_module
    try:
        with contextlib.redirect_stdout(captured), contextlib.redirect_stderr(captured):
            exec(compile(tree, test_path, "exec"), test_module.__dict__)
    except Exception as e:
        message, line = describe_error(e, run_dir)
        if isinstance(e, ImportError) and "mymodule" in str(e):
            message = ("Couldn't load something the tests need from your code: %s. "
                       "Check that every function or class from the instructions "
                       "exists and is spelled exactly right." % e)
        emit({"status": "import_error", "message": message, "line": line or 0,
              "stdout": clip(captured.getvalue())})
        return

    # 3. Run each test.
    results = []
    for name, fn in collect(test_module):
        out = io.StringIO()
        passed, message, line = True, "", 0
        try:
            with contextlib.redirect_stdout(out), contextlib.redirect_stderr(out):
                fn()
        except BaseException as e:  # noqa: B902 - student code may raise anything
            if isinstance(e, KeyboardInterrupt):
                raise
            passed = False
            message, line = describe_error(e, run_dir)
            line = line or 0
        results.append({"name": name, "passed": passed, "message": clip(message, 600),
                        "line": line, "output": clip(out.getvalue(), 400)})

    if not results:
        emit({"status": "no_tests", "message": "No tests were found."})
        return
    emit({"status": "ok", "tests": results,
          "passed": sum(r["passed"] for r in results), "total": len(results),
          "stdout": clip(captured.getvalue())})


if __name__ == "__main__":
    if len(sys.argv) >= 3 and sys.argv[1] == "--child":
        run_child(sys.argv[2])
    elif len(sys.argv) >= 2:
        run_parent(os.path.abspath(sys.argv[1]))
    else:
        print("usage: python harness.py <run_dir>")
        sys.exit(2)
