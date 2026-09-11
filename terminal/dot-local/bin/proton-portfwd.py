#!/usr/bin/env python3
"""Keep a Proton VPN NAT-PMP port mapping alive and sync it to qBittorrent."""

import json
import os
import re
import subprocess
import sys
import time

import requests

# --- Configuration ---
GATEWAY = "10.2.0.1"
LEASE = 60  # lease length requested from the gateway (seconds)
RENEW_EVERY = 45  # renew well before the lease expires
RETRY_EVERY = 5  # retry quickly after a failed mapping
PORT_FILE = "/run/proton-port"

# Credentials come from the environment (see /etc/proton-portfwd.env).
# Leave QBIT_USER unset if qBittorrent bypasses auth for localhost.
QBIT_URL = os.environ.get("QBIT_URL", "http://localhost:8080")
QBIT_USER = os.environ.get("QBIT_USER", "")
QBIT_PASS = os.environ.get("QBIT_PASS", "")


def log(msg):
    # flush=True so output reaches journalctl immediately under systemd
    print(f"[{time.strftime('%H:%M:%S')}] {msg}", flush=True)


def request_mapping(protocol):
    """Ask the gateway for a mapping. Returns the public port, or None on failure."""
    try:
        result = subprocess.run(
            ["natpmpc", "-a", "1", "0", protocol, str(LEASE), "-g", GATEWAY],
            capture_output=True,
            text=True,
            timeout=30,
        )
    except (OSError, subprocess.TimeoutExpired) as e:
        log(f"natpmpc ({protocol}) failed to run: {e}")
        return None

    match = re.search(r"Mapped public port (\d+)", result.stdout)
    return int(match.group(1)) if match else None


def update_qbittorrent(port):
    """Set qBittorrent's listening port. Returns True only if it actually worked."""
    try:
        with requests.Session() as session:
            if QBIT_USER:
                session.post(
                    f"{QBIT_URL}/api/v2/auth/login",
                    data={"username": QBIT_USER, "password": QBIT_PASS},
                    timeout=5,
                )
            response = session.post(
                f"{QBIT_URL}/api/v2/app/setPreferences",
                data={"json": json.dumps({"listen_port": port, "upnp": False})},
                timeout=5,
            )
            # 403 here usually means the login failed
            response.raise_for_status()
    except requests.RequestException as e:
        log(f"Couldn't update qBittorrent, will retry: {e}")
        return False

    log(f"qBittorrent now listening on port {port}")
    return True


def write_port_file(port):
    try:
        with open(PORT_FILE, "w") as f:
            f.write(f"{port}\n")
    except OSError as e:
        log(f"Couldn't write {PORT_FILE}: {e}")


def main():
    current = None  # port the gateway last assigned
    synced = None  # port qBittorrent was last successfully set to

    log("Starting NAT-PMP loop")
    while True:
        udp = request_mapping("udp")
        tcp = request_mapping("tcp")

        if udp is None or tcp is None:
            log("Mapping failed, retrying shortly")
            time.sleep(RETRY_EVERY)
            continue

        if udp != tcp:
            log(f"Warning: UDP port {udp} differs from TCP port {tcp}")

        if tcp != current:
            log(f"Forwarded port: {tcp}")
            write_port_file(tcp)
            current = tcp

        # Only mark as synced once qBittorrent accepts it, so failures get retried
        if synced != current and update_qbittorrent(current):
            synced = current

        time.sleep(RENEW_EVERY)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
