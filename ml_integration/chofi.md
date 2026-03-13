# 🤖 ML — Machine Learning pour la Détection d'Attaques IoT

## 📌 C'est quoi ton rôle dans ce projet ?

Tu vas entraîner un **modèle de Machine Learning** capable de reconnaître automatiquement si un trafic réseau est **normal ou une attaque**.

> 💡 **Analogie simple :** Imagine un médecin qui a vu des milliers de patients. Avec le temps, il reconnaît une maladie juste en regardant les symptômes. Ton modèle ML fait pareil — il "apprend" à reconnaître les attaques en analysant des milliers d'exemples de trafic réseau.

---

## 🎯 Objectif concret

Entraîner un modèle qui prend en entrée des **caractéristiques du trafic réseau** et prédit en sortie :

```
Entrée (features du trafic)
        ↓
   [ Modèle ML ]
        ↓
Sortie : "Normal" / "DoS" / "DDoS" / "Port Scan" / "Brute Force"
```

---

## 📊 Le Dataset — TON_IoT

### C'est quoi TON_IoT ?

TON_IoT est un dataset créé par l'**Université UNSW Australia** spécialement pour la sécurité IoT.  
Il contient des enregistrements réels de trafic réseau IoT avec des étiquettes indiquant le type de trafic.

### Téléchargement

🔗 **Lien officiel :** https://research.unsw.edu.au/projects/toniot-datasets

### Ce que contient le dataset

| Colonne | Description | Exemple |
|---|---|---|
| `duration` | Durée de la connexion (secondes) | `0.5` |
| `proto` | Protocole réseau | `tcp`, `udp` |
| `src_bytes` | Octets envoyés par la source | `1024` |
| `dst_bytes` | Octets reçus par la destination | `512` |
| `missed_bytes` | Octets perdus | `0` |
| `src_pkts` | Nombre de paquets source | `10` |
| `dst_pkts` | Nombre de paquets destination | `8` |
| `label` | ✅ La cible à prédire | `normal`, `ddos`, `dos`... |

### Types d'attaques dans le dataset

| Label | Type d'attaque | Description |
|---|---|---|
| `normal` | Trafic normal | Aucune attaque |
| `dos` | DoS | Déni de service — surcharge un serveur |
| `ddos` | DDoS | DoS distribué — vient de plusieurs sources |
| `scanning` | Port Scan | Exploration des ports ouverts |
| `password` | Brute Force | Tentatives de mots de passe |
| `ransomware` | Ransomware | Chiffrement malveillant |
| `backdoor` | Backdoor | Porte dérobée installée |
| `xss` | XSS | Injection de code web |

---

## 🔄 Les étapes à suivre

### Étape 1 — Installer les librairies

```bash
pip install pandas numpy scikit-learn matplotlib seaborn jupyter
```

### Étape 2 — Charger et explorer le dataset

```python
import pandas as pd
import numpy as np

# Charger le dataset
df = pd.read_csv('TON_IoT_Network.csv')

# Explorer les données
print(df.shape)          # Nombre de lignes et colonnes
print(df.head())         # Les 5 premières lignes
print(df['label'].value_counts())  # Combien d'exemples par type
```

### Étape 3 — Nettoyer les données

```python
# Supprimer les valeurs manquantes
df = df.dropna()

# Supprimer les colonnes inutiles
df = df.drop(columns=['ts', 'src_ip', 'dst_ip', 'src_port', 'dst_port'])

# Encoder le protocole (tcp=0, udp=1, etc.)
from sklearn.preprocessing import LabelEncoder
le = LabelEncoder()
df['proto'] = le.fit_transform(df['proto'])

print("✅ Données nettoyées :", df.shape)
```

### Étape 4 — Préparer les features et la cible

```python
# Features (X) = tout sauf le label
X = df.drop(columns=['label'])

# Cible (y) = le label à prédire
y = df['label']

# Encoder les labels
y_encoded = le.fit_transform(y)

# Sauvegarder les noms des classes (important pour Hanane !)
classes = list(le.classes_)
print("Classes :", classes)
# Exemple : ['backdoor', 'ddos', 'dos', 'normal', 'password', 'ransomware', 'scanning', 'xss']
```

### Étape 5 — Diviser en train/test

```python
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(
    X, y_encoded,
    test_size=0.2,      # 20% pour tester
    random_state=42,    # Pour reproduire les mêmes résultats
    stratify=y_encoded  # Garder les proportions de chaque classe
)

print(f"Entraînement : {X_train.shape[0]} exemples")
print(f"Test         : {X_test.shape[0]} exemples")
```

### Étape 6 — Normaliser les données

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# Sauvegarder le scaler (important pour Hanane !)
import pickle
with open('scaler.pkl', 'wb') as f:
    pickle.dump(scaler, f)

print("✅ Scaler sauvegardé")
```

### Étape 7 — Entraîner le modèle

```python
from sklearn.ensemble import RandomForestClassifier

