#!/usr/bin/env python3
"""
GitHub API Push Script - Fallback when git push fails

Usage:
    python3 scripts/github-api-push.py
"""
import os, requests, base64
from pathlib import Path

token = os.environ.get("GH_TOKEN", "")
repo = "LaugHan/papershare-github"
api = f"https://api.github.com/repos/{repo}"
hdrs = {"Authorization": f"token {token}", "Accept": "application/vnd.github.v3+json"}

def get_sha(p):
    r = requests.get(f"{api}/contents/{p}", headers=hdrs)
    return r.json()["sha"] if r.status_code == 200 else None

def push(p, c, m):
    d = {"message": m, "content": base64.b64encode(c).decode()}
    sha = get_sha(p)
    if sha: d["sha"] = sha
    r = requests.put(f"{api}/contents/{p}", headers=hdrs, json=d)
    return r.status_code in [200, 201]

if __name__ == "__main__":
    for path, msg in [
        ("daily-paper/index.html", "fix: update daily-paper via API"),
    ]:
        fp = Path(__file__).parent.parent / path
        if fp.exists():
            print(f"{'✓' if push(path, fp.read_bytes(), msg) else '✗'} {path}")
