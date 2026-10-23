#!/usr/bin/env python3
"""
Telegram Build Bot for Begonia Recovery Builds
Token: 8477945979:AAGTYiUAfnPjQFpkh576D7Xsqm0RDQJr_As
Authorized Chat ID: 8198896729 (txor93)
"""

import os
import sys
import time
import json
import subprocess
import urllib.request

BOT_TOKEN = os.environ.get("TELEGRAM_BOT_TOKEN", "8477945979:AAGTYiUAfnPjQFpkh576D7Xsqm0RDQJr_As")
ADMIN_CHAT_ID = int(os.environ.get("TELEGRAM_CHAT_ID", "8198896729"))
GH_BIN = os.environ.get("GH_BIN", "gh" if subprocess.run("which gh", shell=True, stdout=subprocess.PIPE).returncode == 0 else "/tmp/custom-dns/gh-wrap")

REPOS = {
    "fox": ("txorav/orangefox-begonia", "OrangeFox"),
    "twrp": ("txorav/twrp-begonia", "TWRP"),
    "shrp": ("txorav/shrp-begonia", "SHRP"),
    "pbrp": ("txorav/pbrp-begonia", "PBRP"),
}

STATE_FILE = os.environ.get("STATE_FILE", "/tmp/.bot_state.json")

def tg_api(method, data=None):
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/{method}"
    try:
        if data:
            req_data = json.dumps(data).encode("utf-8")
            req = urllib.request.Request(url, data=req_data, headers={"Content-Type": "application/json"})
        else:
            req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except Exception as e:
        if "409" not in str(e):
            print(f"[tg_api error] {method}: {e}", file=sys.stderr)
        return None

def send_msg(chat_id, text):
    res = tg_api("sendMessage", {
        "chat_id": chat_id,
        "text": text,
        "parse_mode": "Markdown",
        "disable_web_page_preview": True
    })
    print(f"[Telegram sent] To {chat_id}: ok={res and res.get('ok')}")
    return res

def run_cmd(cmd):
    try:
        env = dict(os.environ)
        if "GH_PAT" in env and "GH_TOKEN" not in env:
            env["GH_TOKEN"] = env["GH_PAT"]
        res = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=30, env=env)
        return res.stdout.strip()
    except Exception as e:
        return ""

def load_state():
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                return json.load(f)
        except Exception:
            pass
    return {"last_update_id": 0, "notified_runs": []}

def save_state(state):
    try:
        with open(STATE_FILE, "w") as f:
            json.dump(state, f, indent=2)
    except Exception as e:
        print(f"[save_state error]: {e}", file=sys.stderr)

def get_runs_status():
    lines = ["📊 *Begonia Recovery Build Monitor*\n"]
    for key, (repo, label) in REPOS.items():
        cmd = f"{GH_BIN} run list --repo {repo} -L 1 --json databaseId,status,conclusion,url"
        out = run_cmd(cmd)
        try:
            json_str = out[out.find("["):]
            runs = json.loads(json_str)
            if runs:
                run = runs[0]
                run_id = run.get("databaseId")
                status = run.get("status")
                conclusion = run.get("conclusion")
                url = run.get("url")
                if status == "in_progress" or status == "queued":
                    st = "🟡 In Progress"
                elif conclusion == "success":
                    st = "✅ Succeeded"
                else:
                    st = f"❌ {conclusion or 'Failed'}"
                lines.append(f"• *{label}*: {st} (`Run #{run_id}`)\n  🔗 [View Run]({url})")
            else:
                lines.append(f"• *{label}*: No runs found")
        except Exception:
            lines.append(f"• *{label}*: Querying...")
    return "\n\n".join(lines)

def trigger_build(key):
    if key == "all":
        results = []
        for k in REPOS:
            r, name = REPOS[k]
            cmd = f"{GH_BIN} workflow run build.yml --repo {r} --ref main"
            run_cmd(cmd)
            results.append(name)
        return f"🚀 Triggered cloud builds for: *{', '.join(results)}*"
    elif key in REPOS:
        repo, name = REPOS[key]
        cmd = f"{GH_BIN} workflow run build.yml --repo {repo} --ref main"
        run_cmd(cmd)
        return f"🚀 Triggered cloud build for *{name}* on `main`!"
    else:
        return f"Unknown recovery `{key}`. Options: `fox`, `twrp`, `shrp`, `pbrp`, `all`"

