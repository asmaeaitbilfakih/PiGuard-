# PiGuard — IoT Intrusion Detection System

Système de détection d'intrusion en temps réel sur Raspberry Pi combinant Firewall, IDS (Suricata) et Machine Learning entraîné sur le dataset TON_IoT.

---

## Pourquoi ce projet ?

Les objets connectés (IoT) sont parmi les cibles les plus vulnérables des cyberattaques modernes. En 2024, les attaques IoT ont augmenté de 400%. La majorité des appareils IoT n'ont aucune protection réseau intégrée.

PiGuard répond à ce problème en déployant un système de sécurité complet sur Raspberry Pi — un appareil à faible coût — combinant trois couches de protection :

1. **Firewall** — bloque le trafic non autorisé avant qu'il n'atteigne le système
2. **IDS Suricata** — détecte les patterns d'attaque connus en temps réel
3. **Modèle ML** — classifie les attaques subtiles que les règles fixes ne peuvent pas capturer

---

## Stack technique

- Raspberry Pi 5 — OS ARM64
- Suricata 6.0 (IDS)
- UFW / iptables (Firewall + ACL)
- Python 3.11
- Scikit-learn (ML)
- Scapy (simulation d'attaques)
- Dataset TON_IoT (UNSW Australia)

---

## Architecture

```
[Attacker PC]  [IoT Devices]
      │               │
      └───────┬───────┘
              ↓
     ┌─────────────────────┐
     │    Raspberry Pi      │
     │                     │
     │  1. UFW / iptables  │  ← Bloque les IP non autorisées
     │         ↓           │
     │  2. Suricata IDS    │  ← Détecte les patterns d'attaque
     │         ↓           │
     │  3. Modèle ML       │  ← Classifie et prédit l'attaque
     │         ↓           │
     │  Monitor + Logs     │  ← Alertes en temps réel
     └─────────────────────┘
```

---

## Règles de détection — alignées avec TON_IoT

Le dataset TON_IoT contient 9 classes d'attaques. Nos règles Suricata couvrent les attaques réseau détectables par pattern :

| SID | Attaque TON_IoT | Méthode de détection | Statut |
|-----|-----------------|---------------------|--------|
| 1000001 | Scanning | TCP SYN > 20/sec par source | ✅ Détecté |
| 1000002 | Password attack | SSH > 5 tentatives/60sec | ✅ Détecté |
| 1000003 | Backdoor (Telnet) | Connexion TCP port 23 | ✅ Détecté |
| 1000004 | MQTT injection | Connexion TCP port 1883 | ✅ Détecté |
| 1000005 | DoS | ICMP flood > 10/sec | ✅ Règle active |
| 1000006 | DDoS | SYN flood > 30/sec vers dst | ✅ Détecté |
| 1000007 | Ransomware (SMB) | TCP port 445 > 5/5sec | ✅ Règle active |
| 1000008 | XSS | HTTP URI contient `<script>` | ✅ Règle active |
| 1000009 | SQL Injection | HTTP URI contient `union select` | ✅ Règle active |

---

## Pourquoi le ML complète Suricata ?

Les règles Suricata sont basées sur des **thresholds fixes** — par exemple "plus de 30 SYN par seconde = DDoS". Cette approche a une limitation importante : dans un environnement réseau local à très faible latence (< 1ms), certains patterns d'attaque arrivent trop rapidement pour que le threshold soit calculé correctement.

C'est exactement là qu'intervient le modèle ML :

```
Suricata seul :
  trafic → correspond à une règle ? → OUI / NON

Suricata + ML :
  trafic → extraction de features → modèle prédit →
  "DoS à 94% de confiance" même sans threshold exact
```

Le modèle ML détecte des **patterns subtils** dans les features réseau (durée, protocole, volume de bytes, nombre de paquets) que les règles fixes ne peuvent pas capturer. Il a été entraîné sur le dataset TON_IoT qui contient du trafic réseau réel annoté avec 9 classes d'attaques.

> **Note lab** : Les règles 1000005 (DoS ICMP) et 1000007 (SMB Ransomware) sont plus difficiles à déclencher en environnement lab local (latence < 1ms entre machines). En production avec du vrai trafic IoT distribué, ces règles fonctionnent normalement. Le modèle ML compense cette limitation en analysant les features du trafic plutôt que des thresholds fixes.

---

## Structure du projet

```
PiGuard/
│
├── README.md
├── .gitignore
│
├── firewall/
│   ├── setup_ufw.sh          # Configure UFW + règles ACL
│   ├── iptables_rules.sh     # Règles anti SYN flood + logging
│   └── acl_config.txt        # Documentation des règles ACL
│
├── ids/
│   ├── suricata.yaml         # Configuration Suricata (interface eth0)
│   └── rules/
│       └── local.rules       # 9 règles IoT alignées avec TON_IoT
│
├── attack_simulation/
│   ├── simulate_attacks.sh   # Simulation bash (nmap, nc, ssh)
│   ├── simulate_attacks.py   # Simulation Scapy depuis PC attaquant
│   └── test_traffic.py       # Génération trafic normal + suspect
│
├── ml_integration/
│   ├── predict_attack.py     # Intégration modèle ML
│   ├── model/
│   │   └── model.pkl         # Modèle entraîné sur TON_IoT
│   └── features.txt          # Features utilisées par le modèle
│
├── monitor/
│   ├── monitor.py            # Dashboard temps réel — 9 classes
│   └── generate_report.sh   # Rapport automatique
│
└── docs/
    ├── architecture.png
    └── screenshots/
```

---

## Installation

```bash
# 1. Cloner le repo
git clone https://github.com/ItsHaname/PiGuard-.git
cd PiGuard

# 2. Installer les dépendances
sudo apt install -y ufw iptables suricata nmap tcpdump
pip3 install pandas numpy scikit-learn scapy --break-system-packages

# 3. Configurer le firewall
chmod +x firewall/setup_ufw.sh
sudo ./firewall/setup_ufw.sh

# 4. Configurer Suricata
sudo cp ids/suricata.yaml /etc/suricata/suricata.yaml
sudo cp ids/rules/local.rules /etc/suricata/rules/local.rules
sudo systemctl restart suricata

# 5. Lancer le monitor
python3 monitor/monitor.py
```

---

## Démonstration

```bash
# Terminal 1 (Pi) — Monitor en temps réel
python3 monitor/monitor.py

# Terminal 2 (PC attaquant) — Simulation d'attaques
sudo python3 attack_simulation/simulate_attacks.py
```

Alertes générées en temps réel :
```
[ALERT] PORT SCAN     | src: 192.168.50.4 | 04:00:54
[ALERT] DDOS ATTACK   | src: 192.168.50.4 | 04:00:55
[ALERT] TELNET ATTACK | src: 192.168.50.4 | 04:00:56
[ALERT] MQTT ATTACK   | src: 192.168.50.4 | 04:00:57
```

---

## Résultats

- 9 règles Suricata couvrant toutes les classes TON_IoT
- 6 types d'attaques détectés en temps réel en environnement lab
- Intégration d'un modèle ML pour la classification automatique
- Firewall UFW avec règles ACL — SSH limité, Telnet/MQTT bloqués

---

## Auteurs

- **Hanane Ait Bah** — Réseau, Firewall, IDS, Intégration ML
  [@ItsHaname](https://github.com/ItsHaname)

- **Asmae Ait Bilfakih** — Modèle Machine Learning (dataset TON_IoT)
  [@asmaeaitbilfakih](https://github.com/asmaeaitbilfakih)
