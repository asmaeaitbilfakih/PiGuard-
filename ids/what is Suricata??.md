<img width="674" height="347" alt="image" src="https://github.com/user-attachments/assets/cd71cd3b-4c6c-428e-95d9-7cf18dafbe3a" />


# 🔍 IDS — Intrusion Detection System avec Suricata

## 📌 C'est quoi Suricata ?

Suricata est un **système de détection d'intrusion (IDS)** open source.  
Il analyse **chaque paquet réseau** qui passe sur ton interface en temps réel et génère une **alerte** quand il détecte un comportement suspect ou une attaque connue.

> 💡 **Analogie simple :** Si le Firewall est le videur qui bloque à la porte, Suricata est la **caméra de surveillance** qui regarde tout ce qui se passe à l'intérieur et sonne l'alarme.

---

## 🧠 Comment Suricata fonctionne ?

```
Trafic réseau (eth0)
        ↓
   [ Suricata ]
        ↓
Compare chaque paquet avec les règles
        ↓
✅ Normal   →  Rien à signaler
🚨 Suspect  →  Alerte dans /var/log/suricata/fast.log
```

Suricata utilise des **règles de détection** — chaque règle décrit un pattern d'attaque.  
Si le trafic correspond à une règle → alerte générée automatiquement.

---

## 🎯 Types d'attaques détectées dans ce projet

| Attaque | Description | Règle utilisée |
|---|---|---|
| **Port Scan** | Un attaquant explore les ports ouverts du Pi | `sid:1000001` |
| **SSH Brute Force** | Tentatives répétées de connexion SSH | `sid:1000002` |
| **Telnet IoT** | Protocole non sécurisé ciblant les objets connectés | `sid:1000003` |
| **MQTT non autorisé** | Accès suspect au protocole IoT MQTT (port 1883) | `sid:1000004` |

---

## 🆚 IDS vs IPS — Quelle différence ?

| Mode | Nom complet | Ce qu'il fait |
|---|---|---|
| **IDS** ✅ (utilisé ici) | Intrusion Detection System | Observe et **alerte** uniquement |
| **IPS** | Intrusion Prevention System | Observe et **bloque** automatiquement |

Dans ce projet on utilise le mode **IDS** — suffisant pour détecter et logger les attaques en temps réel.

---

## 📁 Structure du dossier

```
ids/
├── README.md               ← Ce fichier
├── suricata.yaml           ← Fichier de configuration principal
├── rules/
│   └── local.rules         ← Règles IoT personnalisées
└── logs/
    └── alerts_sample.log   ← Exemple de logs d'alertes générés
```

---

## ⚙️ Configuration — suricata.yaml

Le fichier `suricata.yaml` contient la configuration principale de Suricata.  
Les paramètres importants modifiés dans ce projet :

```yaml
# Interface réseau surveillée (câble Ethernet)
af-packet:
  - interface: eth0

# Dossier où Suricata écrit les alertes
default-log-dir: /var/log/suricata/

# Inclusion des règles personnalisées
rule-files:
  - local.rules
```

> ⚠️ **Important :** L'interface `eth0` correspond à la connexion Ethernet du Raspberry Pi.  
> Si ton Pi utilise le WiFi, remplace par `wlan0`.

---

## 📜 Règles personnalisées IoT — local.rules

Les règles Suricata suivent ce format :

```
alert <protocole> <IP_source> <port_source> -> <IP_cible> <port_cible>
(msg:"Description"; options; sid:ID_unique; rev:version;)
```

### Règles utilisées dans ce projet

```
# 1. Détection de scan de ports
alert tcp any any -> $HOME_NET any
(msg:"SCAN Port Scan Detected";
flags:S;
threshold: type threshold, track by_src, count 20, seconds 1;
sid:1000001; rev:1;)

# 2. Détection brute force SSH
alert tcp any any -> $HOME_NET 22
(msg:"SSH Brute Force Attempt";
threshold: type threshold, track by_src, count 5, seconds 60;
sid:1000002; rev:1;)

# 3. Détection connexion Telnet (attaque IoT courante)
alert tcp any any -> $HOME_NET 23
(msg:"TELNET IoT Attack Detected";
flow:to_server;
sid:1000003; rev:1;)

# 4. Détection accès MQTT non autorisé
alert tcp any any -> $HOME_NET 1883
(msg:"Unauthorized MQTT Access";
flow:to_server,established;
sid:1000004; rev:1;)
```

---

## 📊 Exemple de logs d'alertes

Quand Suricata détecte une attaque, il écrit dans `/var/log/suricata/fast.log` :

```
03/12/2026-14:23:11 [**] [1:1000001:1] SCAN Port Scan Detected [**]
[Priority: 3] {TCP} 192.168.50.10:54321 -> 192.168.50.2:8080

03/12/2026-14:25:44 [**] [1:1000002:1] SSH Brute Force Attempt [**]
[Priority: 2] {TCP} 192.168.50.10:45678 -> 192.168.50.2:22

03/12/2026-14:30:02 [**] [1:1000003:1] TELNET IoT Attack Detected [**]
[Priority: 1] {TCP} 192.168.50.10:12345 -> 192.168.50.2:23
```

**Explication d'une ligne d'alerte :**
```
[Date-Heure]  [Priorité]  [Message]  [Protocole]  [IP_attaquant → IP_Pi:Port]
```

---

## 🚀 Commandes utiles

```bash
# Démarrer Suricata
sudo systemctl start suricata

# Vérifier le statut
sudo systemctl status suricata

# Voir les alertes en temps réel
sudo tail -f /var/log/suricata/fast.log

# Tester la configuration
sudo suricata -T -c /etc/suricata/suricata.yaml -v

# Arrêter Suricata
sudo systemctl stop suricata
```

---

## 🔗 Lien avec les autres composantes du projet

```
[Firewall UFW]          [Suricata IDS]         [Modèle ML]
  Bloque les IP    →    Détecte les patterns →  Classifie l'attaque
  suspectes             et génère des alertes   (Normal/DoS/Scan...)
```

Suricata est le **middleware** entre le firewall et le modèle ML :
- Le firewall bloque ce qui est évidemment dangereux
- Suricata analyse ce qui passe et génère des données
- Le modèle ML utilise ces données pour classifier intelligemment

---

## 👩‍💻 Auteure

**Hanane** — Configuration réseau, IDS, et intégration ML  
Projet : **PiGuard** — IoT Intrusion Detection System sur Raspberry Pi