def poll_updates(state):
    offset = state.get("last_update_id", 0) + 1
    res = tg_api("getUpdates", {"offset": offset, "timeout": 15})
    if not res or not res.get("ok"):
        return state

    for update in res.get("result", []):
        state["last_update_id"] = update["update_id"]
        msg = update.get("message")
        if not msg:
            continue
        chat_id = msg.get("chat", {}).get("id")
        text = msg.get("text", "").strip()
        print(f"[Telegram] From {chat_id}: {text}")

        if text.startswith("/start") or text.startswith("/help"):
            welcome = (
                "👋 *Begonia Recovery CI/CD Bot*\n\n"
                "I monitor builds for Redmi Note 8 Pro (`begonia`) across OrangeFox, TWRP, SHRP, and PBRP.\n\n"
                "⚡ When builds complete, recovery artifacts are uploaded to Gofile and links are posted here automatically.\n\n"
                "*Commands:*\n"
                "• `/status` - Live build status\n"
                "• `/build <flavor>` - Dispatch build (`fox`, `twrp`, `shrp`, `pbrp`, `all`)\n"
                "• `/latest` - Show recent builds\n"
            )
            send_msg(chat_id, welcome)

        elif text.startswith("/status") or text.startswith("/latest"):
            st = get_runs_status()
            send_msg(chat_id, st)

        elif text.startswith("/build"):
            parts = text.split()
            target = parts[1].lower() if len(parts) > 1 else "all"
            resp = trigger_build(target)
            send_msg(chat_id, resp)

    return state

def monitor_completed_runs(state):
    notified = state.setdefault("notified_runs", [])
    for key, (repo, label) in REPOS.items():
        cmd = f"{GH_BIN} run list --repo {repo} -L 2 --json databaseId,status,conclusion,url"
        out = run_cmd(cmd)
        try:
            json_str = out[out.find("["):]
            runs = json.loads(json_str)
            for run in runs:
                run_id = str(run.get("databaseId"))
                status = run.get("status")
                conclusion = run.get("conclusion")
                url = run.get("url")

                if status == "completed" and run_id not in notified:
                    notified.append(run_id)
                    if conclusion == "success":
                        msg = (
                            f"🎉 *{label} Recovery Cloud Build Succeeded!*\n\n"
                            f"📱 *Device:* Redmi Note 8 Pro (`begonia`)\n"
                            f"⏱ *Run ID:* `#{run_id}`\n"
                            f"🔗 [View GitHub Actions Run]({url})\n\n"
                            f"📦 Direct Gofile links are delivered in the release message."
                        )
                    else:
                        msg = (
                            f"❌ *{label} Recovery Build Failed*\n\n"
                            f"📱 *Device:* Redmi Note 8 Pro (`begonia`)\n"
                            f"⏱ *Run ID:* `#{run_id}`\n"
                            f"🔗 [View Failed Logs]({url})"
                        )
                    send_msg(ADMIN_CHAT_ID, msg)
        except Exception:
            pass
    return state

def main():
    print("Begonia Build Bot starting...")
    state = load_state()
    for key, (repo, label) in REPOS.items():
        cmd = f"{GH_BIN} run list --repo {repo} -L 2 --json databaseId,status"
        out = run_cmd(cmd)
        try:
            json_str = out[out.find("["):]
            runs = json.loads(json_str)
            for r in runs:
                if r.get("status") == "completed":
                    rid = str(r.get("databaseId"))
                    if rid not in state.setdefault("notified_runs", []):
                        state["notified_runs"].append(rid)
        except Exception:
            pass
    save_state(state)
    print("Begonia Build Bot is running and monitoring...")

    webhook_info = tg_api("getWebhookInfo")
    has_webhook = bool(webhook_info and webhook_info.get("result", {}).get("url"))
    if has_webhook:
        print(f"Webhook active ({webhook_info['result']['url']}); running in notification-only monitor mode.")

    loop_count = 0
    max_loops = int(os.environ.get("MAX_LOOPS", "0"))  # 0 means infinite loop
    while True:
        try:
            if not has_webhook:
                state = poll_updates(state)
            state = monitor_completed_runs(state)
            save_state(state)
        except Exception as e:
            print(f"[Loop Exception]: {e}", file=sys.stderr)
            time.sleep(5)
        
        loop_count += 1
        if max_loops > 0 and loop_count >= max_loops:
            print("Max loops reached. Exiting cleanly.")
            break
        time.sleep(15)

if __name__ == "__main__":
    main()
