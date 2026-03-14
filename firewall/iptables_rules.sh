#!/bin/bash
# ================================
# PiGuard - Règles iptables ACL
# Auteure: Hanane
# ================================

echo "=== Configuration iptables ACL ==="

# Bloquer les scans de ports SYN flood
sudo iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT
sudo iptables -A INPUT -p tcp --syn -j DROP

# Bloquer les paquets invalides
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Loguer les paquets suspects
sudo iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "PiGuard-DROP: "

# Sauvegarder les règles
sudo iptables-save > /etc/iptables/rules.v4

echo "=== iptables configuré  ==="
sudo iptables -L -n --line-numbers | head -20
