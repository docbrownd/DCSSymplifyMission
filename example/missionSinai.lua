
local Persistance = PWS:New("MaMission")
Persistance:SaveReco()
Persistance:Init()

local recon = ReconClass:New(Persistance)
recon:Init()

local splash = SplashDamageClass:New()
splash:Init()

local Zeus = ZeusMod:New("MOOSERED")
Zeus:Allow()
Zeus:UsePassword('password')
Zeus:ExcludePersistance(Persistance)
Zeus:Init()


local Tacan = TacanBase:New()


Tacan:AddTacan({
    code = "NEV",
    frequency = 41,
    band = "X",
    base = "Nevatim"
})


Tacan:AddTacan({
    code = "MEL",
    frequency = 43,
    band = "X",
    base = "Melez"
})

Tacan:AddTacan({
    code = "CIA",
    frequency = 44,
    band = "X",
    base = "Cairo International Airport"
})


Tacan:AddTacan({
    code = "CWT",
    frequency = 45,
    band = "X",
    base = "Cairo West"
})

Tacan:AddTacan({
    code = "WAJ",
    frequency = 97,
    band = "X",
    base = "Wadi al Jandali"
})

Tacan:AddTacan({
    code = "HZM",
    frequency = 95,
    band = "X",
    base = "Hatzerim"
})

Tacan:Init()

local artillery = GroundArtillery:New()
artillery:AddGroundShootIf("Scud1", "Ramon Airbase")
artillery:AddGroundShootIf("Scud2", "Ovda")
artillery:AddGroundShootIf("Scud3", "Melez")
artillery:AddGroundShootIf("Ramon", "Kedem")
artillery:Init()




local MyCapture = CaptureAirBase:New(Persistance)
MyCapture:AddGroundControl(artillery)

MyCapture:AddbaseToCapture({base = "Al Mansurah", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})
MyCapture:AddbaseToCapture({base = "Nevatim", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})
MyCapture:AddbaseToCapture({base = "Hatzerim", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})
MyCapture:AddbaseToCapture({base = "Ovda", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Patriot"})
MyCapture:AddbaseToCapture({base = "Melez", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Patriot"})
MyCapture:AddbaseToCapture({base = "Cairo International Airport", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})
MyCapture:AddbaseToCapture({base = "Ramon Airbase", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})
MyCapture:AddbaseToCapture({base = "Fayed", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})


MyCapture:AddbaseAutoCapture("Abu Rudeis")
MyCapture:AddbaseAutoCapture("St Catherine")
MyCapture:AddbaseAutoCapture("Wadi al Jandali")
MyCapture:AddbaseAutoCapture("Cairo West")
MyCapture:AddbaseAutoCapture("El Arish")
MyCapture:AddbaseAutoCapture("El Gora")
MyCapture:AddbaseAutoCapture("Kibrit Air Base")
MyCapture:AddbaseAutoCapture("Bir Hasanah")
MyCapture:AddbaseAutoCapture("Kedem")
MyCapture:AddbaseAutoCapture("AzZaqaziq")
MyCapture:AddbaseAutoCapture("Al Ismailiyah")


MyCapture:RedGroundCaptureGroup({"unArmored","armored","scout","zu","zu","sa9", "sa9","heavy", "heavy"}) -- N group choose randomly. choose in Convoy Class

MyCapture:RedSpawnCapturegroup({"redGround"}) -- editor group name


MyCapture:RedMaxGroundSpawn( {
    { min = 3, max = 6, },
    { min = 7, max = 10},
    { min = 11}
}
)


MyCapture:RedGroundSpawnTime(1200) --time in s before respawn for same group



MyCapture:AddRedGroundCaptureBase({start = "El Arish", destination = "El Gora"})
MyCapture:AddRedGroundCaptureBase({start = "Bir Hasanah", destination = "Melez"})
MyCapture:AddRedGroundCaptureBase({start = "Fayed", destination = "Kibrit Air Base"})
MyCapture:AddRedGroundCaptureBase({start = "Fayed", destination = "Al Ismailiyah"})
MyCapture:AddRedGroundCaptureBase({start = "Cairo International Airport", destination = "Wadi al Jandali"})

MyCapture:RedAirCaptureHQ({"Cairo International Airport"})
MyCapture:AddRedAirCaptureBase("Melez")
MyCapture:AddRedAirCaptureBase("Nevatim")
MyCapture:AddRedAirCaptureBase("Ovda")
MyCapture:AddRedAirCaptureBase("Fayed")
MyCapture:AddRedAirCaptureBase("Al Mansurah")
MyCapture:AddRedAirCaptureBase("El Arish")



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



local tanker3 = TankerIA:New({
    plane = "KC135", 
    alt = 20000, 
    knot = 450, 
    frequency = 231, 
    tacan = {frequency = 31, band = "X", code = "KC2"}, 
    callsign = {name = "Shell", groupeNumber = 2}, 
    takeOffFrom = "Ben-Gurion",
    startTo = {
        startPosition = "KC135-sud-1", 
        endPosition = "KC135-sud-2", 
        bases = {
            "St Catherine",
            "Abu Rudeis"
        }
    },
 
})

local tanker4 = TankerIA:New({
    plane = "KC135MPRS", 
    alt = 18000, 
    knot = 420, 
    frequency = 234, 
    tacan = {frequency = 34, band = "X", code = "KM2"}, 
    callsign = {name = "Texaco", groupeNumber = 2}, 
    takeOffFrom = "Ben-Gurion",
    startTo = {
        startPosition = "KC135-sud-1", 
        endPosition = "KC135-sud-2", 
        bases = {
            "St Catherine",
            "Abu Rudeis"
        }
    },

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
IA:SetTankers({tanker1, tanker2, tanker3, tanker4 })
IA:SetAwacs({awacs1})
IA:SetZones(baseAndZoneMap)
IA:AllowedCruise(tomahawk) 
IA:AllowedSatReco()
IA:ShowTrainingZone("Training target-4")
IA:AllowedBombing(bombing)
IA:SetPA(gan)
IA:Init()


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
        planes = SyAAFAirForceCAP,
        start = {"Abu Rudeis", "St Catherine" },
        objectif = "Ovda",
        name = "Hotel",
        minPlayer =  6
    }
)

redCap:Init()


local menu = Menu:New()
menu:AddMQ9(MQ9)
menu:AddAutoMQ9(MQ9Auto)
menu:AddIA(IA)
menu:AddFrequences()
menu:Init()

