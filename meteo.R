# Initialisation ----------------------------------------------------------

rm(list = ls())

#install.packages("conflicted")
library(conflicted)
#install.packages("hms") 
library(hms)

path <- "C:\\Users\\bilal\\OneDrive\\Bureau\\portfolio\\rosée\\"
setwd(path)


# Partie A: extraction des données ----------------------------------------

## Importation ------------------------------------------------------------

meteo <- read.csv2(paste(path, "meteo.csv", sep = ""), header = TRUE, sep = ";", dec = '.', skip = 6)

## Extraction vectorielle des éléments de la variable "Local  time" -------

jour = substr(meteo[, 1], 1, 2)
mois = substr(meteo[, 1], 4, 5)
annee = substr(meteo[, 1], 7, 10)

## Création date&time à partir de l'extraction vectorielle ----------------

date = as.Date(paste(annee, mois, jour, sep = "-"))
meteo$date = date

hours = as.numeric(substr(meteo[, 1], 12, 13))
minutes = as.numeric(substr(meteo[, 1], 15, 16))
meteo$time <- hms(minutes = minutes, hours = hours)

## Insertion des variables utiles dans le nouveau ds puis sauvegarde ------

meteo <- meteo[, c(2, 4, 6, 23, 30, 31)]

save(meteo,file = paste(path, "meteo.Rda", sep = ""))


# Partie B: stat descriptives ---------------------------------------------

## Chargement de meteo ----------------------------------------------------

load(paste(path, "meteo.Rda", sep = ""))

## Fonction 1 cf.ReadMe ---------------------------------------------------

StatDesc = function(varname, splitcol, titre) {
    Res = NULL
    for (fun in c('mean', 'sd', 'min', 'max')) {
    Res = rbind(Res, tapply(varname, splitcol, fun, na.rm = TRUE))
    }
  
  rownames(Res) = c('Moyenne', 'Ecart-type', 'Minimum', 'Maximum')
  colnames(Res) = paste(levels(as.factor(splitcol)))
  cat('========================================================== \n')
  cat("Statistiques par", titre[2], "de la variable", titre[1], "\n") 
  cat('---------------------------------------------------------- \n')
  print(round(Res, 2))
  cat('========================================================== \n')
  return(round(Res, 2))
}

## Formatage de la variable "date" ----------------------------------------

date <- format(as.Date(meteo$date), "%Y-%m")

## Exemple + préparation graphique ----------------------------------------

titre = c("Humidité", "mois")
X1 = StatDesc(meteo$U, date, titre)
titre = c("Température", "mois")
X2 = StatDesc(meteo$T, date, titre)

## Graphique de l'évolution mensuelle de l'humidité et de la t° -----------

par(mfrow = c(1, 1))
par(mar = c(6, 4, 4, 8) + 0.1)

toprint = levels(as.factor(date)) 

plot(seq(1, length(toprint)), X1[1, ], type = "b", col = "red", pch = 1, xlab = "", ylab = "", axes = FALSE, ylim = c(0, 100))
axis(1, at = seq(1, length(toprint)), labels = toprint, las = 2)
axis(2, las = 1, col = "red")
par(new = TRUE)
plot(seq(1, length(toprint)), X2[1, ], type = 'b', col = "blue", pch = 4, ylim = c(0, 50), axes = FALSE, xlab = "", ylab = "")
axis(4, at = seq(0, 50, by = 5), las = 2, col = "blue")
mtext("Température moyenne mensuelle", side = 4, las = 0, col = "black", line = 2)
mtext("Mois", side = 1, las = 0, col = "black",line = 4)
title("Evolution mensuelle de l'humidité et de la température", xlab = "",
      ylab = "Humidité relative moyenne mensuelle")

## Exportation des statistiques descriptives ------------------------------

write.csv(X1, paste(path,"X1_U.csv", sep = ""))
write.csv(X2, paste(path,"X2_T.csv", sep = ""))


# Partie C: modélisation --------------------------------------------------

## Comparaison valeurs réelles avec modèles issus de la littérature -------

### Calcul du point de rosée avec modèle 1 --------------------------------

rosee1 = function(T, H, a = 17.27, b = 237.7) {
  alpha = (a * T/(b + T)) + log(H / 100, base = exp(1))
  Td = (b * alpha) / (a - alpha)
  return(Td)
}

### Calcul du point de rosée avec modèle 2 --------------------------------

rosee2 = function(T, H, c = 112, d = 0.9) {
  Td = ((H / 100) ^ (1 / 8)) * (c + (d * T)) + ((1 - d) * T) - c
  return(Td)
}


### Point de rosée théorique pour chaque valeur de T et  ------------------

T1 = rosee1(meteo$T, meteo$U)
T2 = rosee2(meteo$T, meteo$U)

#### Graphique ------------------------------------------------------------

plot(T1, T2)
plot(meteo$Td, T1)
plot(meteo$Td - T1)
points(meteo$Td - T2, col = "red")

### Calcul des MSE --------------------------------------------------------

MSE <- function(T1, T2) {
  MSE = mean((T1 - T2) ^ 2, na.rm = T)
  return(MSE)
}

MSE(meteo$Td, T1)
MSE(meteo$Td, T2)

#### => On voit que modèle 2 est meilleur ---------------------------------

## Recalcul de a, b, c et de pour minimisation du MSE via nlm() -----------

### Fonctions d'optimisation modèle 1  ------------------------------------

optim1 <- function(param) {
  Tr = rosee1(meteo$T, meteo$U, param[1], param[2])
  x = MSE(meteo$Td, Tr)
  print(x)
  return(x)
}

### Fonctions d'optimisation modèle 2  ------------------------------------

optim2 <- function(param) {
  Tr = rosee2(meteo$T, meteo$U, param[1], param[2])
  x = MSE(meteo$Td, Tr)
  print(x)
  return(x)
}

### Paramétrisation des variables pour chaque fonction --------------------

res1 = nlm(optim1, c(17.27, 237.7))$estimate
res2 = nlm(optim2, c(112, 0.9))$estimate

### Recalcul du point de rosée pour chaque modèle -------------------------

Tfinal1 = rosee1(meteo$T, meteo$U, a = res1[1], b = res1[2])
Tfinal2 = rosee2(meteo$T, meteo$U, c = res2[1], d = res2[2])

### Graphique et calcul des nouveaux MSE ----------------------------------

plot(meteo$Td, Tfinal1)

MSE(meteo$Td, Tfinal1)
MSE(meteo$Td, Tfinal2)

#### => Les nouvelles valeurs de a,b, c et d donnent un meilleur MSE ------


