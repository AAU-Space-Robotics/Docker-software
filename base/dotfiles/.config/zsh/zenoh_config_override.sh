#!/usr/bin/env bash

# --- CONFIG ---
TARGET_IP="192.168.50.100"

ZENOH_OVERRIDE='mode="client";connect/endpoints=["tcp/192.168.50.100:7447"]'

# --- FUNCTIONS ---

check_ping() {
    ping -c 1 -W 1 "$TARGET_IP" >/dev/null 2>&1
}

# --- MAIN ---
# if you want to check the zenoh check works,
# uncomment the echo lines.
if $BASESTATION; then
    if check_ping; then
        export ZENOH_CONFIG_OVERRIDE="$ZENOH_OVERRIDE"
        # echo "Target reachable. ZENOH_CONFIG_OVERRIDE exported."
    else
        # echo "Target IP not reachable: $TARGET_IP"
    fi
fi
