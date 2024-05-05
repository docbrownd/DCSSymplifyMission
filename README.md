# DCS Simplify Mission V2

**Attention** la version 2 casse la compatibilité avec les scripts mission réalisés sur les versions précédentes. La V2 ajoute plusieurs fonctionnalités et contient d'importante réécriture pour utiliser plus efficacement la POO. Entre autre les class gérant les tankers, awacs, tacan, et PA ont été refaites. Une nouvelle class RedIA apparait pour gérér tout ce qui est lié aux misisons Red, à savoir la recapture de base par convoi/convoi largué par IL76/hélicoptère larguant des manpad, mais aussi des attaques SEAD (SU24M) ou antipiste (TU160). De même la CAP peut maintenant être gérée plus simplement via la class AutoCAP.

Les tankers et l'awacs ont maintenant une course générée automatiquement par le script qui créé une orbit 'reace-track' autour d'un trigger posé dans l'éditeur et avec un range et une inclinaison indiqué par script. Il est maintenant possible d'indiquer une autre base de décollage suivant la progression de la mission.

Le porte avion voit également sa course gérée par script et peut se déplacer en fonction de la progression de la mission. Un S3B peut être ajouté et va orbiter autour d'un des bâtiment du groupe. Il est aussi possible d'ajouter automatiquement des static sur la catapulte 2 pour habiller l'USS Lincoln et Stennis avec des F18.

Pour les missions de type Cold War il est maintenant possible de déployer un gruope JTAC au sol en autolase Laser + IR, sur le meme principe que les MQ9.

La class BuildingControl a été revu afin de fonctionner avec des zones et non des ID, qui changent à chaque MAJ

Enfin une class simple de type CTLD a été ajoutée pour déplacer/faire slot des groupes de Manpad/JTAC et déployer des FARP. 

Le script contient les scripts Moose (v2.9.6) et Mist (v4.5.122) en entier, il n'est donc pas nécessaire de les charger si vous les utiliser avec d'autres scripts

## Description

DCS Simplify Mission (DSM) est un ensemble de scripts conçus pour faciliter la création de missions de type conquête avec persistance, capture de base, CAP adaptatives, Reconnaissance de cible, Bombardement de base et plus encore. Le code est encore perfectible avec quelques redondances mais il est suffisamment stable pour être publié. Il est actuellement utilisé pour faire tourner la mission Sinai des serveurs public Couteau et privé Ghost.

Les scripts se basent en grande partie sur Moose, mais uniquement sur les fonctions de base facilitant l'accès à l'API de DCS, et ce afin de limiter les risques d'avoir des fonctionnalités qui ne seraient plus focntionelles ou qui seraient trop lourde pour un serveur.

DSM se décompose en 2 scripts à charger : le premier (DCSSimplifyMission) contient l'ensemble des class (dont Moose et Mist) qui peuvent être utilisées, le second correspond à la mission en elle-même. 
L'ensemble des options disponibles sont décrits ci-après, et un exemple d'un script Mission (pour la map Sinai) est disponible dans le dossier /example (il peut être plus facile dans un premier temps de regarder le script).

## Installation

Charger le script DCSSimplifyMission.lua en déclenchement unique sur un temps supérieur à 1s.
Charger ensuite votre script de mission sur un second déclencheur à 10s.
Copier le script SimpleSlotBlockGameGUI sur votre serveur dans Partie enregistrée/DCS/Scripts/Hook (ce script gère le blocage des slots)

## Unités requises au niveau de l'éditeur
Il est nécessaire d'ajouter des unités en activation retardée au niveau de l'éditeur et de respecter la syntaxe pour le nom du groupe. Ces groupes seront utilisés pour faire spawn les unités aériennes, au sol et des systèmes de capture : 

    - MOOSERED : une unité au sol, le type importe peu
    - MLRS : une unité au sol => unité qui spawn à la capture de base, à vous de voir ce que vous voulez mettre 
    - MLRS capture : une unité au sol => unité qui spawn dans le cas des captures automatiques (sans C17/C130), à vous de voir ce que vous voulez mettre 
    - Plane Template : une unité aérienne,  utilisée pour la CAP et les tankers/Awacs, le type importe peu mais attention à ****supprimer** toutes les tâches/options que l'appareil aurait pas défaut.
    - Heli Template : un hélicopter, le type importe peu mais il ne doit pas avoir de tâche/mission

    
Au delà de ces unités obligatoires, il sera nécessaire d'en ajouter (toujours en activation retardée) dans certains cas qui sont décrits plus bas : notamment pour le groupe qui spawn en cas de recapture de base par les RED et le groupe qui spawn au posé des C17/C130 (généralement un site SAM)


## Principes génériques du script Mission

