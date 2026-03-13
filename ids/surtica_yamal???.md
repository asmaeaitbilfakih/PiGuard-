# ⚙️ suricata.yaml — Explication du fichier de configuration

## 📌 C'est quoi ce fichier ?

`suricata.yaml` est le **fichier de configuration principal de Suricata**.  
Il contrôle tout le comportement de Suricata : quelle interface écouter, où écrire les logs, quels protocoles analyser, et quelles règles charger.

> 💡 **Analogie simple :** C'est comme le tableau de bord d'une voiture — tous les réglages importants sont là.

---

## 🗂️ Structure générale du fichier

```
suricata.yaml
│
├── 1. VARS          → Définit les IPs et ports du réseau
├── 2. OUTPUTS       → Où et comment écrire les logs
├── 3. AF-PACKET     → Quelle interface réseau écouter
├── 4. APP-LAYER     → Quels protocoles analyser
├── 5. RULES         → Quels fichiers de règles charger
└── 6. ADVANCED      → Performances, mémoire, threads...
```

---

## 1️⃣ VARS — Définition du réseau

```yaml
vars:
  address-groups:
    HOME_NET: "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]"
    EXTERNAL_NET: "!$HOME_NET"
```

### C'est quoi ?

| Variable | Valeur | Signification |
|---|---|---|
| `HOME_NET` | `192.168.0.0/16` ... | Ton réseau local — là où se trouve ton Pi |
| `EXTERNAL_NET` | `!$HOME_NET` | Tout ce qui n'est PAS ton réseau = internet = attaquants potentiels |

> Le `!` devant `$HOME_NET` veut dire **"tout sauf HOME_NET"**

### Pourquoi c'est important ?

Ces variables sont utilisées dans toutes tes règles de détection :

```
any -> $HOME_NET    =  quelqu'un attaque TON réseau  🚨
$HOME_NET -> any    =  quelqu'un de ton réseau attaque dehors  🚨
```

---

## 2️⃣ OUTPUTS — Les logs

```yaml
outputs:
  - fast:
      enabled: yes
      filename: fast.log

  - eve-log:
      enabled: yes
      filename: eve.json
```

### C'est quoi ?

Suricata écrit les alertes dans 2 fichiers différents :

| Fichier | Format | Contenu | Usage |
|---|---|---|---|
| `fast.log` | Texte simple | Une ligne par alerte | Facile à lire, idéal pour monitoring |
| `eve.json` | JSON | Toutes les infos détaillées | Pour analyse approfondie |

### Où sont ces fichiers sur le Pi ?

```
/var/log/suricata/fast.log    ← alertes simples  (on lit celui-là)
/var/log/suricata/eve.json    ← alertes détaillées en JSON
```

### Exemple d'une alerte dans fast.log

```
03/12/2026-14:23:11 [**] [1:1000001:1] SCAN Port Scan Detected [**]
[Priority: 3] {TCP} 192.168.50.10:54321 -> 192.168.50.2:8080
```

---

## 3️⃣ AF-PACKET — Interface réseau ✏️ MODIFIÉE

```yaml
af-packet:
  - interface: eth0    # ← MODIFIÉ dans ce projet
    cluster-id: 99
    cluster-type: cluster_flow
    defrag: yes
```

### C'est quoi AF-PACKET ?

AF-PACKET est le **mode de capture réseau** de Suricata sur Linux.  
Il dit à Suricata sur quelle interface réseau il doit **écouter et capturer le trafic**.

### La modification qu'on a faite

| | Valeur | Statut |
|---|---|---|
| **Avant** | `interface: eth2` | ❌ N'existe pas sur le Pi |
| **Après** | `interface: eth0` | ✅ Câble Ethernet actif |

### Pourquoi eth0 ?

En tapant `ip addr show` sur le Pi, on a vu :

```
eth0  → state UP → 192.168.50.2   ✅ câble branché et actif
wlan0 → state DOWN                ❌ WiFi éteint, inutilisé
```

> ⚠️ **Si on laissait eth2 :** Suricata démarrerait mais ne verrait **aucun trafic** car cette interface n'existe pas sur notre Pi.

---

