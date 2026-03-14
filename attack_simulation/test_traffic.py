#!/usr/bin/env python3
# ================================
# PiGuard - Test Traffic avec Scapy
# Auteure: Hanane
# ================================

from scapy.all import *
import time

TARGET_IP = "192.168.50.2"

print("=" * 50)
print("   🔴 PIGUARD - GÉNÉRATION DE TRAFIC")
print("=" * 50)

# 1. Trafic normal (ping)
print("\n[1/4] ✅ Trafic normal - ICMP ping...")
for i in range(3):
    pkt = IP(dst=TARGET_IP)/ICMP()
    send(pkt, verbose=False)
    time.sleep(0.5)
print("      Pings envoyés!")

# 2. Simulation scan de ports
print("\n[2/4] 🔍 Simulation Port Scan...")
for port in [22, 23, 80, 443, 1883, 8080]:
    pkt = IP(dst=TARGET_IP)/TCP(dport=port, flags="S")
    send(pkt, verbose=False)
    time.sleep(0.1)
print("      Port scan envoyé!")

# 3. SYN Flood léger
print("\n[3/4] 💥 SYN Flood léger (25 paquets)...")
for i in range(25):
    pkt = IP(dst=TARGET_IP)/TCP(dport=RandShort(), flags="S")
    send(pkt, verbose=False)
print("      SYN Flood envoyé!")

# 4. Telnet attempt
print("\n[4/4] ⚠️  Tentative Telnet (port 23)...")
for i in range(3):
    pkt = IP(dst=TARGET_IP)/TCP(dport=23, flags="S")
    send(pkt, verbose=False)
    time.sleep(0.2)
print("      Telnet attack envoyé!")

print("\n" + "=" * 50)
print("   ✅ TEST TERMINÉ!")
print("   Vérifie monitor.py pour les alertes 🚨")
print("=" * 50)
