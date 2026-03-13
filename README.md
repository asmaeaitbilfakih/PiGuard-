# 🛡️ PiGuard — IoT Intrusion Detection System

Système de détection d'intrusion en temps réel sur Raspberry Pi
combinant Firewall, IDS (Suricata) et Machine Learning.

## Stack technique
- Raspberry Pi OS ARM64
- Suricata 6.0 (IDS)
- UFW / iptables (Firewall)
- Python 3.11
- Scikit-learn (ML)

## Structure
- firewall/        → Configuration UFW et iptables
- ids/             → Configuration Suricata et règles
- attack_simulation/ → Scripts de test
- ml_integration/  → Intégration du modèle ML
- monitor/         → Dashboard et rapports
```
PiGuard/
│
├── README.md                          # Description du projet
├── .gitignore                         # Fichiers à ignorer
│
├── firewall/
│   ├── setup_ufw.sh                   # Script pour configurer UFW
│   ├── iptables_rules.sh              # Règles iptables avancées
│   └── acl_config.txt                 # Liste des règles ACL
│
├── ids/
│   ├── suricata.yaml                  # Config Suricata
│   ├── rules/
│   │   └── local.rules                # Tes règles IoT personnalisées
│   └── logs/
│       └── alerts_sample.log          # Exemple de logs d'alertes
│
├── attack_simulation/
│   ├── simulate_attacks.sh            # Script pour simuler des attaques
│   └── test_traffic.py                # Script Scapy pour générer trafic
│
├── ml_integration/
│   ├── predict_attack.py              # Script qui utilise le modèle
│   ├── model/
│   │   └── model.pkl                  # Modèle ML de ton amie (à ajouter)
│   └── features.txt                   # Liste des features du modèle
│
├── monitor/
│   ├── monitor.py                     # Dashboard temps réel
│   └── generate_report.sh             # Script rapport final
│
└── docs/
    ├── architecture.png               # Schéma du projet
    ├── screenshots/                   # Screenshots 
    └── rapport_final.pdf              # Rapport complet
```
## Auteurs
- Hanane → Réseau, Firewall, IDS, Intégration ML
- [https://github.com/asmaeaitbilfakih]  → Modèle Machine Learning (dataset TON_IoT)
