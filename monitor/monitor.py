#!/usr/bin/env python3
# ================================
# PiGuard - Monitor temps réel
# Auteure: Hanane
# ================================

import time
from datetime import datetime

LOG_FILE = "/var/log/suricata/fast.log"

print("=" * 55)
print("   🔴 PIGUARD - MONITOR EN TEMPS RÉEL")
print("=" * 55)
print(f"[{datetime.now().strftime('%H:%M:%S')}] En attente d'alertes...\n")

try:
    with open(LOG_FILE, 'r') as f:
        f.seek(0, 2)  # Aller à la fin du fichier
        while True:
            line = f.readline()
            if line:
                if "Port Scan" in line:
                    print(f"🚨 PORT SCAN    : {line.strip()}")
                elif "SSH Brute" in line:
                    print(f"🔑 BRUTE FORCE  : {line.strip()}")
                elif "TELNET" in line:
                    print(f"⚠️  TELNET ATTACK: {line.strip()}")
                elif "MQTT" in line:
                    print(f"📡 MQTT ATTACK  : {line.strip()}")
                else:
                    print(f"⚡ ALERT        : {line.strip()}")
            else:
                time.sleep(0.5)
except FileNotFoundError:
    print("❌ Log file not found!")
except KeyboardInterrupt:
    print("\n✅ Monitor arrêté.")
