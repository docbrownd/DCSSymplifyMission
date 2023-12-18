# DCS Simplify Mission

## Description

DCS Simplify Mission (DSM) est un ensemble de scripts conçus pour faciliter la création de missions de type conquête avec persistance, capture de base, CAP adaptatives, Reconnaissance de cible, Bombardement de base et plus encore.

DSM se décompose en 2 scripts à charger : le premier (DCSSimplifyMission) contient l'ensemble des class (dont Moose et Mist) qui peuvent être utilisées, le second correspond à la mission en elle-même. 
L'ensemble des options disponibles sont décrits ci-après, et un exemple d'un script Mission (pour la map Sinai) est disponible dans le dossier /example (il peut être plus facile dans un premier temps de regarder le script).

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
Les différents modules sont décrits ci-après, tant au niveau du gameplay que pour leur utilisation (au sens 'utilisation dans le script de mission').


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
La class PWS fournit d'autres functions qui vous permet d'ajuster certains paramètres si besoin. 

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

La class ReconClass fournit d'autres functions qui vous permet d'ajuster certains paramètres si besoin. 

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

### Splash Damage (class SplashDamageClass)
Cette fonction est une réécriture en POO et une adaptation du script splash_damage (https://github.com/spencershepard/DCS-Scripts/blob/master/Splash_Damage_2_0.lua) qui permet de simuler l'effet de souffle d'une bombe à son impacte, ce qui augmente l'intérêt pour l'ututlisation des bombes lisses.

#### Utilisation
  - Constructeur : `local splash = SplashDamageClass:New()`
  - Initialisation : `splash:Init()` : tant que cette ligne n'est pas appelée, le splash damage ne fonctionnera pas. Cette ligne doit être appelée après les éventuelles functions décrites ci-après.
    
#### Options supplémentaires

##### Modifier le niveau de l'effet de souffle d'un armement
Via la fonction `:SetWeaponConfig(weaponName, weaponValue)` il est possible d'ajouter ou de modifier la configuration d'un armement. Le premier paramètre correspond au nom de l'arme dans DCS (exemple une GBU12 : GBU_12), le second paramètre correspond à la puissance de l'effet de souffle. 
Par comparaison, par défaut une mk82 à une valeure de 118 alors qu'une mk84 est à 582

##### Modifier les options du script original
Le script initial vient avec plusieurs configuration qu'il est possible de changer via `:ChangeOption(optionName, optionValue)`

### Tacan (class TacanBase)
Cette class permet de faire spawn des Tacan lorsqu'une base est capturée. Le tacan est ajouté à la position (0,0) de la base, soit généralement en bout de piste. 

#### Utilisation
  - Constructeur : `local tacan = TacanBase:New()`
  - Ajout d'un tacan : `local tacan = TacanBase:AddTacan(obj)`, avec obj comme suit :
   - code : code Tacan qui sera affiché sur les HSI
   - frequency : fréquence du Tacan
   - band : bande du Tacan, X ou Y
   - base : la base liée (tel qu'affiché dans l'éditeur)
   - Exemple :  `tacan:AddTacan({code = 'HZM', frequency = 95, band = 'X', base = Hatzerim)` pour ajouter un tacan 95X sur la base d'Hatzerim 
  - Initialisation : `tacan:Init()` : tant que cette ligne n'est pas appelée, la class Tacan ne fonctionnera pas. Cette ligne doit être appelée en dernier
    

### Artillerie (class GroundArtillery)
Cette class permet d'activer des unités pour les faire tirer sur une base lorsque celle-ci est capturée, comme des sites scud ou des unités Smerch. 
Cette class doit être à la fois initialisée et utilisée de concert avec la class CaptureAirBase pour fonctionner.
Le groupe va prendre pour cible un point choisi aléatoirement dans la zone autour de la base. La précision est donc toutes relative.



#### Utilisation
  - Constructeur : `local artillery = GroundArtillery:New()`
  - Ajout d'un tacan : `artillery:AddGroundShootIf(unit, airbase)`, avec unit le nom du groupe à contrôler, airbase le nom de la base (tel qu'affiché dans l'éditeur) ciblée. Exemple : `artillery:AddGroundShootIf("Scud1", "Ramon Airbase")` va activer le groupe Scud1 et lui faire cibler la base Ramon Airbase
  - Initialisation : `artillery:Init()` : tant que cette ligne n'est pas appelée, la class ne fonctionnera pas. Cette ligne doit être appelée en dernier
    


### Capture de base (class CaptureAirBase)
Il s'agit de l'une des class les plus complexes car elle gère plusieurs parties du game play :
 - la capture de base par C17
 - le spawn d'unité de capture
 - le spawn de défense au posé du C17
 - l'activation de l'artillerie ennemie
 - la recapture de base par des convois (au sol ou aéroportés) ennemis

Concernant la capture de base, pour limiter la charge serveur, les bases ne sont scannées qu'à raison d'une base toutes les minutes. Si vous ajoutez 20 bases, la dernière ne sera donc scannée qu'au bout de 20 min de jeu

#### Utilisation
  - Constructeur : `MyCapture = CaptureAirBase:New(PWS)` : la class a besoin de la class PWS pour fonctionner correctement. Vous DEVEZ donc lui passer la variable contenant cette class (Persistance ici)
  - Initialisation : `MyCapture:Init()` : tant que cette ligne n'est pas appelée, la class ne fonctionnera pas. Cette ligne doit être appelée après les éventuelles functions décrites ci-après.

#### Ajouter une base à capturer par C17
`MyCapture:AddbaseToCapture(obj)` permet d'ajouter une base qui sera capturée par C17 (seul avion disponible pour le moment), avec obj un objet contenant : 

 - base : le nom de la base (tel qu'indiqué dans l'éditeur)
 - baseStart : le nom de la base de départ pour le C17 (tel qu'indiqué dans l'éditeur), attention la base doit être assez grande pour accueillir les C17 
 - plane = "C-17", pour le moment pas d'autres options disponibles
 - groupPop : le nom du groupe qui popera une fois que le C17 sera posé (et uniquement dans ce cas), en règle général un site SAM. Le nom doit correspondre à un groupe en activation retardé au niveau de l'éditeur

Exemple : `MyCapture:AddbaseToCapture({base = "Al Mansurah", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})` : Ajoute la base Al Mansurah au système de capture par C17 qui partira de la base de Ben-Gurion et fera pop le groupe Hawk une fois posé

#### Ajouter une base à capturer automatiquement (sans C17)
`:AddbaseAutoCapture(nom)` permet d'ajouter une base (nom) qui sera capturée sans C17 via le slot de l'unité nommée 'MLRS capture' dans l'éditeur. 

#### Activation de l'artillerie à la capture d'une base 
`:AddGroundControl(GroundArtillery)` permet, à la capture d'une base, d'activer les unités contrôlées par la class GroundArtillery. 


#### Système de recapture de base par convoi ennemi
Ce système fonctionne en plusieurs parties : 
 - `:RedGroundCaptureGroup({groupe1, groupe2})` : cette fonction permet d'indiquer le nom des groupes qui vont spawn en tant que convoi. Le groupe est choisi aléatoirement dans la liste, donc plus il est présent, plus il a de probabilité d'être choisit. Le groupe peut soit être ajouté dans l'éditeur, soit être choisi dans la liste des convois disponibles : 
    - heavy : convoi lourdement armé comprenant des Tank, des BTR, des SAM (SA15 et SA9) et une ZSU
    - sa9 : convoi "heavy" sans SA15
    - zu : convoi "sa9" sans SA9
    - armored : convoi "zu" sans la ZSU23
    - t90 : convoi de 7 T90 et un Ural
    - t90SA : convoi "t90" avec un SA9 en plus
    - unArmored : convoi non armé de 9 Ural
    - scout : convoi comprenant plusieurs Urals, dont certains sont armés
    - uniq : convoi comportant une seule unité HL_KORD (Ural armé)

 - `:RedSpawnCapturegroup({groupe1, groupe2 })` : cette fonction permet d'indiquer quel groupe Red va spawn au niveau de la base capturée, à la place du convoi. Le groupe est choisi aléatoirement dans la liste, et correspond à un groupe ajouté dans l'éditeur en activation retardée
   
 - `:RedMaxGroundSpawn(obj)` : permet d'ajuster le nombre de convoi autorisés à slot en fonction du nombre de joueur connecté. Obj est un tableau d'objet construit comme suit :
  	- l'indice du tableau est le nombre de groupe autorisé
  	- l'objet du tableau contient un attribut min et un attribut max correspondant respectivement au nombre de joueur minimum et maximum pour autoriser le spawn
  	- exemple pour 3 groupes :
    `
  	{
    		{ min = 3, max = 6, },
    		{ min = 7, max = 10},
    		{ min = 11}
	}
 `
 
		- Le premier groupe pourra spawn s'il y a au moins 3 joueurs
		- Le second groupe s'il y a 7 joueurs
		- Le dernier groupe s'il y a 11 joueurs

 - `:AddRedGroundCaptureBase({start = "baseDépart", destination = "baseDestination" )` permet de spécifier quelle base peut être recapturée par un convoi et d'où il doit partir (le système est à double sens : une base de destination peut devenir la base d'origine). Les bases doivent avoir le même nom que dans l'éditeur. Exemple `MyCapture:AddRedGroundCaptureBase({start = "El Arish", destination = "El Gora"})` 
 -`:RedGroundSpawnTime(temps_en_seconde)` change le temps minimal (en seconde) entre 2 spawn d'un même groupe. Par défaut 1200

