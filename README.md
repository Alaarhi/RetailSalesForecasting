# RetailSalesForecasting
Retail Sales Forecasting of 45 shops in different regions 


On va traiter l’historiques de ventes de 45 magasins situés dans différentes régions à travers ces 3 bases
de données :
- Stores :
Informations anonymisées sur les 45 magasins, indiquant le type et la taille du magasin

- Features :
Contient des données supplémentaires relatives au magasin, au département et à l'activité régionale
pour les dates données.
  * Store - le numéro de magasin
  * Date - la semaine
  *  Temperature - température moyenne dans la région
  *  Fuel_Price - coût du carburant dans la région
  *  MarkDown1-5 - données anonymisées relatives aux démarques promotionnelles. Toute valeur manquante est marquée avec un NA
  *  IPC - l'indice des prix à la consommation
  *  Unemployment - le taux de chômage
  *  IsHoliday - si la semaine est une semaine de vacances spéciale

- Sales :
Les ventes allant du 2010-02-05 au 2012-11-01.
  *  Store - le numéro de magasin
  *  Dept - le numéro de département
  *  Date - la semaine
  *  Weekly_Sales - ventes pour le département donné dans le magasin donné
  *  IsHoliday - si la semaine est une semaine de vacances spéciale
