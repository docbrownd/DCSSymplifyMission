
local Persistance = PWS:New("SandFire")
Persistance:SaveReco()
Persistance:Init()

local recon = ReconClass:New(Persistance)
recon:Init()

local splash = SplashDamageClass:New()
splash:Init()

local Zeus = ZeusMod:New("MOOSERED")
    :Allow()
    :UsePassword('baloo')
    :ExcludePersistance(Persistance)
    :Init()
    --  :AllowMenu()


local Tacan = TacanBase:New()

local tacanN = TacanObj:New("Nevatim")
    :SetTacanCode("NEV")
    :SetFrequency(41)
    :SetBand("X")

local tacanM = TacanObj:New("Melez")
    :SetTacanCode("MEL")
    :SetFrequency(43)
    :SetBand("X")

local tacanC = TacanObj:New("Cairo International Airport")
    :SetTacanCode("CIA")
    :SetFrequency(44)
    :SetBand("X")


local tacanCW = TacanObj:New("Cairo West")
    :SetTacanCode("CWT")
    :SetFrequency(45)
    :SetBand("X")

    
local tacanW = TacanObj:New("Wadi al Jandali")
    :SetTacanCode("WAJ")
    :SetFrequency(97)
    :SetBand("X")


local tacanH = TacanObj:New("Hatzerim")
    :SetTacanCode("HZM")
    :SetFrequency(95)
    :SetBand("X")


Tacan:SetTacan(tacanN)
Tacan:SetTacan(tacanM)
Tacan:SetTacan(tacanC)
Tacan:SetTacan(tacanCW)
Tacan:SetTacan(tacanW)
Tacan:SetTacan(tacanH)




Tacan:Init()

local artillery = GroundArtillery:New()
artillery:AddGroundShootIf("Scud1", "Ramon Airbase")
artillery:AddGroundShootIf("Scud2", "Ovda")
artillery:AddGroundShootIf("Scud3", "Melez")
artillery:AddGroundShootIf("Ramon", "Kedem")
artillery:Init()




local MyCapture = CaptureAirBase:New(Persistance)
MyCapture:AddGroundControl(artillery)