Le script de mission est à faire pour chaque mission (alors que DCSSimplifyMission doit juste être chargé). Différents modules (class) peuvent être utilisés, certains sont indépendants (ils contiennent une fonction Init()), ainsi il est possible d'utiliser uniquement le mod Zeus au niveau du script Mission.  D'autres modules ne sont qu'une description et doivent être utilisés via des modules plus larges. 
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
  - Constructeur : `local recon = ReconClass:New(PWS)` : si la class ReconClass est instanciée avec le nom de la class PWS (persistance) utilisée, les marqueurs seront sauvegardés (il faut en plus avoir activé l'écriture dans le fichier de reco, via `:SaveReco()`)
  - Initialisation : `recon:Init()` : tant que cette ligne n'est pas appelée, la reconnaissance ne fonctionnera pas. Cette ligne doit être appelée après les éventuelles functions décrites ci-après.

#### Options supplémentaires

La class ReconClass fournit d'autres functions qui vous permet d'ajuster certains paramètres si besoin. 

##### Ajouter des appareils

Par défaut la reconnaissance est disponibles pour les appareils suivants : 

 - F15-C/E
 - F14-B
 - F1
 - M2000
 - F1-EE/CR
 - F18
 - F16
 - JF17
 - Gazelle SA342M
 - Gazelle SA342L
 - UH-1H
 - Apache
 - A-10C/A
 - AJS37
 - AV8
 - C-101CC/C-101EB
 - F-5E
 - J-11
 - L-39C/ZA
 - Mig-15Bis/19P/29A/29S/29A/29G
 - SU-25/25T/27/33


Il est possible d'ajouter un appareil via `:AddRecoType(obj)`, l'objet doit avoir les attributs suivants : 
 - name : le nom de l'appareil (le nom importe peut, mais il doit être unique)
 - recoType : le type d'appareil pour DCS (exemple pour le F18 : FA-18C_hornet)
   
 - offset : angle en rad pour le calcul de l'offset (par défaut math.rad(83))
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
Class réécrite en V2

Cette class permet de faire spawn des Tacan lorsqu'une base est capturée. Le tacan est ajouté au bout de la  piste en service, légérement décalé.
En V2, la class ne fait que charger N Tacn décrit via la class TacanObj

#### class TacanObj

Cette class permet de créer un TACAN : 
  - Constructeur : `local tacan1 = TacanObj:New(baseName)` : baseName correspond à la base où le tacan devra pop si elle est bleue
  - `:SetTacanCode("codeTacan")` :  code Tacan qui sera affiché sur les HSI
  - `:SetFrequency(value)` : fréquence du Tacan
  - `:SetBand('C)` : bande du Tacan, X ou Y


#### Utilisation avec la class TacanBase
  - Constructeur : `local tacan = TacanBase:New()`
  - `:SetTacan(tacan1)` : ajoute un tacan tel que décrit dans TacanObj (tacan1 dans notre exemple), à répéter autant de fois que nécessaire
  - Initialisation : `:Init()` : tant que cette ligne n'est pas appelée, la class Tacan ne fonctionnera pas. Cette ligne doit être appelée en dernier
    

### Artillerie (class GroundArtillery)
Cette class permet d'activer des unités pour les faire tirer sur une base lorsque celle-ci est capturée, comme des sites scud ou des unités Smerch. 
Cette class doit être à la fois initialisée et utilisée de concert avec la class CaptureAirBase pour fonctionner.
Le groupe va prendre pour cible un point choisi aléatoirement dans la zone autour de la base. La précision est donc toutes relative.



#### Utilisation
  - Constructeur : `local artillery = GroundArtillery:New()`
  - Ajout d'un groupe : `artillery:AddGroundShootIf(unit, airbase)`, avec unit le nom du groupe à contrôler, airbase le nom de la base (tel qu'affiché dans l'éditeur) ciblée. Exemple : `artillery:AddGroundShootIf("Scud1", "Ramon Airbase")` va activer le groupe Scud1 et lui faire cibler la base Ramon Airbase lorsqu'elle sera bleue
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
 - plane = "C-17", ou "C-130" 
 - groupPop : le nom du groupe qui popera une fois que le C17/C130 sera posé (et uniquement dans ce cas), en règle général un site SAM. Le nom doit correspondre à un groupe en activation retardé au niveau de l'éditeur

Exemple : `MyCapture:AddbaseToCapture({base = "Al Mansurah", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})` : Ajoute la base Al Mansurah au système de capture par C17 qui partira de la base de Ben-Gurion et fera pop le groupe Hawk une fois posé

#### Ajouter une base à capturer automatiquement (sans C17)
`:AddbaseAutoCapture(nom, groupName)` : permet d'ajouter une base (nom) qui sera capturée sans C17 via le slot de l'unité nommée 'MLRS capture' dans l'éditeur, ou via le slot de groupName si ce dernier est indiqué. 'Nom' est le seul paramètre obligatoire.

#### Activation de l'artillerie à la capture d'une base 
`:AddGroundControl(GroundArtillery)` permet, à la capture d'une base, d'activer les unités contrôlées par la class GroundArtillery. 

### Recapture Red ###
Dans la V2, toute la partie de recapture RED a été déplacée dans une nouvelle class 'RedIA'

### Reaper (class Reaper)
Il est possible d'ajouter 2 types de drones sur une mission, tout deux seront appelés via le menu communication et apparaitront au niveau d'une base. Ces types de drones diffèrent par leur mission : le premier drone devra être contacté pour avoir des informations sur une cible (mode AFAC), le second scannera la zone est lasera automatiquement les cibles (avec un visuel via fumigène). Les deux drones sont codés via la class Reaper, le drone avec autolase a simplement quelques options en plus.

#### Reaper classique
  - Constructeur : `local MQ9 = Reaper:New()`
  - `MQ9:SetZones(menuComm)` : cette fonction permet de définir la strcuture du menu comm "MQ-9 Reaper". menuComm doit contenir un premier niveau de Menu (peu importe le nom) et un second qui sera constituer du nom des bases où le drone sera dirigé.

    	local menuComm = {
    		["Israel"] = {
        		"Hatzerim",
        		"Kedem",
        		"Nevatim",
        		"Ovda",
        		"Ramon Airbase"
    		},
    		["Est Egypte"] = {
        		"Abu Rudeis",
    			"El Arish",
    			"Melez",
    			"St Catherine",
    			"El Gora"
    		},
    		["Ouest Egypte"] = {
        		"Al Mansurah",
    			"Cairo West",
    			"Cairo International Airport",
    			"Fayed",
    			"Wadi al Jandali"
    		}
    	}
    
  - Initialisation : `MQ9:Init()` : tant que cette ligne n'est pas appelée, la class ne fonctionnera pas. Cette ligne doit être appelée après les éventuelles functions décrites ci-après.

##### Options supplémentaires 
 - `:SetStartFrequency(272)` : indique à partir de quelle fréquence chaque drone doit être contacté. Le drone n°1 sera sur cette fréquence, le n°2 sur la fréqeunce 272+1, etc
 - `:NumberMax(nbr)` : par défaut il est possible d'appeler jusqu'à 8 drones. Cette fonction permet de modifier le nombre (ne pas dépasser 7 pour des raisons de code laser)


#### Reaper avec autolase
Le drone avec autolase (par défaut laser + IR) a les meme options que le drone classique, sauf qu'il n'est pas nécessaire de la contacter et qu'il a 2 functions suplémentaires pour le lasing : 
 - `:SetStartLaserCode(1681)` : indique la valeur du laser du drone n°1, le second aura +1, le 3eme +2, etc. Attention à bien choisir entre le nombre de drone et les codes autorisés.
 - `:AutoLase({state = true, smoke = true, smokeColor = "red", tot = 30})` : décrit la misison du drone : state doit être à true pour que le drone fonctionne, smoke indique si le drone doit ou non marquer sa cible par un fumigène donc la couleur est indiquée par smokeColor (valeur possible red/green/white/orange/blue). La valeur tot indique le temps en minute avant que le drone s'autodétruise

Exemple de code pour un drone avec autolase : 

	local MQ9Auto = Reaper:New()
	MQ9Auto:SetZones(baseAndZoneMap)
	MQ9Auto:SetStartFrequency(40)
	MQ9Auto:NumberMax(5)
	MQ9Auto:SetStartLaserCode(1681)
	MQ9Auto:AutoLase({state = true, smoke = true, smokeColor = "red", tot = 30})
	MQ9Auto:Init()

#### JTAC via des groupes au sol (class AutoJTACGround)

Pour les missions coldwar (sans MQ9) ou pour le CTLD, il est possible de déployer un JTAC au sol. 
- Constructeur : `local autoJTAC = AutoJTACGround:New()`
- `:SetStartLaserCode(1681)` : (optionnel, par défaut 1681) indique la valeur du laser du drone n°1, le second aura +1, le 3eme +2, etc. Attention à bien choisir entre le nombre de drone et les codes autorisés.
- `:SetZones(menuComm)` : (obligatoire, sauf si ulisation avec CTLD) même fonction que pour le JTAC classique
- `:Smoke(color)` : (optionnel, par défaut null) indique si la cible doit aussi être marquée par un fumigène (par défaut non). Color doit avoir comme valeur : red, green, white, orange ou blue
 - `:NumberMax(nbr)`: par défaut il est possible d'appeler jusqu'à 5 groupes. Cette fonction permet de modifier le nombre (ne pas dépasser 7 pour des raisons de code laser)


### Class IA (class IABlue)
La class IABlue est au moins aussi complexe que la classe CaptureBase car elle gère elle aussi de multiples systèmes : 
 - les tankers et awacs (qui sont décrits dans leur propre class)
 - les missions de bombardement par B-1B (lui aussi décrit dans sa propre class)
 - le système de reconnaissance par "satellite"
 - l'utilisation des missiles Tomahawk (également décrit dans sa propre class)

Les class Tanker, Awacs et porte avion utilise la class IAprogression pour permettre un déplacement en fonction de la progression de la mission mais aussi pour avoir une course générée automatiquement

De même elles utilisent la class TacanObj qui permet de créer un Tacan. 

#### IAprogression 
Cette class permet de décrire la course d'un appareil (avion ou porte avion) en fonction de l'état de la mission (des bases capturées) et ajoute une gestion automatique de la course, à partir d'une zone créée dans l'éditeur.
Exemple : 

	local tankers1Progression = {
	    IAprogression:New():SetBases({"Ovda", "Nevatim"}):SetPosition("KCOuest"):SetPatternRaceTrack(50, 160):SetTakeOff("Cairo International Airport"),
	    IAprogression:New():SetPosition("KCNord"):SetPatternRaceTrack(50, 106),
	}


Ici on crée un objet tankers1Progression qui contient 2 objets IAprogression. Si les bases "Ovda" et "Nevatim" sont capturées alors letanker utilisera les infos du premier objet IAprogression, sinon se sera le second. 

- Constructeur : `IAprogression:New()`
- `:SetPosition(zoneName)` : obligatoire.  Indique la zone de l'éditeur autour de laquelle l'appareil va orbiter 
- `:SetPatternRaceTrack(distance, angle)` : indique que l'appareil doit prendre une orbite de type 'race-track' (possible que pour les avions tanker/awacs), ce type d'orbite évite que le tanker oscille en permanence gauche/droite lorsqu'il va sur un WPT. Distance doit etre en Nm et correspont à la taille de l'orbite. Angle, en degré, correspond à l'inclinaison de l'orbite sur la map. Il vaut 90° par défaut (= pattern horizontal). Pour avoir cette valeur, il suffit sur l'éditeur d'utiliser l'option règle et de noter l'angle donné. Le pattern est en sens horaire, le WPT 1 est à gauche de la zone, le wpt2 à droite
- `:SetPattern(longueur, largeur, angle)` : meme principe que pour SetPatternRaceTrack mais à utiliser pour le porte avion. Le pattern sera de 6 WPT.  Le pattern est en sens anti-horaire, WPT1 à en bas à droite de la zone.
 - `:StartPatternAt(nbr)`: (optionnel) permet d'indiquer à partir de quel WPT l'appareil doit commencer. Utile pour le PA
 - `:SetBases({'base1', 'baseN'})`: (optionnel) Liste des bases qui doivent être capturée pour que les options s'appliquent
 - `:SetTakeOff(baseName)`: (optionnel) nom de la base d'où l'appareil doit décoller. Pas nécessaire pour les porte avions. Pour les tankers/awacs si l'option n'existe pas, c'est celle de la class AwacsIA/TankerIA qui s'applique. Utile pour faire décoller des avions de plus près une fois certaines bases capturées.
 




#### Tankers (class TankerIA)
Class réécrite en V2
La class IA gére les tankers (KC135/KC135MPRS), la class IAGAN gère le S3B, mais ces derniers doivent être configurés avant via la class TankerIA. Il est possible d'ajouter autant de Tanker ou d'Awacs que nécessaire. 

##### Utilisation
 - Constructeur : `local tanker1 = TankerIA:New()`
 - `:SetPlane(planeType)` : le type de tanker : KC135, KC135MPRS ou S3B
 - `:SetAltitude(altInFeet)` : altitude en pied du tanker
 - `:SetKnot(speedInKnot)` : vitesse en noeud du tanker
 - `:SetFrequency(freqInMHz)` : fréquence en MHz pour contacter l'appareil
 - `:SetTacan(TacanObj)` : Objet tacan de type TacanObj
 - `:SetCallSignName(tankerCallSign)` : le callsign du tanker, attention à ne prendre que les callsign possible
 - `:SetCallSignGroup(value)` : le n° de groupe du tanker. 
 - `:SetTakeOffFrom(baseName)` : la base par défaut d'origine du tanker. Pour les S3B la baseName doit correspondre au nom du pote avion d'où l'avion doit décoller (nom de l'unité et non le nom du groupe)
 - `:SetProgression({IAprogression})` : les infos de progression pour le tanker via une liste d'objet IAprogression. Pas nécesaire pour le S3B (qui suit son PA)