## 4️⃣ APP-LAYER — Protocoles analysés

```yaml
app-layer:
  protocols:
    mqtt:
      enabled: yes
    tls:
      enabled: yes
    ssh:
      enabled: yes
    http:
      enabled: yes
    dns:
      enabled: yes
```

### C'est quoi ?

Suricata ne regarde pas que les paquets bruts — il **comprend et analyse le contenu** des protocoles réseau.

### Protocoles importants pour ce projet IoT

| Protocole | Port | Pourquoi surveillé |
|---|---|---|
| `mqtt` | 1883 | Protocole IoT — souvent ciblé par les attaquants |
| `ssh` | 22 | Détecter les tentatives de brute force |
| `http` | 80 | Surveiller le trafic web |
| `tls` | 443 | Surveiller les connexions chiffrées |
| `dns` | 53 | Détecter les requêtes DNS suspectes |

---

## 5️⃣ RULE-FILES — Fichiers de règles ✏️ MODIFIÉE

```yaml
default-rule-path: /etc/suricata/rules

rule-files:
  - suricata.rules    # règles officielles
  - local.rules       # ← AJOUTÉ dans ce projet
```

### C'est quoi ?

C'est la **liste des fichiers de règles** que Suricata charge au démarrage.  
Chaque fichier contient des règles qui décrivent des patterns d'attaques à détecter.

### La modification qu'on a faite

**Avant :**
```yaml
rule-files:
  - suricata.rules    # seulement les règles officielles
```

**Après :**
```yaml
rule-files:
  - suricata.rules    # règles officielles ✅
  - local.rules       # + nos règles IoT personnalisées ✅
```

### Pourquoi c'est important ?

| Fichier | Contenu | Créé par |
|---|---|---|
| `suricata.rules` | Milliers de règles officielles de la communauté | Suricata/communauté |
| `local.rules` | Règles IoT personnalisées pour ce projet | Nous ✅ |

> ⚠️ **Sans cette ligne :** Suricata n'aurait jamais chargé nos règles IoT — même si on les crée, elles seraient ignorées !

---

## 6️⃣ ADVANCED — Paramètres avancés

Ces paramètres contrôlent les performances de Suricata sur le Raspberry Pi.

```yaml
# Mémoire allouée pour le suivi des flux réseau
flow:
  memcap: 128mb

# Mémoire pour la reconstruction des flux TCP
stream:
  memcap: 64mb
  reassembly:
    memcap: 256mb

# Nombre de threads de détection
threading:
  detect-thread-ratio: 1.0    # 1 thread par CPU core
```

> 💡 Ces valeurs sont adaptées pour un Raspberry Pi — pas besoin de les modifier.

---

## 📊 Résumé des modifications faites dans ce projet

| # | Section | Avant | Après | Raison |
|---|---|---|---|---|
| 1 | `af-packet` | `interface: eth2` ❌ | `interface: eth0` ✅ | eth0 = câble Ethernet actif du Pi |
| 2 | `rule-files` | `suricata.rules` seulement | + `local.rules` ✅ | Pour charger nos règles IoT |

---

## 🔄 Ce qui se passe au démarrage de Suricata

```
sudo systemctl start suricata
         ↓
Suricata lit suricata.yaml
         ↓
"Interface à écouter : eth0"        ← modification 1
         ↓
"Règles à charger : suricata.rules
                  + local.rules"    ← modification 2
         ↓
Suricata analyse tout le trafic sur eth0
         ↓
Alerte détectée → écrit dans /var/log/suricata/fast.log
```

---

## 🚀 Commandes utiles

```bash
# Tester que la configuration est valide
sudo suricata -T -c /etc/suricata/suricata.yaml -v

# Démarrer Suricata
sudo systemctl start suricata

# Voir les alertes en temps réel
sudo tail -f /var/log/suricata/fast.log

# Vérifier les modifications
grep "interface" /etc/suricata/suricata.yaml
grep "local.rules" /etc/suricata/suricata.yaml
```

---

## 👩‍💻 Auteure

**Hanane** — Configuration réseau, IDS, et intégration ML  
Projet : **PiGuard** — IoT Intrusion Detection System sur Raspberry Pi