#### Système de recapture de base par convoi aérien
En plus de la capture par voie terrestre, il est possible pour des bases éloingées de faire spawn un IL76 qui va larguer un convoi à 50Nm d'une base cible. 
Ce système utilise les fonctions suivantes : 
 - `:RedAirCaptureHQ(obj)` permet d'indiquer de quelles bases l'IL76 peut partir, attention la base doit être assez grande pour permettre son spawn. obj est une liste de base disponible, si la première est capturée, l'IL76 va spawn sur la seconde, et ainsi de suite. Exemple :  `MyCapture:RedAirCaptureHQ({"Cairo International Airport"})`
 - `:AddRedAirCaptureBase("Nom_de_laBase")` : permet d'ajouter une base qui pourra être ciblée par l'IL76. Exemple `MyCapture:AddRedAirCaptureBase("Nevatim")`




### Reaper 

#### Reaper classique

#### Reaper avec autolase


### Class IA



#### Tankers


#### Awacs

#### Bombardement 

#### Tomahawk (depuis un porte avion)



#### Informations PA


### CAP


### Menu Communication


### Mode Zeus (class ZeusMod)
Il est possible d'ajouter un mod Zeus qui vous permettra de faire spawn des unités au sol comme des SAM, des tanks, des convois ou même des FOB entières rendant le jeu plus dynamique. 
Ce mod peut aussi être utilisé seul dans un script mission ce qui vous permet d'avoir en 2 lignes une mission d'entrainement. 