Exemple d'un tanker : 


	local tankers1Progression = {
		IAprogression:New():SetBases({"Ovda", "Nevatim"}):SetPosition("KCOuest"):SetPatternRaceTrack(50, 160):SetTakeOff("Cairo International Airport"),
		IAprogression:New():SetPosition("KCNord"):SetPatternRaceTrack(50, 106),
	}

	local tanker1 = TankerIA:New()
		:SetPlane("KC135")
		:SetAltitude(20000)
		:SetKnot(450)
		:SetFrequency(230)
		:SetTacan(TacanObj:New():SetTacanCode("KC1"):SetFrequency(30):SetBand("Y"))
		:SetCallSignName("Shell")
		:SetCallSignGroup(1)
		:SetTakeOffFrom("Ben-Gurion")
		:SetProgression(tankers1Progression)

Ici tanker1 correspondra un KC135 répondant sur la 230MHz avec le callsign Shell11 et un tacan "KC1" en 30Y. La tanker partira de Ben Gurion et se positionnera autour de la zone KCNord tant qu'aucune base sera capturée. Il volera à une vitesse de 450noeuds à 20k pieds sur un pattern de 50Nm de long, incliné à 160°. Il se déplacera sur KCOuest une fois les bases Ovda et Nevatim capturées.

Le tanker n'est ici que configuré, il faudra l'injecter dans la class IABlue


