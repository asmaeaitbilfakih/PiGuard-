#!/bin/bash
# ================================
# PiGuard - UFW Firewall Setup
# Auteure: Hanane
# ================================

echo "=== Configuration UFW Firewall ==="

# Activer le firewall
sudo ufw enable

# Politique par défaut
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Autoriser SSH
sudo ufw allow ssh

# Bloquer Telnet (attaque IoT courante)
sudo ufw deny 23

# Bloquer MQTT depuis l'extérieur
sudo ufw deny 1883

# Limiter SSH (anti brute force)
sudo ufw limit ssh

# Autoriser uniquement le PC de test
sudo ufw allow from 192.168.50.4 to any

echo "=== UFW Status ==="
sudo ufw status verbose

echo "=== Configuration terminée ✅ ==="
