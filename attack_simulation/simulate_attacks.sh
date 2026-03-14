#!/bin/bash
# ================================
# PiGuard - Simulation d'attaques
# Auteure: Hanane
# ================================

TARGET="192.168.50.2"
PC_IP="192.168.50.4"

echo "======================================"
echo "   🔴 PIGUARD - SIMULATION D'ATTAQUES"
echo "   Target: $TARGET"
echo "   $(date)"
echo "======================================"

echo ""
echo "[1/4] 🔍 Port Scan (nmap SYN)..."
nmap -sS $TARGET -p 1-1000 2>/dev/null | tail -5
echo "✅ Port Scan lancé — vérifie le monitor!"
sleep 2

echo ""
echo "[2/4] 🔑 SSH Brute Force simulation..."
for i in {1..8}; do
    ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no wronguser@$TARGET 2>/dev/null
done
echo "✅ SSH Brute Force lancé!"
sleep 2

echo ""
echo "[3/4] ⚠️  Telnet Attack..."
echo "" | nc -w 1 $TARGET 23 2>/dev/null
echo "✅ Telnet Attack lancé!"
sleep 2

echo ""
echo "[4/4] 📡 MQTT Attack..."
echo "" | nc -w 1 $TARGET 1883 2>/dev/null
echo "✅ MQTT Attack lancé!"

echo ""
echo "======================================"
echo "   ✅ SIMULATION TERMINÉE"
echo "   Vérifie le monitor pour les alertes!"
echo "======================================"