#### Awacs (class AwacsIA)
Class réécrite en V2

L'AWACS fonctionne de la même manière, il a juste besoin d'une zone de déclenchement pour orbiter (et il n'est pas possible de lui donner une altitude/vitesse ou un tacan). Il faut aussi respecter les callsign possibles pour les Awacs (Darkstar/Overlod par exemple) : 


	local AwacsProgression = {
		IAprogression:New():SetBases({"Ovda", "Nevatim"}):SetPosition("AwacsZoneSud"):SetPatternRaceTrack(50, 150),
		IAprogression:New():SetPosition("AwacsZoneNord"):SetPatternRaceTrack(50),
	}
	
	local awacs1 = AwacsIA:New()
		:SetFrequency(280)
		:SetCallSignName("Darkstar")
		:SetCallSignGroup(1)
		:SetTakeOffFrom("Ben-Gurion")
		:SetProgression(AwacsProgression)

Ici l'AWACS répondra sur la 280MHz avec le callsign Darkstar11. L'AWACS partira de Ben Gurion et se positionnera en orbite de 50Nm sur une inclinaison de 90° sur la zone AwacsZoneNord tant qu'aucune base sera capturée. Il se déplacera sur AwacsZoneSud une fois les bases Ovda et Nevatim capturées, avec cette fois un pattern de 50N incliné à 150°

Comme pour le tanker, l'AWACS n'est ici que configuré, il faudra l'injecter dans la class IABlue


#### Bombardement (class IABombing)
Il est possible d'ajouter un B-1B IA qui pourra avoir 2 missions : bombarder une piste avec de la MK82 ou bombarder des unités sur une base avec des GBU31 (GPS), via le menu de communication. La class n'a qu'un constructeur qui prend une objet contenant le nom de la base de départ :   
`local bombing = IABombing:New({takeOffFrom = "Ben-Gurion"})`

La class ne contient pas de fonction Init(), pour fonctionner il faut l'injecter dans la class IABlue


#### Tomahawk (class IATomahawk)
Il est possible d'utiliser les missiles Tomahawk si la flotte du PA contient des batiments ayant ces missiles. 
##### Utilisation 
 - Contructeur : `local tomahawk = IATomahawk:New("Groupe aeronaval")` : le constructeur a besoin du nom du groupe d'unité contenant les bâtiments depuis lesquels les missiles seront tirés

La class ne contient pas de fonction Init(), pour fonctionner il faut l'injecter dans la class IABlue
##### Options supplémentaires
Il est possible de configurer les missiles : 
 - `:SetMissileMax(nombre)` : permet de définir le nombre maximum de missile pouvant être tiré dans un certain délais (30 min par défaut)
 - `:SetDelay(temps)` : permet de définir le temps, en minute, de rechargement (temps entre le moment où les missiles sont à 0 puis remis au maximum)
 - `:SetTimeBetweenFire(temps)` : permet de définir le temps, en seconde, entre deux tirs. 

##### Utilisation In Game
Les missiles s'utilisent de 2 manières : 
 - soit via un marqueur dans lequel on tape #t puis en utilisant le menu communication : Demande soutien>Missiles Tomahawk>Tir sur coordonnées 
 - soit directement via le menu communication pour tirer automatiquement sur les unités présentes au niveau d'une base Demande soutien>Missiles Tomahawk>Sur unités (base)>Nom de la base 

#### Informations PA (class IAGAN)
Class réécrite en V2.
La class va utliser les objets : 
 - IAprogression pour avoir une course automatique
 - IAShip pour configurer chaque porte avion du groupe, la class IAShip utilise notamment la class TacanObj pour gérer le tacan du PA
 - TankerIA pour le S3B


**Attention** : vu que le PA est placé automatiquement par le script, il est en réalité détruit pour reconstruit à l'identique à la bonne position. Cela implique qu'il **ne faut pas** slot dessus tant qu'il ne s'est pas déplacé (en gros attendre 1min) et que les statics qui habillerait le PA ne sont pas reconstruit (sauf ceux gérés par le script)

Exemple d'un groupe avec 4 PA, dont 2 avec un habillage de static, et avec la gestion d'un S3B 
	
	local gan1 = IAGAN:New()
		:SetGroupName("Groupe aeronaval")
		:AddShip(IAShip:New():SetName("Tarawa"):SetFrequency(226.5):SetTacan(TacanObj:New():SetTacanCode("TAW"):SetFrequency(26):SetBand("X")):SetICLS(5))
		:AddShip(IAShip:New():SetName("Lincoln"):SetFrequency(227.5):SetTacan(TacanObj:New():SetTacanCode("LNC"):SetFrequency(27):SetBand("X")):SetLink4(336):SetICLS(10):AddStatic('F18'))
		:AddShip(IAShip:New():SetName("Stennis"):SetFrequency(228.5):SetTacan(TacanObj:New():SetTacanCode("STN"):SetFrequency(28):SetBand("X")):SetLink4(346):SetICLS(15):AddStatic('F18'))
		:AddShip(IAShip:New():SetName("Washington"):SetFrequency(229.5):SetTacan(TacanObj:New():SetTacanCode("WAS"):SetFrequency(29):SetBand("X")):SetLink4(356):SetICLS(20))
		:SetProgression(GANProgression)
		:AddS3B(S3B)
		:Init()

Ici le groupe au niveau de l'éditeur s'appelle 'Groupe aeronaval' et contient 3 portes avions (appelé 'Lincoln', 'Stennis', 'Washington') + le tarawa ('Tarawa') : 
 - Le Tarawa répond sur la fréquence 226.5MHz, a pour Tacan 26X 'TAW' et un ICLS sur 5
 - Le Lincoln répond sur la fréquence 227.5MHz, a pour Tacan 27X 'LNC', un ICLS sur 10 et un link4 sur 336MHz
 - Le Stennis répond sur la fréquence 228.5MHz, a pour Tacan 28X 'STN', un ICLS sur 15 et un link4 sur 346MHz
 - Le Washington répond sur la fréquence 229.5MHz, a pour Tacan 29X 'WAS', un ICLS sur 20 et un link4 sur 356MHz

De plus le Lincoln et le Stennis auront des F18 sur la catapulte 2 (pour le moment le code ne gère que des F18 et que pour ces 2 types de bâtiments). L'option :AddStatic n'est pas obligatoire

Un S3B décollera et suivra l'un des bâtiments, en fonction de la valeur contenu dans SetTakeOffFrom (:AddS3B n'est pas obligatoire)

