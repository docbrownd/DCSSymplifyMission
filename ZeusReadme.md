

Pour utiliser le mode Zeus, il suffit de poser un marqueur en F10 sur la map et de taper la commande voulue. Sauf mension contraire, l'unité slot à la position du marqueur. 

Une commande commence toujours par # et chaque paramètre est séparé d'un _

Voici la liste des commandes disponibles : 

## Spawn de base prédessinée

 - #addF_SMALLFOB1
   ![smallfob1](https://github.com/docbrownd/DCSZeus/assets/105074220/8f6dac9d-bc0d-4d6e-8548-8e54610e15c3)

 - #addF_SMALLFOB2
![SMALLFOB2](https://github.com/docbrownd/DCSZeus/assets/105074220/970a7b89-a1ea-4dff-bede-85401beff347)
   
 - #addF_MEDIUMFOB1
   ![MEDIUMFOB1](https://github.com/docbrownd/DCSZeus/assets/105074220/6382e7c3-1188-402b-bcd5-3617343e8fda)

 - #addF_MEDIUMFOB2
   ![MEDIUMFOB2](https://github.com/docbrownd/DCSZeus/assets/105074220/ea243bd4-1dbe-40e2-9942-52d86361bf6e)
   
 - #addF_LARGEFOB1
   ![LARGEFOB1](https://github.com/docbrownd/DCSZeus/assets/105074220/cdddc387-87bf-4e3c-bb73-8e3cd0d56314)

- #addF_CAMP1
  ![image](https://github.com/docbrownd/DCSZeus/assets/105074220/81cb12bc-954f-4c5c-b223-4372a09a6454)

 
## Spawn d'unité

Pour les unités, il est possible de choisir le camp et le nombre : #addZ_TypeUnité_Coalition_Nombre avec :

 - TypeUnité : l'unité voulue (voir ci-après)
 - Nombre : le nombre d'unité (1 par défaut)
 - Coalition : 1 (Red) ou 2 (Bleu) (1 par défaut)

### Liste des unités diposnibles (code et description) : 

Il est possible de faire slot des unités classiques ou des sites SAM complets : 

#### SAM :

 - SA2 : Site SA2 complet
 - SA3 : Site SA3 complet
 - SA6 : Site SA6 complet
 - SA10 : Site SA10 complet
 - SA11 : Site SA11 complet
 - SA5 : Site SA5 complet
 - Patriot : Site Patriot
 - Hawk : Site Hawk
 - Nasam : Site Nasam


#### Unités :

 - SA-15 : Unité AA SA-15
 - SA-13 : Unité AA SA-13
 - SA-9 : Unité AA SA-9
 - SA-8 : Unité AA SA-8
 - T-55 : Tank T-55
 - T-90 : Tank T-90
 - T-80 : Tank T-80D
 - T-72 : Tank T-72B
 - M-1 : Char M-1 Abrams
 - M-109 : Unité M-109
 - BMP-3 : Unité BMP-3
 - BTR-80 : Unité BTR-80
 - Vulcan : Unité Vulcan
 - ZU23 : Unité AA ZU23
 - ZSU23 : Unité AA ZSU23
 - Smerch : Unité Smerch
 - HL_KORD : Unité HL_KORD
 - RPG : Soldat avec RPG
 - AK : Soldat 
 - SA-18 : Unité AA SA-18 (ManPad) 
 - Ural : Unité Ural-375
 - Ural-4320T : Unité Ural-4320T
 - Ural-4320-31 : Unité Ural-4320-31
 - Tigr : Unité Tigr

### Exemple d'utilisation : 

	#addZ_T-90 : slot 1 T90 red 
	#addZ_T-90_2_10 : slot 10 T-90 blue


## Spawn d'unité venant de l'éditeur

Il est possible de faire spawn un groupe créé directement dans l'éditeur, en utilisant le même modèle mais avec la commande #add : #add_NomUnité_Coalition_Nombre



## Spawn de convoi

Il est possible de faire spawn un convoi parmis une liste prédéfinie et d'indiquer la destination : 

Au niveau de la destination, déposer un marqueur et entrer la commande #destination
Au niveau du site de spawn, entrée un marqueur avec la commande suivante : #convoy_Type_Nom__Coalition 
Avec : 
 - Type : le type de convoi (voir ci-après)
 - Nom : le nom de votre convoi, il doit ête unique si vous en faîtes slot plusieurs en même temps
 - Coalition : 1 (Red) ou 2 (Bleu), 1 par défaut

### Type de convoi (code et description) : 

 - heavy : convoi lourdement armé comprenant des Tank, des BTR, des SAM (SA15 et SA9) et une ZSU
 - sa9 : convoi "heavy" sans SA15
 - zu : convoi "sa9" sans SA9
 - armored : convoi "zu" sans la ZSU23
 - t90 : convoi de 7 T90 et un Ural
 - t90SA : convoi "t90" avec un SA9 en plus
 - unArmored : convoi non armé de 9 Ural
 - scout : convoi comprenant plusieurs Urals, dont certains sont armés 
 - uniq : convoi comportant une seule unité HL_KORD (Ural armé)

 ### Exemple d'utilisation : 

	#destination : pour la destination

	#convoy_heavy_Test : slot du convoi Red "heavy" avec le nom Test
    #convoy_sa9_Test2_2 : slot du convoi Bleu "sa9" avec le nom Test2


## Spawn d'unité à une position aléatoire dans une zone donnée : 

Si des zones ont été ajoutées dans l'éditeur et paramétrées dans le script via la fonction AddZone, il est possible d'utiliser le même type de commande qu'addZ mpour faire slot des unités aléatoirement de la zone : 

#zone_zoneName_TypeUnité_Coalition_Nombre  avec :

 - zoneName : le nom de la zone tel que définit sur le paramètre n°2 de AddZone 
 - TypeUnité : l'unité voulue (voir ci-dessus)
 - Coalition : 1 (Red) ou 2 (Bleu) (1 par défaut)
 - Nombre : le nombre d'unité (1 par défaut)

Il est possible d'utiliser le menu comm pour faire spawn dans une zone sans avoir à retenir le code : 
 - Dans le menu comm, choisir la zone
 - Taper la commande sans zoneName : #zone__TypeUnité_Coalition_Nombre (il y a 2 fois le caractère _)


## Explosion

Il est possible de générer une explosion de la puissance voulue : #explosion_Détonateur_Puissance avec :
 - Détonateur : le temps en seconde avant explosion
 - Puissance : la puissance de l'explosion (entre 1 et l'infini)
