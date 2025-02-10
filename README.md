# 📱 Météo Mobile

**Une application météo simple en C++ et QML démontrant l'utilisation de Qt pour interagir avec des API REST.**  

Cette application a été développée dans le cadre d'un apprentissage personnel. Elle répondait parfaitement aux exigences, permettant ainsi de rechercher une ville et d'obtenir une prévision météo (plus ou moins précise) pour les 5 prochains jours.  

---

## 🌟 Fonctionnalités  

### 📍 Au démarrage de l'application :  
- Votre position est détectée via **GPS** (si l'autorisation a été accordée).  
- Si l'accès au GPS est refusé :  
  - L'application tente de charger les données météorologiques du **dernier emplacement utilisé**.  
  - Si cela échoue, une **recherche manuelle** d’un emplacement vous sera proposée.  

### 🔍 Recherche d'un emplacement spécifique :  
- En raison des **limitations de l'API**, certaines petites localités peuvent ne pas être disponibles.  
- Il peut être nécessaire d’essayer un **lieu plus grand** à proximité pour obtenir une prévision approximative.  

### ⛅ Prévisions météo :  
- **Conditions actuelles** et prévisions pour les **5 jours à venir**.  
- Possibilité de basculer entre :  
  - **Un aperçu rapide** (état météo actuel + températures du jour).  
  - **Une prévision détaillée** (humidité, vent, lever/coucher du soleil, etc.).  

### ⭐ Favoris :  
- Enregistrez un **emplacement favori** pour un accès rapide.  
- Accédez-y via le **tiroir latéral** (balayez depuis le bord gauche de l'écran).  

### 🌍 Support multilingue :  
- Actuellement disponible en **anglais**.  

---

🚀 **Prêt à explorer la météo avec Qt ?**  
