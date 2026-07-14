#!/usr/bin/env python3
"""Does resident context actually cost WALL-CLOCK? (Goal 2, the owed latency probe.)

Usage: latency-probe.py <session-uuid> [...]

The per-leg correlation (r=+0.82, METRICS.md) is confounded: big-context legs are
Shipwright legs that also reason more per round, and per-leg wall includes tool
execution. This isolates the model's own think-time and controls for the confound.

think_time(n) = timestamp(assistant n) - timestamp(last tool_result before n)
             = prefill + decode, with tool execution excluded.

Then regress think_time on the things that could drive it:
    cache_read       - the CACHED prefix (doctrine + floor live here)
    cache_creation   - the UNCACHED prefix, paid at full prefill price
    output_tokens    - decode, which is sequential and usually dominates

The question that decides Goal 2: does cache_read carry a real time cost? Doctrine
is resident and cached, so if cached prefix is ~free in wall-clock, then trimming
doctrine buys NOTHING on latency (rung 2) and the case for touching it rests
entirely on rung-1 quality - which this instrument cannot see.

OLS by normal equations; no numpy dependency.
"""
import sys, os, glob, collections
from datetime import datetime
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from inbound import load  # noqa: E402

PROJ = os.path.expanduser("~/.claude/projects/-home-exedev-shipshape-shakedown")


def ts(r):
    t = r.get("timestamp")
    return datetime.fromisoformat(t.replace("Z", "+00:00")) if t else None


def samples(path):
    """One row per invocation: think-time and what might explain it."""
    recs = load(path)
    out, seen, last_input = [], set(), None
    for i, r in enumerate(recs):
        if r.get("type") in ("user", "attachment"):
            last_input = ts(r) or last_input
            continue
        if r.get("type") != "assistant":
            continue
        mid = r["message"]["id"]
        if mid in seen:
            continue                       # first chunk of the message = first token out
        seen.add(mid)
        u, t = r["message"]["usage"], ts(r)
        if not t or not last_input:
            continue
        dt = (t - last_input).total_seconds()
        if not (0 < dt < 300):             # drop clock oddities and long tool gaps
            continue
        out.append({
            "think": dt,
            "cache_read": u.get("cache_read_input_tokens", 0),
            "cache_creation": u.get("cache_creation_input_tokens", 0),
            "output": u.get("output_tokens", 0),
        })
    return out


def ols(rows, xs, y="think"):
    """Least squares with intercept, via Gaussian elimination on the normal equations."""
    n, k = len(rows), len(xs)
    X = [[1.0] + [float(r[x]) for x in xs] for r in rows]
    Y = [float(r[y]) for r in rows]
    A = [[sum(X[i][a] * X[i][b] for i in range(n)) for b in range(k + 1)] + [
          sum(X[i][a] * Y[i] for i in range(n))] for a in range(k + 1)]
    for c in range(k + 1):
        p = max(range(c, k + 1), key=lambda r: abs(A[r][c]))
        A[c], A[p] = A[p], A[c]
        if abs(A[c][c]) < 1e-12:
            return None
        for r in range(k + 1):
            if r != c:
                f = A[r][c] / A[c][c]
                for j in range(c, k + 2):
                    A[r][j] -= f * A[c][j]
    beta = [A[i][k + 1] / A[i][i] for i in range(k + 1)]
    ybar = sum(Y) / n
    pred = [sum(beta[j] * X[i][j] for j in range(k + 1)) for i in range(n)]
    ss_res = sum((Y[i] - pred[i]) ** 2 for i in range(n))
    ss_tot = sum((y_ - ybar) ** 2 for y_ in Y)
    return beta, (1 - ss_res / ss_tot if ss_tot else 0)


def pearson(rows, a, b):
    n = len(rows)
    ma, mb = sum(r[a] for r in rows) / n, sum(r[b] for r in rows) / n
    cov = sum((r[a] - ma) * (r[b] - mb) for r in rows)
    va = sum((r[a] - ma) ** 2 for r in rows) ** .5
    vb = sum((r[b] - mb) ** 2 for r in rows) ** .5
    return cov / (va * vb) if va and vb else 0


def main(sessions):
    rows = []
    for s in sessions:
        for f in glob.glob(f"{PROJ}/{s}/subagents/agent-*.jsonl"):
            rows += samples(f)
    if len(rows) < 30:
        sys.exit(f"only {len(rows)} usable invocations; need more legs")

    print(f"THE OWED LATENCY PROBE   n = {len(rows)} invocations, think-time isolated")
    print("(think = last tool result -> next assistant message; tool execution excluded)\n")

    print("Raw correlations with think-time:")
    for v in ("cache_read", "cache_creation", "output"):
        print(f"   {v:<16} r = {pearson(rows, v, 'think'):+.2f}")

    print("\nOLS: think ~ cache_read + cache_creation + output")
    r = ols(rows, ["cache_read", "cache_creation", "output"])
    if not r:
        sys.exit("singular")
    beta, r2 = r
    names = ["intercept", "cache_read", "cache_creation", "output"]
    for nm, b in zip(names, beta):
        if nm == "intercept":
            print(f"   {nm:<16} {b:>10.3f} s")
        else:
            print(f"   {nm:<16} {b*1000:>10.3f} s per 1k tokens")
    print(f"   R^2 = {r2:.2f}")

    b_cr, b_out = beta[1], beta[3]
    doctrine = 24_060
    typ_out = sum(r["output"] for r in rows) / len(rows)
    print("\nWHAT IT WOULD MEAN FOR DOCTRINE, IF THE COEFFICIENT WERE TRUSTWORTHY")
    print(f"   Shared Articles = {doctrine:,} cached tokens, resident on every invocation.")
    print(f"   Modelled cost of carrying them: {b_cr*doctrine:.2f} s per invocation.")
    print(f"   For scale, a typical {typ_out:,.0f}-token output decodes in {b_out*typ_out:.2f} s.")

    print("\nBUT IT IS NOT TRUSTWORTHY, AND THIS INSTRUMENT WILL NOT PRETEND OTHERWISE:")
    print(f"   R^2 = {r2:.2f} and cache_read's raw r is only {pearson(rows,'cache_read','think'):+.2f}.")
    print("   cache_read is collinear with everything - it grows monotonically within a leg,")
    print("   and later invocations also tend to think and write more. The coefficient is")
    print("   POSITIVE but POORLY IDENTIFIED. This is observational data with an uncontrolled")
    print("   confound; it cannot settle the question, and a number this weak must not be")
    print("   quoted as a finding.")
    print("\n   => THE CONTROLLED PROBE IS STILL OWED: hold the task fixed, vary ONLY the")
    print("      resident context (inert ballast), and measure think-time. See bin/ballast-probe.sh.")


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not args:
        args = [os.path.basename(p) for p in glob.glob(f"{PROJ}/*") if os.path.isdir(p)]
    main(args)