MyCapture:AddbaseToCapture({base = "Al Mansurah", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})--C-130
MyCapture:AddbaseToCapture({base = "Ramon Airbase", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})
MyCapture:AddbaseToCapture({base = "Nevatim", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})
MyCapture:AddbaseToCapture({base = "Hatzerim", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})
MyCapture:AddbaseToCapture({base = "Ovda", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Patriot"})
MyCapture:AddbaseToCapture({base = "Melez", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Patriot"})
MyCapture:AddbaseToCapture({base = "Cairo International Airport", baseStart = "Ben-Gurion", plane = "C-17", groupPop = "Hawk"})
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
    :SetZones(baseAndZoneMap)
    :SetStartFrequency(251)
    :Init()


local MQ9Auto = Reaper:New()
    :SetZones(baseAndZoneMap)
    :SetStartFrequency(40)
    :NumberMax(5)
    :SetStartLaserCode(1681)
    :AutoLase({state = true, smoke = true, smokeColor = "red", tot = 30}) --red/green/white/orange/blue
    :Init()


local GANProgression = {
    IAprogression:New():SetPosition("PAZone"):SetPattern(100, 30,104):StartPatternAt(3), 
}

local AwacsProgression = {
    IAprogression:New():SetBases({"Melez", "Abu Rudeis","St Catherine"}):SetPosition("AwacsZoneCenter"):SetPatternRaceTrack(50, 150),
    IAprogression:New():SetBases({"Ovda", "Nevatim","Ramon Airbase"}):SetPosition("AwacsZoneSud"):SetPatternRaceTrack(50, 150),
    IAprogression:New():SetPosition("AwacsZoneNord"):SetPatternRaceTrack(50),
}

local tankers1Progression = {
    IAprogression:New():SetBases({"Cairo International Airport"}):SetPosition("KCOuest"):SetPatternRaceTrack(50, 160):SetTakeOff("Cairo International Airport"),
    IAprogression:New():SetBases({"Melez", "Abu Rudeis","St Catherine"}):SetPosition("KCSud"):SetPatternRaceTrack(50, 160),
    IAprogression:New():SetPosition("KCNord"):SetPatternRaceTrack(50, 106),
}


local tankersStart2 = {
    IAprogression:New():SetBases({"St Catherine","Abu Rudeis"}):SetPosition("KC2-sud"):SetPatternRaceTrack(50, 73)
}





local awacs1 = AwacsIA:New()
    :SetFrequency(280)
    :SetCallSignName("Darkstar")
    :SetCallSignGroup(1)
    :SetTakeOffFrom("Ben-Gurion")
    :SetProgression(AwacsProgression)

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

local tanker2 = TankerIA:New()
    :SetPlane("KC135MPRS")
    :SetAltitude(18000)
    :SetKnot(420)
    :SetFrequency(233)
    :SetTacan(TacanObj:New():SetTacanCode("KCM"):SetFrequency(33):SetBand("Y"))
    :SetCallSignName("Texaco")
    :SetCallSignGroup(1)
    :SetTakeOffFrom("Ben-Gurion")
    :SetProgression(tankers1Progression)


local tanker3 = TankerIA:New()
    :SetPlane("KC135")
    :SetAltitude(20000)
    :SetKnot(450)
    :SetFrequency(231)
    :SetTacan(TacanObj:New():SetTacanCode("KC2"):SetFrequency(31):SetBand("Y"))
    :SetCallSignName("Shell")
    :SetCallSignGroup(2)
    :SetTakeOffFrom("Ben-Gurion")
    :SetProgression(tankersStart2)

local tanker4 = TankerIA:New()
    :SetPlane("KC135MPRS")
    :SetAltitude(18000)
    :SetKnot(420)
    :SetFrequency(234)
    :SetTacan(TacanObj:New():SetTacanCode("KM2"):SetFrequency(34):SetBand("Y"))
    :SetCallSignName("Texaco")
    :SetCallSignGroup(2)
    :SetTakeOffFrom("Ben-Gurion")
    :SetProgression(tankersStart2)

local S3B = TankerIA:New()
    :SetPlane("S3B")
    :SetAltitude(8000)
    :SetKnot(400)
    :SetFrequency(263)
    :SetTacan(TacanObj:New():SetTacanCode("S3B"):SetFrequency(63):SetBand("Y"))
    :SetCallSignName("Arco")
    :SetCallSignGroup(1)
    :SetTakeOffFrom("Lincoln")


local gan = IAGAN:New()
    :SetGroupName("Groupe aeronaval")
    :AddShip(IAShip:New():SetName("Tarawa"):SetFrequency(226.5):SetTacan(TacanObj:New():SetTacanCode("TAW"):SetFrequency(26):SetBand("X")):SetICLS(5))
    :AddShip(IAShip:New():SetName("Lincoln"):SetFrequency(227.5):SetTacan(TacanObj:New():SetTacanCode("LNC"):SetFrequency(27):SetBand("X")):SetLink4(336):SetICLS(10):AddStatic('F18'))
    :AddShip(IAShip:New():SetName("Stennis"):SetFrequency(228.5):SetTacan(TacanObj:New():SetTacanCode("STN"):SetFrequency(28):SetBand("X")):SetLink4(346):SetICLS(15):AddStatic('F18'))
    :AddShip(IAShip:New():SetName("Washington"):SetFrequency(229.5):SetTacan(TacanObj:New():SetTacanCode("WAS"):SetFrequency(29):SetBand("X")):SetLink4(356):SetICLS(20))
    :SetProgression(GANProgression)
    :AddS3B(S3B)
    :Init()

local tomahawk = IATomahawk:New("Groupe aeronaval")
    :SetMissileMax(10)
    :SetDelay(30) --in min
    :SetTimeBetweenFire(5) --in s


local bombing = IABombing:New({
    takeOffFrom = "Ben-Gurion"
}) 


local IA = IABlue:New(Persistance)
    :SetTankers({tanker1, tanker2, tanker3, tanker4 })
    :SetAwacs({awacs1})
    :SetZones(baseAndZoneMap)
    :AllowedCruise(tomahawk) 
    :AllowedSatReco()
    :ShowTrainingZone("Training target-4")
    :AllowedBombing(bombing)
    :SetPA({gan})
    :Init()
    


local SyAAFAirForceCAP = {
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


local SyAAFAirForcePACAP = {
    "SyAAF Su-33"
}




local newCAP = AutoCAP:New()
    :InitCarrier("Admiral Kuznetsov")
    :InitAirForce(SyAAFAirForceCAP)
    :InitCarrierAirForce(SyAAFAirForcePACAP)
    :SetRatioBlueRed(5) -- N blue for 1 GROUP red
    :SetMaxGroup(5)
    :Init()

local JTACHeli = AutoJTACGround:New()
    :SetEditorDefaut("MOOSERED")
    :NumberMax(5)
    :SetStartLaserCode(1511)
    :Smoke('red')
    :Init()

local ctld = CSARCTLD:New(Persistance)
    :SetJTAC(JTACHeli)
    :TurnOffFenwick()
    :AllowHeli("UH-1H", {'jtac', "manpad", "fob"})
    :Init()

local captureAirRed = RedIAPlane:New()
    :AddRedAirCaptureBase("Melez")
    :AddRedAirCaptureBase("Nevatim")
    :AddRedAirCaptureBase("Ovda")
    :AddRedAirCaptureBase("Fayed")
    :AddRedAirCaptureBase("FAl Mansurahayed")
    :AddRedAirCaptureBase("El Arish")


local captureGroundBases = RedConvoiRecapture:New()
    :AddRedGroundCaptureBase({start = "El Arish", destination = "El Gora"})
    :AddRedGroundCaptureBase({start = "Bir Hasanah", destination = "Melez"})
    :AddRedGroundCaptureBase({start = "Fayed", destination = "Kibrit Air Base"})
    :AddRedGroundCaptureBase({start = "Fayed", destination = "Al Ismailiyah"})
    :AddRedGroundCaptureBase({start = "Cairo International Airport", destination = "Wadi al Jandali"})



local red = RedIA:New() 
    :SetHQs({'Cairo International Airport'})
    :AllowHeliLogisticManpad(10,30) --min, max, obj
    :AllowHeliLogistic(10,15) 
    :AllowBomber(45,60) --min, max, obj
    :AllowSEAD(30, 45) --min, max, obj
    :AllowAirRecapture(30,40, captureAirRed)
    :AllowGroundRedRecapture(25, 35, captureGroundBases)
    :RedGroundCaptureGroup({"unArmored","armored","scout","zu","zu","sa9", "sa9","heavy", "heavy"})
    :RedSpawnCapturegroup({"redGround"})
    :SetAutoMessage()
    :Init()




local buildingControle = BuildingControl:New()
    buildingControle:AddBuildingAction({
        zones = {"gas_water_cooling_01", "gas_administration_01"}, 
        message = "Centrale détruite, site SAM SA2/SA10 sur Melez inactifs", 
        type = {"ground"}, 
        groundGroup = {"SA2Melez", "SA10Melez" }
    })
    
    buildingControle:Init()


--------- Partie JTAC Sol non présent dans la mission ---------- 

local zonesJTAC = { -- attnetion ne marchera pas sur sinai
    ["Nord"] = {
        {nom = "JTAC-Firu", display = "Firuzabad (XM59)"},
        {nom = "JTAC-Bandegan", display = "Bandegan (YM79)"},
        {nom = "JTAC-Hajiabad", display = "Hajiabad (BS44)"},
        {nom = "JTAC-LAR", display = "Lar"},
        {nom = "JTAC-BANDAR", display = "Bandar Abbas"},
        {nom = "JTAC-Jenah", display = "Jenah (BQ39)"},
    },

    ["Centre"] = {
        {nom = "JTAC-QUESHM", display = "Queshm Island"},
        {nom = "JTAC-KISH", display = "Kish Intl"},
        {nom = "JTAC-Bandar", display = "Bandar Lengeh"},
        {nom = "JTAC-KHASAB", display = "Khasab"},
        {nom = "JTAC-Ras-Al-Khaimah", display = "Ras-Al-Khaimah (DP05)"},
        {nom = "JTAC-Masafi", display = "Masafi (DN19)"},
    },

    ["Sud"] = {
        {nom = "JTAC-AL MINHAB", display = "Al Minhad"},
        {nom = "JTAC-Muzeira", display = "Muzeira (DN04)"},
        {nom = "JTAC-Sweihan", display = "Sweihan (CN20)"},
        {nom = "JTAC-Al-Khatim", display = "Al-Khatim (CM07)"},
    },
}


local jtac = AutoJTACGround:New()
    :SetZones(zonesJTAC)
    :NumberMax(5)
    :SetStartLaserCode(1681)
    :Smoke('red')
    :Init()

----

local menu = Menu:New()
    :AddGroundJTAC(jtac) -- pour les JTAC au sol
    :AddMQ9(MQ9)
    :AddAutoMQ9(MQ9Auto)
    :AddIA(IA)
    :AddFrequences()
    :Init()

Mission:New():AllowBlockSlot(50):Init()  
