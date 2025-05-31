Parcel Delivery App
Une application mobile de livraison de colis à Cotonou, inspirée de Gozem. Développée en Flutter avec une interface moderne et sobre, elle permet aux utilisateurs de s'inscrire, se connecter, créer des livraisons, suivre leur progression, et gérer leur profil.
Fonctionnalités

Inscription et connexion : Authentification sécurisée via une API.
Création de livraisons : Formulaire pour ajouter une nouvelle livraison.
Liste des livraisons : Affichage des livraisons en cours et terminées.
Suivi en temps réel : Intégration de Google Maps pour suivre les livraisons.
Profil utilisateur : Affichage des informations et déconnexion.

Installation

Clonez le dépôt : git clone https://github.com/carnell0/parcel_delivery.git
Installez les dépendances : flutter pub get
Configurez le backend (Django/PostgreSQL) avec les endpoints /api/register, /api/login, et /api/parcels.
Lancez l'application : flutter run

Technologies

Frontend : Flutter, Provider, Google Maps, Google Fonts, Animate Do
Backend : Django, PostgreSQL (non inclus dans ce dépôt)

UI
L'interface utilise une palette bleu nuit (#1A237E) et doré (#FBC02D), avec la police Poppins pour une apparence élégante et moderne. Les animations fluides (via Animate Do) et une barre de navigation inférieure assurent une expérience utilisateur intuitive.
