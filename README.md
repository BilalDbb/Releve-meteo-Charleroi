# Relevé Méteo à l'aéroport de Charleroi
Rstat - Les données concernent les relevés météo enregistrés à l’aéroport de Charleroi (Bruxelles Sud).
Ce en quoi consite ce projet:
- Calcul de la moyenne, l’écart-type, le minimum et le maximum de l’humidité relative par mois en créant un vecteur "date".
- Création d'une fonction qui aura pour argument la variable choisie, le vecteur qui défini la temporalité et le vecteur contenant le label selon la variable.
- Application de la fonction crée au point précédent pour calculer les staistiques descriptives par mois de la variable U et T du dataset initial.
- Création d'un graphique présentant l'évolution mensuelle de l'humidité et de la température. 
- Comparer les points de rosée (variable Td) et les comparer avec chacun des modèles suivant (issus de la littérature) pour déterminer lequel est le meilleur. Des valeurs théoriques seront générées et comparées via l'écart moyen des erreurs (MSE) et le meilleur modèle sera celui avec le plus petit score.

![image](https://user-images.githubusercontent.com/43625844/172031065-6d46df25-d906-4173-8c82-d0e0efd2b070.png)

(Note: ln est le logarithme en base e=exp(1), T est la température et U est l’humidité relative).

![image](https://user-images.githubusercontent.com/43625844/172031080-aed0ed09-f21d-433a-939a-b4cfabb78f98.png)

- Application de la fonction nlm() pour tenter de réestimer les valeurs des paramètres en minimisant le MSE, puis itérer sur les modèles 1 et 2.





  

