
local Persistance = PWS:New("MaMission")
Persistance:SaveReco()
Persistance:Init()

local recon = ReconClass:New(Persistance)
recon:Init()

local splash = SplashDamageClass:New()
splash:Init()

local Zeus = ZeusMod:New("MOOSERED")
Zeus:Allow()
Zeus:ExcludePersistance(Persistance)
Zeus:Init()


local Tacan = TacanBase:New()


Tacan:AddTacan({
    code = "NEV",
    frequency = 41,
    band = "X",
    base = "Nevatim"
})


Tacan:Init()

local artillery = GroundArtillery:New()
-- artillery:AddGroundShootIf("Scud1", "Ramon Airbase") -- ajouter un groupe Scud1 dans l'éditeur avant d'activer cette ligne
artillery:Init()



local MyCapture = CaptureAirBase:New(Persistance)
MyCapture:AddGroundControl(artillery)

MyCapture:AddbaseToCapture({base = "Al Mansurah", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})
MyCapture:AddbaseToCapture({base = "Ovda", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Patriot"})

MyCapture:AddbaseAutoCapture("Abu Rudeis")
MyCapture:AddbaseAutoCapture("St Catherine")

MyCapture:RedGroundCaptureGroup({"unArmored","armored","scout","zu","zu","sa9", "sa9","heavy", "heavy"}) -- N group choose randomly. choose in Convoy Class
MyCapture:RedSpawnCapturegroup({"redGround"}) -- editor group name


MyCapture:RedMaxGroundSpawn( {
    { min = 3, max = 6, },
    { min = 7, max = 10},
    { min = 11}
}
)

MyCapture:AddRedGroundCaptureBase({start = "El Arish", destination = "El Gora"})
MyCapture:AddRedGroundCaptureBase({start = "Bir Hasanah", destination = "Melez"})

MyCapture:RedAirCaptureHQ({"Cairo International Airport"})
MyCapture:AddRedAirCaptureBase("Melez")
MyCapture:AddRedAirCaptureBase("Nevatim")

MyCapture:Init()


local baseAndZoneMap = {
    ["Israel"] = {
        "Hatzerim",
        "Kedem",
        "Nevatim",
        "Ovda",
        "Ramon Airbase"
    },
    ["Est Egypte"] = {
        "Abu Rudeis", "El Arish", "Melez", "St Catherine", "El Gora"
    },
    ["Ouest Egypte"] = {
        "Al Mansurah", "Cairo West", "Cairo International Airport","Fayed", "Wadi al Jandali"
    }
}

local MQ9 = Reaper:New()
MQ9:SetZones(baseAndZoneMap)
MQ9:SetStartFrequency(272)
MQ9:Init()

local MQ9Auto = Reaper:New()
MQ9Auto:SetZones(baseAndZoneMap)
MQ9Auto:SetStartFrequency(40)
MQ9Auto:NumberMax(5)
MQ9Auto:SetStartLaserCode(1681)
MQ9Auto:AutoLase({state = true, smoke = true, smokeColor = "red", tot = 30}) --red/green/white/orange/blue
MQ9Auto:Init()

local awacs1 = AwacsIA:New({
    frequency = 280,
    callsign = {name = "Darkstar", groupeNumber = 1}, 
    takeOffFrom = "Ben-Gurion",
    startTo = "awacs-1",
    progression = { -- last position in first !
        {bases = {"Melez", "Abu Rudeis","St Catherine" }, position = "awacs-3"},
        {bases = {"Ovda", "Nevatim","Ramon Airbase" }, position = "awacs-2"}
    }
})


local tanker1 = TankerIA:New({
    plane = "KC135", 
    alt = 20000, 
    knot = 450, 
    frequency = 230, 
    tacan = {frequency = 30, band = "X", code = "KC1"}, 
    callsign = {name = "Shell", groupeNumber = 1}, 
    takeOffFrom = "Ben-Gurion",
    startTo = {startPosition = "KC135-1-1", endPosition = "KC135-1-2"},
    progression = {
        {bases = {"Melez", "Abu Rudeis","St Catherine" }, startPosition = "KC135-3-1", endPosition = "KC135-3-2"},
        {bases = {"Ovda", "Nevatim","Ramon Airbase" }, startPosition = "KC135-2-1", endPosition = "KC135-2-2"}
    }
})


local tanker2 = TankerIA:New({
    plane = "KC135MPRS", 
    alt = 18000, 
    knot = 420, 
    frequency = 233, 
    tacan = {frequency = 33, band = "X", code = "KCM"}, 
    callsign = {name = "Texaco", groupeNumber = 1}, 
    takeOffFrom = "Ben-Gurion",
    startTo = {startPosition = "KC135-1-1", endPosition = "KC135-1-2"},
    progression = {
        {bases = {"Melez", "Abu Rudeis","St Catherine" }, startPosition = "KC135-3-1", endPosition = "KC135-3-2"},
        {bases = {"Ovda", "Nevatim","Ramon Airbase" }, startPosition = "KC135-2-1", endPosition = "KC135-2-2"}
    }
})

-- just for message informations
local gan = IAGAN:New({
    groupeName = "Groupe aeronaval", 
    ships = {
        {name = "Lincoln", frequency = "127.5MHz" , tacan = "72X", tacanInfos = "LNC", link4 = "336MHz", ICLS = "20"},
        {name = "Stennis", frequency = "129.5MHz" , tacan = "52X", tacanInfos = "STN", link4 = "316MHz", ICLS = "10"},
        {name = "Washington", frequency = "128.5MHz" , tacan = "62X", tacanInfos = "WHG", link4 = "326MHz", ICLS = "15"}
    }
})


local tomahawk = IATomahawk:New("Groupe aeronaval")
tomahawk:SetMissileMax(10)
tomahawk:SetDelay(30) --in min
tomahawk:SetTimeBetweenFire(5) --in s


local bombing = IABombing:New({
    takeOffFrom = "Ben-Gurion"
}) 


local IA = IABlue:New(Persistance)
IA:SetTankers({tanker1, tanker2 })
IA:SetAwacs({awacs1})
IA:SetZones(baseAndZoneMap)
IA:AllowedCruise(tomahawk) 
IA:AllowedSatReco()
IA:AllowedBombing(bombing)
IA:SetPA(gan)
-- IA:ShowTrainingZone("Training target-4") -- ajouter une zone Training target-4 dans l'éditeur
IA:Init()

local menu = Menu:New()
menu:AddMQ9(MQ9)
menu:AddAutoMQ9(MQ9Auto)
menu:AddIA(IA)
menu:AddFrequences()
menu:Init()


SyAAFAirForceCAP = {
    "SyAAF JF-17", --1/14
    "SyAAF Su-30",
    "SyAAF Su-33",
    "SyAAF Mig-31",
    "SyAAF Mig-31",
    "SyAAF Mig-23",
    "SyAAF Mig-23",
    "SyAAF Mig-23",
    "SyAAF Mig-23",
    "SyAAF Mig-29A",
    "SyAAF Mig-29A",
    "SyAAF Mig-29S", -- 3/14
    "SyAAF Mig-29S",
    "SyAAF Mig-29S",
}


SyAAFAirForcePACAP = {
    "SyAAF Su-33"
}


local redCap = CAP:New()

redCap:AddGroup(
    {
        planes = SyAAFAirForcePACAP,
        start = {"Admiral Kuznetsov"},
        objectif = "Bir Hasanah",
        name = "Alpha",
        toPA = true,
        blockIfBlue = "Melez",
    }
)

redCap:AddGroup(
    {
        planes = SyAAFAirForcePACAP,
        start = {"Admiral Kuznetsov"}, -- nommer le PA russe 'Admiral Kuznetsov'
        objectif = "Cairo International Airport",
        name = "Bravo",
        toPA = true,
        blockIfRed = "Melez",
    }
)

redCap:AddGroup(
    {
        planes = SyAAFAirForceCAP,
        start = {"Inshas Airbase" },
        objectif = "Melez",
        name = "Juliet",
        blockIfRed = "Melez",
        minPlayer = 14
    }
)

redCap:Init()



