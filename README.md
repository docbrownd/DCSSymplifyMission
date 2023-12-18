# DCS Simplify Mission

## Description

DCS Simplify Mission (DSM) est un ensemble de scripts conçus pour faciliter la création de missions de type conquête avec persistance, capture de base, CAP adaptatives, Reconnaissance de cible, Bombardement de base et plus encore.

DSM se décompose en 2 scripts à charger : le premier (DCSSimplifyMission) contient l'ensemble des class (dont Moose et Mist) qui peuvent être utilisées, le second correspond à la mission en elle-même.

## Installation

Charger le script DCSSimplifyMission.lua en déclenchement unique sur un temps supérieur à 1s.
Charger ensuite votre script de mission sur un second déclencheur à 10s.

## Unités requises au niveau de l'éditeur

Il est nécessaire d'ajouter des unités en activation retardées au niveau de l'éditeur et de respecter la syntaxe pour le nom du groupe. Ces groupes seront utilisés pour faire spawn les unités aériennes, au sol et des systèmes de capture : 

    - MOOSERED : une unité au sol, le type importe peu
    - MLRS : une unité au sol => unité qui spawn à la capture de base, à vous de voir ce que vous voulez mettre 
    - MLRS capture : une unité au sol => unité qui spawn dans le cas des captures automatiques (sans C17), à vous de voir ce que vous voulez mettre 
    - Plane Template : une unité aérienne,  utilisée pour la CAP et les tankers/Awacs, le type importe peu
    
Au délà de ces unités obligatoires, il sera nécessaire d'en ajouter (toujours en activation retardée) dans certains cas qui sont décrits plus bas.


## Principes génériques du script Mission

Le script de mission est à faire pour chaque mission (alors que DCSSimplifyMission doit juste être chargé). Différents modules peuvent être utilisés, certains sont indépendants : ils contiennent une fonction Init().  D'autres modules ne sont qu'une description et doivent être utilisés via d'autres modules plus larges. 



## Descriptions des différents modules

### Persistance (class PWS)
Ce module gère la persistance, c'est-à-dire la sauvegarde des unités détruites, des unités spawned ainsi que les marqueurs liés à la reconnaissance. Comme souvent cela ne marche que si vous mettiez en commentaire (ajout de -- avant les lignes) les lignes suivantes dans Eagle Dynamics\DCS World OpenBeta\Scripts\MissionScripting.lua : 
`
    sanitizeModule('os')
	sanitizeModule('io')
	sanitizeModule('lfs')
`

#### Utilisation
 - Constructeur : `local peristance = PWS:New("Fichier")` : le texte passé en paramètre correspond au préfix des fichiers de sauvegarde. Ici les fichiers seront nommés : Fichier_PWS_Units.lua, Fichier_PWS_Spawned.lua, Fichier_PWS_Statics.lua, Fichier_PWS_MarkReco.lua (respectivement pour les unités détruites, spawned, les static et la reconnaissance. Les fichiers seront sauvés dans le dossier Missions/_PWS_Saves)
 - Initialisation : `peristance:Init()` : tant que cette ligne n'est pas appelée, la persistance ne foncitonnera pas

### Reconnaissance 


### Tacan


### Artillerie



### Capture de base 


#### Capture automatique 


#### Capture par C17


#### Recapture de base par des unités Red - sol


#### Recapture de base par des unités Red - air




### Reaper 

#### Reaper classique

#### Reaper avec autolase


### Class IA

(description)

#### Tankers


#### Awacs

#### Bombardement 

#### Tomahawk (depuis un porte avion)



#### Informations PA


### CAP


### Menu Communication


