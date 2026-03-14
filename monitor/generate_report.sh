#!/bin/bash
# ================================
# PiGuard - Rapport Final
# Auteure: Hanane
# ================================

echo "======================================"
echo "   📊 PIGUARD - RAPPORT DE SÉCURITÉ"
echo "   $(date)"
echo "======================================"

echo ""
echo "--- 🔥 STATUT FIREWALL ---"
sudo ufw status verbose

echo ""
echo "--- 🚨 TOP 20 ALERTES SURICATA ---"
sudo tail -20 /var/log/suricata/fast.log

echo ""
echo "--- 🌐 CONNEXIONS ACTIVES ---"
ss -tuln

echo ""
echo "--- 🔑 TENTATIVES SSH ---"
sudo grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5

echo ""
echo "======================================"
echo "   ✅ FIN DU RAPPORT"
echo "======================================"
