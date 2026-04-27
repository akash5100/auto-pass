import os
import time
import json
import urllib.request
import sys
from pathlib import Path
from playwright.sync_api import sync_playwright, TimeoutError

TIME = 2.5
AUTH_STATE = "auth_state.json"
CONFIG_URL = (
    "https://raw.githubusercontent.com/akash5100/auto-pass/main/remote_config.json"
)

BASE_URL = "https://fasalrin.gov.in/"
LIST_URL = "https://fasalrin.gov.in/claim-application-list"


def check_license_and_config():
    """
    Checks GitHub for the 'kill switch' and updates configuration dynamically.
    """
    global BASE_URL, LIST_URL

    print("[INFO] Checking for updates and license...")
    try:
        with urllib.request.urlopen(CONFIG_URL, timeout=10) as response:
            data = json.loads(response.read().decode())

            # 1. Kill Switch Check
            if data.get("status") != "active":
                print("\n" + "=" * 50)
                print(" [ACCESS DENIED]")
                print(f" {data.get('message', 'This software has been disabled.')}")
                print("=" * 50 + "\n")
                sys.exit(1)

            # 2. Dynamic Config Update
            remote_config = data.get("config", {})
            BASE_URL = remote_config.get("BASE_URL", BASE_URL)
            LIST_URL = remote_config.get("LIST_URL", LIST_URL)

            print(f"[OK] License active. Version: {data.get('version', 'unknown')}")

    except Exception as e:
        print(f"[WARNING] Could not verify license online: {e}")
        print("[WARNING] Please check your internet connection.")


def login_and_save_state(browser_context, page):
    print(f"Navigating to {BASE_URL}...")
    try:
        page.goto(BASE_URL)
        print("Please enter your credentials and Captcha, then log in.")
    except Exception as e:
        print(f"Error during navigation: {e}")

    print("\n>>> ACTION REQUIRED: Please solve the Captcha and log in.")

    while True:
        try:
            if "claim-application-list" in page.url:
                break

            page.get_by_role("button", name="PROCEED").wait_for(
                state="visible", timeout=2000
            )
            break
        except TimeoutError:
            pass

        try:
            page.get_by_text("REVIEW").first.wait_for(state="visible", timeout=2000)
            break
        except TimeoutError:
            pass

        time.sleep(1)

    print("Login detected!")
    browser_context.storage_state(path=AUTH_STATE)
    print(f"Session saved to {AUTH_STATE}")


def automate_approvals(page):
    print("Starting automation loop...")

    import re

    while True:
        try:
            # --- STATE 1: DETAILS / PREVIEW PAGE ---
            approve_btn = page.locator("button:has-text('APPROVE')").first

            is_details_page = False

            # Existing IS detection (unchanged)
            try:
                page.get_by_text("IS Claim Details", exact=False).wait_for(
                    state="visible", timeout=1000
                )
                is_details_page = True
            except TimeoutError:
                pass

            # NEW: fallback detection for PRI / preview pages
            if not is_details_page:
                try:
                    approve_btn.wait_for(state="visible", timeout=1000)
                    is_details_page = True
                except TimeoutError:
                    pass

            if is_details_page:
                print(">>> State: Details/Preview Page")

                try:
                    approve_btn.wait_for(state="visible", timeout=3000)
                    print("Found 'APPROVE'. Clicking...")
                    approve_btn.click()
                except TimeoutError:
                    pass

                # Handle popups (no sleep)
                for _ in range(2):
                    clicked = False
                    for selector in [
                        "button:has-text('OK')",
                        "button:has-text('Confirm')",
                        "button:has-text('Yes')",
                        "text=OK",
                        "text=Confirm",
                        "text=Yes",
                    ]:
                        btn = page.locator(selector).first
                        try:
                            btn.wait_for(state="visible", timeout=2000)
                            print(f"Clicking popup: {selector}")
                            btn.click()
                            clicked = True
                            break
                        except TimeoutError:
                            continue

                    if not clicked:
                        break

                try:
                    page.wait_for_url("**claim-application-list**", timeout=5000)
                except TimeoutError:
                    pass

                continue

            # --- STATE 2: LIST PAGE ---
            review_btn = (
                page.locator("button.edit-greenbtn, a.edit-greenbtn")
                .filter(has_text=re.compile(r"REVIEW", re.IGNORECASE))
                .first
            )

            try:
                review_btn.wait_for(state="visible", timeout=3000)
                print(">>> State: List Page. Clicking REVIEW...")
                review_btn.click()
                continue
            except TimeoutError:
                pass

            # --- STATE 3: WAITING ---
            print(">>> Waiting for table / user action...")
            time.sleep(1)

        except Exception:
            time.sleep(2)


def main():
    # --- REMOTE CONTROL CHECK ---
    check_license_and_config()

    with sync_playwright() as p:
        storage_state = AUTH_STATE if Path(AUTH_STATE).exists() else None

        browser = p.chromium.launch(headless=False)
        context = browser.new_context(storage_state=storage_state)
        page = context.new_page()

        page.goto(LIST_URL)

        try:
            page.wait_for_load_state("domcontentloaded", timeout=5000)
        except TimeoutError:
            pass

        if "login" in page.url or not Path(AUTH_STATE).exists():
            login_and_save_state(context, page)

        automate_approvals(page)

        print("Automation finished.")
        browser.close()


if __name__ == "__main__":
    main()