Comme pour les tankers et awacs, SetProgression permet de donner une zone de navigation et une progression (attention à ne pas utiliser SetPatternRaceTrack mais bien StartPatternAt).  


Via le menu communication, il sera possible de demander les informations PA, qui afficheront le nom des bâtiments, leur tacan, la fréquence d'appel, ainsi que les fréquences ICLS et Link4. Pour cela il faut injecter la class dans la class IABlue


#### Utilisation de la class IABlue
 - Constructeur : `local IA = IABlue:New(PWS)` le constructeur a besoin de la class PWS si vous souhaitez utilser le système de reconnaissance manuel
 - `:SetTankers({tanker1, tanker2})` : permet d'injecter les tankers configurés via la class TankerIA
 - `:SetAwacs({awacs1, awacs1})` : permet d'injecter les AWACS configurés via la class AwacsIA
 - `:SetPA({gan1, gan2, etc})` : permet d'injecter les informations des groupes aéronaval configurés via la class IAGAN. 
 - `:AllowedCruise(tomahawk)` : autorise l'utilisation des Tomahawk, configurés via la class IATomahawk
 - `:AllowedBombing(bombing)` : autorise l'utilisation de B-1B, configurés via la class IABombing
 - `:SetZones(menuZones)` : même système que pour les Drones : cette fonction permet de donner la structure du menu comm (nécesaire pour le bombardement B-1B et Tomahawk)
  - Initialisation : `IA:Init()` : tant que cette ligne n'est pas appelée, la class ne fonctionnera pas. Cette ligne doit être appelée après les éventuelles functions décrites ci-après.

#### Options supplémentaires 

 - `:ShowTrainingZone(zone)` : fait pop un drone au-dessus d'une zone (définie via l'éditeur) puis détruit le drone. Cela permet de retirer le brouillard de guerre sur la zone. Utile pour une zone d'entrainement
 - `:AllowedSatReco()` : autorise l'utilisation de la reconnaissance via un marqueur :
   - via le texte #reaper qui fait slot un drone et le détruit (pour ne plus avoir le brouillard de guerre)
   - via le texte #reco pour avoir des cercles de reconnaissance sur les unités trouvées (même principe que le reconnaissance par appareil)


### Menu Communication (class Menu)

Cette class permet d'afficher un menu communication nécessaire pour faire appel à différentes fonctiones : obtenir les informations de fréquence des PA, Awacs, Tankers, déclencher une frappe B-1B ou de TomaHawk, déployer des drones (autolase ou classique) : 