# Créer et entraîner le modèle
model = RandomForestClassifier(
    n_estimators=100,   # 100 arbres de décision
    random_state=42,
    n_jobs=-1           # Utiliser tous les CPU disponibles
)

model.fit(X_train, y_train)
print("✅ Modèle entraîné !")
```

> 💡 **Pourquoi Random Forest ?**  
> C'est un algorithme robuste, rapide, et qui donne d'excellents résultats sur les données réseau.  
> Il combine plusieurs arbres de décision pour prendre la meilleure décision.

### Étape 8 — Évaluer le modèle

```python
from sklearn.metrics import classification_report, accuracy_score

y_pred = model.predict(X_test)

# Accuracy globale
accuracy = accuracy_score(y_test, y_pred)
print(f"✅ Accuracy : {accuracy:.2%}")

# Rapport détaillé par type d'attaque
print(classification_report(y_test, y_pred, target_names=classes))
```

**Tu dois voir quelque chose comme :**
```
              precision    recall  f1-score
    normal       0.99      0.98      0.99
       dos       0.97      0.96      0.97
      ddos       0.98      0.99      0.98
  scanning       0.95      0.94      0.95
  password       0.93      0.92      0.92

  accuracy                           0.97
```

### Étape 9 — Sauvegarder le modèle

```python
import pickle

# Sauvegarder le modèle
with open('model.pkl', 'wb') as f:
    pickle.dump(model, f)

# Sauvegarder la liste des features (TRÈS IMPORTANT pour Hanane !)
feature_names = list(df.drop(columns=['label']).columns)
with open('features.txt', 'w') as f:
    for feature in feature_names:
        f.write(feature + '\n')

# Sauvegarder les labels
with open('labels.txt', 'w') as f:
    for label in classes:
        f.write(label + '\n')

print("✅ model.pkl sauvegardé")
print("✅ features.txt sauvegardé")
print("✅ labels.txt sauvegardé")
print(f"\nFeatures utilisées ({len(feature_names)}) :")
for f in feature_names:
    print(f"  - {f}")
```

---

## 📦 Fichiers à donner à Hanane

> ⚠️ **TRÈS IMPORTANT** — Hanane a besoin de ces 3 fichiers pour intégrer ton modèle sur le Raspberry Pi

| Fichier | Description | Obligatoire |
|---|---|---|
| `model.pkl` | Le modèle entraîné | ✅ Oui |
| `scaler.pkl` | La normalisation des données | ✅ Oui |
| `features.txt` | Liste des features dans le bon ordre | ✅ Oui |
| `labels.txt` | Liste des labels (Normal, DoS...) | ✅ Oui |

---

## 📁 Structure de ton dossier

```
ml/
├── README.md                  ← Ce fichier
├── notebooks/
│   └── train_model.ipynb      ← Jupyter Notebook d'entraînement
├── data/
│   └── TON_IoT_Network.csv    ← Dataset (ne pas uploader sur GitHub !)
├── model/
│   ├── model.pkl              ← Modèle entraîné ✅
│   ├── scaler.pkl             ← Normalisation ✅
│   ├── features.txt           ← Liste des features ✅
│   └── labels.txt             ← Liste des labels ✅
└── results/
    ├── accuracy.png           ← Graphique de précision
    └── confusion_matrix.png   ← Matrice de confusion
```

---

## 📊 Visualisations à faire (pour LinkedIn 🔥)

### Matrice de confusion

```python
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import confusion_matrix

cm = confusion_matrix(y_test, y_pred)

plt.figure(figsize=(10, 8))
sns.heatmap(cm, annot=True, fmt='d',
            xticklabels=classes,
            yticklabels=classes,
            cmap='Blues')
plt.title('Matrice de Confusion — PiGuard ML Model')
plt.ylabel('Réel')
plt.xlabel('Prédit')
plt.tight_layout()
plt.savefig('results/confusion_matrix.png')
plt.show()
```

### Importance des features

```python
importances = model.feature_importances_
indices = np.argsort(importances)[::-1][:10]  # Top 10

plt.figure(figsize=(10, 6))
plt.bar(range(10), importances[indices])
plt.xticks(range(10), [feature_names[i] for i in indices], rotation=45)
plt.title('Top 10 Features les plus importantes')
plt.tight_layout()
plt.savefig('results/feature_importance.png')
plt.show()
```

---

## ✅ Checklist finale

Avant de donner le modèle à Hanane, vérifie :

- [ ] Le modèle a une accuracy > 90%
- [ ] `model.pkl` est généré
- [ ] `scaler.pkl` est généré
- [ ] `features.txt` contient les features dans le bon ordre
- [ ] `labels.txt` contient tous les labels
- [ ] Tu as testé que le modèle prédit correctement sur quelques exemples
- [ ] Tu as partagé les 4 fichiers avec Hanane

---

## 👩‍💻 Auteure

**[Ton prénom]** — Entraînement du modèle ML sur dataset TON_IoT  
Projet : **PiGuard** — IoT Intrusion Detection System sur Raspberry Pi
