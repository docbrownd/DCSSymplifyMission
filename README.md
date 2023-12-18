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

    sanitizeModule('os')
    sanitizeModule('io')
    sanitizeModule('lfs')

#### Utilisation
 - Constructeur : `local peristance = PWS:New("Fichier")` : le texte passé en paramètre correspond au préfix des fichiers de sauvegarde. Ici les fichiers seront nommés : Fichier_PWS_Units.lua, Fichier_PWS_Spawned.lua, Fichier_PWS_Statics.lua, Fichier_PWS_MarkReco.lua (respectivement pour les unités détruites, spawned, les static et la reconnaissance. Les fichiers seront sauvés dans le dossier Missions/_PWS_Saves)
 - Autoriser la sauvegarde de la reconnaissance : `peristance:SaveReco()` (non activé par défaut)
 - Initialisation : `peristance:Init()` : tant que cette ligne n'est pas appelée, la persistance ne fonctionnera pas. Cette ligne doit être appelée après les éventuelles functions décrites ci-après.

#### Options supplémentaires
La class PWS fournit d'autres functions qui vous permet d'ajuster certaines paramètres si besoin. 

#### Temps entre 2 sauvegardes
Par défaut la sauvegarde se faut toutes les 5 min, il est possible de modifier cette durée via la function `:SetSaveSchedule(temps_en_seconde)`

#### Désactivé la sauvegarde des unités red/bleu

Par défaut toute unité qui est détruite ou qui apparait est sauvegardée (sauf cas d'exclusion, voir si-après), mais il est possible d'ajuster en fonction de votre mission : 

  - `:SaveDeadBlue(bool)` : activer (true, par défaut) ou désactiver (false) la sauvegarde des unités bleues détruites
  - `:SaveDeadRed(bool)` : activer (true, par défaut) ou désactiver (false) la sauvegarde des unités reds détruites
  - `:SaveBirthBlue(bool)` : activer (true, par défaut) ou désactiver (false) la sauvegarde des unités bleues qui ont spawned
  - `:SaveBirthRed(bool)` : activer (true, par défaut) ou désactiver (false) la sauvegarde des unités reds qui ont spawned
  

##### Exclure des unités (par type ou par nom)

Par défaut, certaines unités sont exclus du système de persistance, cela permet notamment d'avoir des unités qui vont respawn à chaque restart du serveur (pour des zones d'entraintement par exemple ou pour éviter de trop modifier le gameplay si un PA est coulé). 
Pour les unités détruites, par défaut le type CVN n'est pas enregistrés, de même que les unités qui portent l'un des préfix suivants : 

	"Wounded Pilot", 
 	"TTGT", 
  	"ttgt", 
   	"Training target",
	"Procedural"
     
Pour les unités qui apparaissent, par défaut les unités qui portent l'un des préfix suivants sont exclues : 

	"Wounded Pilot", 
 	"TTGT", 
  	"ttgt", 
   	"Training target",
	"Procedural"
 
La class PWS vous permet d'ajouter des unités ou des types d'unités qui seront alors exclues, soit en cas de destruction de l'unité, soit en cas d'apparition (spawn) : 

  - `:AddToDeadExcludeType(type)` : ajoute un type d'unité dans la liste d'exclusion des unités détruites 
  - `:AddToDeadExclude(name)` : ajoute une unité dans la liste d'exclusion des unités détruites 
  - `:AddToBirthExclude(name)` : ajoute une unité dans la liste d'exclusion des unités spawn 
  

### Reconnaissance (class ReconClass)
Ce module est une réécriture en POO et une adaptation du code provenant du serveur Enigma (https://github.com/Enigma1989YT/Enigma-Cold-War-V1-Public/blob/main/scripts/recon.lua). 
Ce système permet d'ajouter des marqueurs en vue F10 avec le type et les coordonnées d'une unité. Pour cela un joueur doit : 
 - sloter dans un avion sans l'armer (y compris les balles) (il est en revanche possible d'ajouter bidons et pods)
 - au décollage, un mesage indiquera que la reconnaissance est disponible
 - le fonctionnement est le suivant : le script s'active via le menu communication, il tourne pendant 90s au maximun (il est possible de le mettre en pause) et enregistre les cibles vues par l'appareil en fonction de plusieurs paramètres :
  - l'altitude de l'avion. Plus l'avion est haut, plus il voit loin. Il ne faut en revanche pas dépasser 10km (~30k pieds)
  - l'offset du "pod de reconnaissance" de l'appareil
  - l'altitude et l'offset permettent de calculer la zone où pointe le "pod de reconnaissance"  (+/- 40Nm avec les paramètres par défaut si l'avion est à 10km), le pod va de son côté avoir un champ de vision propre dépendant de l'altitude. Seules les unités se trouvant dans ce champ de vision seront enregistrées. Ainsi par défaut, à l'altitude maximal, un appareil va enregistrer les unités se trouvant entre 40 et 50Nm devant lui et sera aveugle en-dessous de 40Nm et au délà de 50Nm. 
  - le joueur doit se poser sur sa base de départ pour pouvoir développer le film ( = ajouter des marqueurs avec nom de l'unité et coordonnées GPS au moment du survol)  

#### Utilisation
  - Constructeur : `local recon = ReconClass:New(PWS)` : si la class ReconClass est instanciée avec le nom de la class PWS (persistance) utilisée, les marqueurs seront sauvegardés (il faut en plus avoir activé l'écriture dans le fichier de reco, via `:SaveReco()`
  - Initialisation : `recon:Init()` : tant que cette ligne n'est pas appelée, la reconnaissance ne fonctionnera pas. Cette ligne doit être appelée après les éventuelles functions décrites ci-après.

#### Options supplémentaires

La class ReconClass fournie d'autres functions qui vous permet d'ajuster certaines paramètres si besoin. 

##### Ajouter des appareils

Par défaut la reconnaissance est disponibles pour les appareils suivants : 

 - F15-E
 - F14-B
 - F1
 - M2000
 - F18
 - F16
 - JF17
 - Gazelle SA342M
 - Gazelle SA342L
 - Apache

Il est possible d'ajouter un appareil via `:AddRecoType(obj)`, l'objet doit avoir les attributs suivants : 
 - name : le nom de l'appareil (le nom importe peut, mais il doit être unique)
 - recoType : le type d'appareil pour DCS (exemple pour le F18 : FA-18C_hornet)
   
 - offset : angle en rad pour le calcul de l'offset (par défaut math.rad(83)
 - fov : angle en ° du champ de vision du pod, par défaut 70
 - duration : temps en seconde max de la reconnaissance (90s par défaut)
 - minAlt : altitude minimale pour activer l'enregistrement, en m. Par défaut 50
 - maxAlt : altitude maximale pour activer l'enregistrement, en m. Par défaut 10000
 - maxRoll : roll max en ° pour activer l'enregistrement. Par défaut 8
 - maxPitch : pitch max en ° pour activer l'enregistrement. Par défaut 15

Les valeurs par défaut n'ont pas besoin d'être indiquée. 
Exemple pour l'ajout du F14A : `recon:AddRecoType({name = 'F14', recoType = "F-14A"}) `

##### Ajouter des exceptions
Par défaut les unités ayant les termes suivants dans leur noms ne sont pas identifiables par la reconnaissance: 

 	"blue supply"
	"blue_01_farp"
	"blue_00_farp"
	"red farp supply"
	"red_00_farp"
	"blufor farp"
	"blue_"
	"static farp"
	"static windsock"
	"red supply"
	"red_"

Il est possible d'ajouter des exceptions via la function `:AddException(Nom_a_retirer)` 

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