#### Utilisation
 - Constructeur : `local menu = Menu:New()`
 - `:AddMQ9(Reaper)` : injecte un objet Reaper corresopndant au drone classique (MQ9 dans l'exemple ci-dessus)
 - `:AddAutoMQ9(Reaper)` : même chose pour le drone autolase (MQ9Auto dans l'exemple ci-dessus)
 - `:AddGroundJTAC(jtac)` : même chose pour le gruope JTAC sol en autolase (autoJTAC dans l'exemple ci-dessus)
 - `:AddIA(IABlue)` : injecte un objet IABlue (IA dans l'exemple ci-dessus)
 - `:AddFrequences()` : autorise l'affichage des fréquences PA/Awacs/Tanker via le menu comm
 - Initialisation : `:Init()` : tant que cette ligne n'est pas appelée, la class ne fonctionnera pas. Cette ligne doit être appelée en dernier

### CAP (class CAP)

#### Fonctionnement In Game
La CAP est adaptative en fonction du nombre de joueur connecté, chaque groupe est composé de 2 appareils et peut décoller d'un PA ou de base. Le type d'appareil est choisi aléatoirement dans une liste. Les avions décollent des bases prédéfinies et si ces dernières sont capturés, ils peuvent décoller d'autres bases. Il est également possible d'activer un groupe ou de le bloquer en fonction du statut d'une base (red ou bleue). Les avions navigueront vers leur base de destination et engageront s'ils détectent une cible dans les 70Nm. Le niveau des appareils est aléatoire par défaut mais peut être défini par paramètre. Quelque soit leur niveau, les appareils ont les mêmes options prédéfinies qui rend la CAP particulièrement difficile à traiter. Une fois le groupe posé ou détruit, il reslot dans un temps aléatoire (par défaut entre 15 et 20 min)

#### Utilisation
 - Constructeur : `local redCap = CAP:New()`
 - `:AddGroup(obj)`  : ajoute un groupe CAP, avec obj comme suit :
   - planes : (obligatoire) une liste contenant le nom des templates des avions à tirer au sort (voir ci-dessous)
   - start : (obligatoire) une liste de base de départ : si la première est capturée, la base d'après sera utilisée, en absence de base disponible, le groupe n'apparaitra pas
   - objectif : (obligatoire) le nom de la base de destination
   - name : (obligatoire) le nom du groupe (doit être unique)
   - fromPA : facultatif, false par défaut. A mettre à true si le groupe slot sur le porte avion (et dans ce cas, le nom de la base de départ doit etre le nom du porte avion)
   - blockIfBlue : (facultatif) nom de la base qui doit être bleue pour empêcher la CAP de décoller
   - blockIfRed : (facultatif) nom de la base qui doit être red pour empêcher la CAP de décoller
   - spawnMin : (facultatif) durée min en seconde avant le prochain slot d'un même groupe (par défaut 900)
   - spawnMax : (facultatif) durée max en seconde avant le prochain slot d'un même groupe (par défaut 1200)
   - Skill : (facultatif) par défaut sur "Random", choisir entre "Average", "Good", "High", "Excellent" et "Random"
   - minPlayer : (facultatif) nombre minimal de joueur pour autoriser la CAP à décoller
   - spawnCountMax : (facultatif) nombre maximal de slot autorisé pour ce groupe CAP. (par défaut -1, slot infini)
   - activeOnBuilding : disponible depuis la v1.2 : indique si la CAP est déclenché via la class BuildingControl (true/false, false par défaut) (:BuildingControl doit être set)
 - `:BuildingControl(BuildingControl)` : permet d'injecter la class BuildingControl. Obligatoire si au moins un groupe CAP est lié à cette class
 - Initialisation : `redCap:Init()` : tant que cette ligne n'est pas appelée, la class ne fonctionnera pas. Cette ligne doit être appelée en dernier

#### Appareils disponibles et nom à utiliser : 

Le paramètre "plane" attend une liste d'avion qui pourront slot, le nom des appareils doit être choisi dans la liste ci-dessous (vous avez également le nom de l'appareil même si c'est généralement compréhensible) :

    "SyAAF JF-17" : JF-17
    "SyAAF Su-30" : Su-30
    "SyAAF Su-33" : Su-33
    "SyAAF Mig-31" : Mig31
    "SyAAF Mig-23" : Mig23
    "SyAAF Mig-29A" : Mig29A
    "SyAAF Mig-29S" : Mig29S
    "SyAAF Mig-21Bis" : Mig21Bis
    "SyAAF Mig-25PD" : Mig25PD
    "Irak Mig-21Bis" : Mig21Bis version coldwar (armement/livrée)
    "Irak F1CE" : F1CE version coldwar (armement/livrée)
    "Irak Mig-29A" : Mig29A version coldwar (armement/livrée)


Comme il s'agit d'un tirage au sort, si un nom est indiquer plusieurs fois dans le paramètre "plane", il aura plus de chance d'être choisi

Exemple possible : 

    local planes = { -- le JF17 aura 1 chance sur 4 de sortir
        "SyAAF JF-17",
        "SyAAF Su-30",
        "SyAAF Su-30",
        "SyAAF Su-30",
    }
    redCap:AddGroup({
        planes = planes,
        start = {"Inshas Airbase"},
        objectif = "Melez",
        name = "Juliet",
        blockIfRed = "Melez",
        minPlayer = 14
    })

Ici le groupe Juliet ne décollera que s'il y a au moins 14 joueurs, de la base Inshas Airbase et ira en direction de la base Melez, une fois que cette dernière sera capturée par les bleus.


### AutoCAP (class AutoCAP)

#### Fonctionnement In Game

Cette class a été réalisée pour créer une CAP plus simplement : plutot que de devoir réfléchie à l'ensemble des paramètres nécessaires pour avoir une CAP équilibrée, cette class permet d'envoyer de la CAP dès qu'un appareil "joueur" décolle avec pour mission d'aller faire de la CAP vers la base d'où le joueur a décollé. Seul le ratio nombre de joueur versus nombre de **groupe**  de CAP (attention 1 groupe = 2 avions) est à adatpter. La CAP décollera 1 groupe à la fois, à chaque décollage d'un joueur, tant que le radio ne sera pas atteint. La base de décollage est aléatoire, en fonction des bases RED disponibles et de leur distance par rapport à l'objectif : mini 60Nm, max 250. Si aucune base n'est disponible et qu'un PA RED est présent, alors la CAP partira du PA.

#### Utilisation

 - Constructeur : `local autoCap = AutoCAP:New()`
 - `:InitAirForce(listingCAP)` : (obligatoire) même princpe que pour la CAP : il s'agit du listing des apapareils qui pourront décoller
 - `:SetRatioBlueRed(Number)` : (obligatoire) le ratio à respecter entre le nombre de joueur bleu et la cap red. Exempel si number = 2, alors l'IA enverra 1 groupe de CAP (soit 2 avoisn) pour 2 joueurs en ligne. A noter que quelque soit la valeur, l'IA envoi forcément un groupe.
 - `:SetMaxGroup(Number)` : (optionnel) nombre max de gropue RED que l'IA peut avoir en vol en même temps. Par défaut 5 (donc 10 avions)
 - `:InitCarrier(REDPAGroup)` : (optionnel) nom du PA RED s'il est présent.
 - `:InitAirForce(listingCAP)` : (optionnel) même princpe que pour InitAirForce : il s'agit du listing des apapareils qui pourront décoller mais cette fois du PA. Obligatoire si InitCarrier présent
 - Initialisation : `:Init()` : tant que cette ligne n'est pas appelée, la class ne fonctionnera pas. Cette ligne doit être appelée en dernier


### Class BuildingControl
Disponible depus la v1.2. Cette class permet de déclencher des actions lorsqu'un batiment de la map est détruit. Pour cela côté éditeur, il faut faire un clic droit > assigné comme sur le batiment voulu et récupérr le nom de la zone qui est créée. 

#### Utilisation 
 - Constructeur : `local buildingControle = BuildingControl:New()`
 - `:AddBuildingAction(obj)` : Ajout d'une action suite à la destruction d'un ou plusieurs batiment. Avec obj :
   - zones : (obligatoire) une liste des zones correspondant aux batiements devant être détruit pour déclencher l'action, si plusieurs zones alors l'action ne sera réalisée qu'une fois l'ensemble des batiments détruits.
   - type : le type d'action à réalisée : "ground", "cap", ou "groundAndCAP". En fonction du type, les actions déclenchées sont différentes :
     - ground => inactivation du group "groundGroup" (Radar off + interdiction de tirer)
     - cap => autorise le spawn de la CAP "capGroup"
     - groundAndCAP => ground + cap 
   - groundGroup : (obligatoire si type = ground ou groundCAP) nom du groupe dans l'éditeur à inactiver
   - capGroup : (obligatoire si type = cap ou groundCAP) nom du group CAP, au niveau de la class CAP (cette dernière doit avoir l'attribut activeOnBuilding à true)
   - message : (optionnel) message affiché lors de la destruction des batiments
   - actionDuring : (optionnel) temps en minute avant de réactiver le groupe groundGroup (si type = ground ou groundCAP)
   - messageReactivation : (optionnel) message affiché lors de la réactivation du groupe groundGroup (si type = ground ou groundCAP)
 - Initialisation : `buildingControle:Init()` : tant que cette ligne n'est pas appelée, la classe ne fonctionnera pas. Cette ligne doit être appelée en dernier



### Mission Red (class RedIA)

Nouveauté de la V2, cette class regroupe la gestion des missions RED. Actuellement il est possible de permettre à l'IA RED de réaliser : 
- des missions des recaptures de base via le déploiement direct de convoi (souvent entre base proche) ou largué par IL76 (pour des objectifs plus lointains)
- des missions de drop de MANPAD sur base bleue 
- des missions de pop d'hélico entre 2 bases RED (sans autre but)
- des missions SEAD pour attaquer un site SAM sur base bleue
- des mission antipiste via le tir de 12 KH75 à 70Nm de la base 
   
Pour la partie recapture de base, la class a besoin d''une liste des bases de départ/à capturer. Pour cela il faut utiliser la class RedIAPlane pour la partie capture par IL76 et RedConvoiRecapture pour les convois entre 2 bases

#### RedIAPlane 
  - Constructeur : `local captureAirRed = RedIAPlane:New()` : Le constructeur sans paramètre
  - `:AddRedAirCaptureBase(baseName)` : à ajouter pour chaque base à capturer par IL76 (le convoi sera largué à 40Nm de la base)

#### RedConvoiRecapture 
  - Constructeur : `local captureGroundBases = RedConvoiRecapture:New()` : Le constructeur sans paramètre
  - `:AddRedGroundCaptureBase(obj)` : à ajouter pour chaque base à capturer par convoi. Avec obj : 
    - start : la base de départ (red)
    - destination : la base de destination (bleue)
  - Exemple `:AddRedGroundCaptureBase({start = "El Arish", destination = "El Gora"})
 A noter que le système est à double sens : une base de destination peut devenir la base d'origine. Les bases doivent avoir le même nom que dans l'éditeur.

### class RedIA 
  - Constructeur : `local red = RedIA:New()` : Le constructeur sans paramètre
  - `:SetHQs({'base1', 'base2'})` : la liste des bases d'où l'IA peut décoller (si la première est capturée, l'IA décolle de la suivante et ainsi de suite)
  - `:AllowHeliLogistic(min, max)` : autorise la mission "logistic" : un hélicopter décolle et fait la liaison entre 2 bases RED. min et max sont en minute et correspondent à la durée min et max entre 2 spawn de la mission.
  - `:AllowHeliLogisticManpad(min, max)` : autorise la mission "manpad" : un hélicopter décolle en direction d'une base Bleue pour y déposer des manpad. min et max sont en minute et correspondent à la durée min et max entre 2 spawn de la mission.
  - `:AllowBomber(min, max)` : autorise la mission de bombardement antipiste : un TU160 décolle en direction d'une base bleue pour tirer 12 missiles KH65 sur le runway. Le TU160 est accompagné de 2 Mig29A armés. min et max sont en minute et correspondent à la durée min et max entre 2 spawn de la mission.
  - `:AllowSEAD(min, max)` : autorise la mission DEAD : 2 SU24. min et max sont en minute et correspondent à la durée min et max entre 2 spawn de la mission.
  - `:AllowAirRecapture(min, max, RedIAPlane)` : autorise la mission de recapture via IL76. min et max sont en minute et correspondent à la durée min et max entre 2 spawn de la mission, RedIAPlane correspond à un object RedIAPlane (captureAirRed ici)
  - `:AllowGroundRedRecapture(min, max, RedConvoiRecapture)` : autorise la mission de recapture par convoi. min et max sont en minute et correspondent à la durée min et max entre 2 spawn de la mission, RedIAPlane correspond à un object RedConvoiRecapture (captureGroundBases ici)
  - `:RedGroundCaptureGroup({'group1', 'group2'})` : pour les missions de recapture, il s'agit de liste des convoi qui peuvent spawnent. Les groupes disponibles correspondent à ceux indiqué dans la documentation de la class Zeus
  - `:RedSpawnCapturegroup(grouName)` : pour les missions de recapture, il s'agit du groupe qui sera spawn sur une base à la place du convoi une fois la base capturée. Le groupe doit etre fait dans l'éditeur en activation retardée
  - `:SetAutoMessage()` : autorise l'affichage d'un message indiquant que l'IA a fait décollé des appareils en mission SEAD/Antipiste. Le message indique uniquement la base d'origine, pas la cible
  - Initialisation : `:Init()` : tant que cette ligne n'est pas appelée, la classe ne fonctionnera pas. Cette ligne doit être appelée en dernier

Exemple complet (ici il faut faire un groupe 'redGround' dans l'éditeur) : 

    local captureAirRed = RedIAPlane:New()
        :AddRedAirCaptureBase("Melez")
        :AddRedAirCaptureBase("Nevatim")


    local captureGroundBases = RedConvoiRecapture:New()
        :AddRedGroundCaptureBase({start = "El Arish", destination = "El Gora"})
        :AddRedGroundCaptureBase({start = "Bir Hasanah", destination = "Melez"})

    local red = RedIA:New() 
        :SetHQs({'Cairo International Airport'})
        :AllowHeliLogisticManpad(10,30)
        :AllowHeliLogistic(10,15) 
        :AllowBomber(45,60)
        :AllowSEAD(30, 45)
        :AllowAirRecapture(30,40, captureAirRed)
        :AllowGroundRedRecapture(25, 35, captureGroundBases)
        :RedGroundCaptureGroup({"unArmored","armored","scout","zu","zu","sa9", "sa9","heavy", "heavy"})
        :RedSpawnCapturegroup({"redGround"})
        :SetAutoMessage()
        :Init()



### CTLD simplifié  (class CSARCTLD)
Une version très minimaliste de CTLD a été ajoutée. Elle permet de déployer un groupe de JTAC en autolase et de le déplacer, de déployer/déplacer un gropue de manpad et de fair spawn une FARP. Par défaut le chargement dans l'hélico se faire à proximité d'un static de type 'CV_59_H60'. Il est possiblde de retirer cette obligation. La FARP n'est fonctionnelle que si l'ensemble des blocs ont été déposés suffisamment proche les un des autres

  - Constructeur : `local ctld = CSARCTLD:New(Persistance)` : Le constructeur prend en paramètre la variable contenant la class de Persistance, afin de ne pas sauver les unités qui spawnent 
  - `:SetJTAC(jactObj)` : permet d'autoriser le spawn de JTAC en Autolase. jtacObj doit faire référence à un object de type AutoJTACGround (voir description plus haut)
  - `:TurnOffFenwick()` : autorise le chargement d'unité sans être à proximité d'un static CV_59_H60
  - `:AllowHeli(heliTypeName, obj )` : à mettre pour chaque hélicoptère autorisé à faire du CTLD : 
    - heliTypeName doit être le nom exacte du type d'appareil dans DCS (exemple pour l'UH1 : UH-1H)
    - obj contient une liste du type de CTLD autorisé. Pour le moment  : 
      - 'jtac' : pour le déploiement de JTAC, SetJTAC doit être utilisé
      - 'manpad' : pour le déploiement de MANPAD
      - 'fob' : pour la création de FARP
    - exmple pour l'UH1 avec l'ensemble des options : `:AllowHeli("UH-1H", {'jtac', "manpad", "fob"})`
  - Initialisation : `:Init()` : tant que cette ligne n'est pas appelée, la classe ne fonctionnera pas. Cette ligne doit être appelée en dernier
   

### Mode Zeus (class ZeusMod)
Il est possible d'ajouter un mod Zeus qui vous permettra de faire spawn des unités au sol comme des SAM, des tanks, des convois ou même des FOB entières rendant le jeu plus dynamique. 
Ce mod peut aussi être utilisé seul dans un script mission ce qui vous permet d'avoir en 2 lignes une mission d'entrainement. 

#### Utilisation
  - Constructeur : `local Zeus = ZeusMod:New('MOOSERED')` : Le constructeur prend en paramètre le nom de l'unité dans l'éditeur qui lui servira d'ancrage. Cette unité doit être en activation retardée (voir [editeur](#unités-requises-au-niveau-de-léditeur))
  - Initialisation : `Zeus:Init()` : tant que cette ligne n'est pas appelée, Zeus ne fonctionnera pas. Cette ligne doit être appelée après les éventuelles functions décrites ci-après.
  - Obligatoire pour autoriser son utilisation : `Zeus:Allow()` : par défaut et même avec la fonction :Init(), le mode Zeus n'est pas fonctionnel, cela permet de donner un niveau supplémentaire pour activer ou non le module.

#### Options supplémentaires
La class ZeusMod fournit d'autres functions qui vous permet d'ajuster certains paramètres si besoin. 

##### Ajouter un mot de passe
Afin d'éviter l'utilisation du mod par n'importe qui, il est possible de mettre un mot de passe via `:UsePassword(mdp)`, à noter qu'une fois le mot de passe saisie, n'importe qui peut utiliser les commandes

##### Exclure les unités qui spawnent de la sauvegarde (via la persistance)
Afin d'éviter une sauvegarde des unités via le script de persistance, il faut utiliser la fonction `:ExcludePersistance(PWS)` avec la variable liée à la class PWS ('Persistance' donc dans les exemples ici)

##### Afficher un menu de comm dédié
Certaines fonctions du mode Zeus peuvent être utilisées plus facilement via le menu comm, toutefois ce type de menu est incompatible avec les missions classiques, il est donc désactivé par défaut. Pour l'activer il faut utiliser la fonction `:AllowMenu()`

#### Utilisation In Game
Le mode Zeus permet d'ajouter de nombreuses unités, son comportement est décrit ici [ZeusReadme](./ZeusReadme.md) (un merci à xMiniKuT pour le design des FOB)

#### Spawn de FOB par script avec persistance
Depuis la version 1.2 il est possible d'utiliser Zeus dans le script mission pour faire spawn des FOB sur une zone : 
 - ExcludePersistance doit être défini
 - `:SpawnWithPersistance(obj)` permet de faire spawn au démarrage de la mission une FOB, avec obj :
    - name : le nom de la FOB dans Zeus
    - zoneName : le nom d ela zone dans l'éditeur
    - exemple : `Zeus:SpawnWithPersistance({name = "LARGEFOB1", zoneName = "testZoneStatic"})`


	

    