#### Utilisation
  - Constructeur : `local Zeus = ZeusMod:New('MOOSERED')` : Le constructeur prend en paramètre le nom de l'unité dans l'éditeur qui lui servira d'encrage. Cette unité doit être en activation retardée (voir [editeur](#unités-requises-au-niveau-de-léditeur))
  - Initialisation : `Zeus:Init()` : tant que cette ligne n'est pas appelée, Zeus ne fonctionnera pas. Cette ligne doit être appelée après les éventuelles functions décrites ci-après.
  - Obligatoire pour autoriser son utilisation : `Zeus:Allow()` : par défaut et même avec la fonction :Init(), le mode Zeus n'est pas fonctionnel, cela permet de donner un niveau supplémentaire pour activer ou non le module.

#### Options supplémentaires
La class ZeusMod fournit d'autres functions qui vous permet d'ajuster certains paramètres si besoin. 

##### Ajouter un mot de passe
Afin d'éviter l'utilisation du mod par n'importe qui, il est possible de mettre un mot de passe via `:UsePassword(mdp)`, à noter qu'une fois le mot de passe saisie, n'importe qui peut utiliser les commandes

##### Exclure les unités qui spawnent de la sauvegarde (via la persistance)
Afin d'éviter une sauvegarde des unités via le script de persistance, il faut utiliser la fonction `:ExcludePersistance(PWS)` avec la variable liée à la class PWS (Persistance donc les exemples ici)

##### Afficher un menu de comm dédié
Certaines fonctions du mode Zeus peuvent être utilisées plus facilement via le menu comm, toutefois ce type de menu est incompatible avec les missions classiques, il est donc désactivé par défaut. Pour l'activer il faut utiliser la fonction `:AllowMenu()`

#### Utilisation In Game
Le mode Zeus permet d'ajouter de nombreuses unités, son comportement est décrit ici [ZeusReadme](./ZeusReadme.md)

	

    


