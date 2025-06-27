-----------------------------------------------------------
-- Plugin DCS-BIOS Hub pour écran PCN M-2000C 
-- Compatible avec le nouveau système de SEGMENTS RAZBAM
-- Récupère les données des segments PCN (PCN_UL_SEG, PCN_UR_SEG, etc.)
-- Version: 2.0 - Système de segments
-----------------------------------------------------------

BIOS.protocol.beginModule("M-2000C", 0x7200)
BIOS.protocol.setExportModuleAircrafts({"M-2000C"})

local defineString = BIOS.util.defineString
local defineFloat = BIOS.util.defineFloat

-----------------------------------------------------------
-- FONCTIONS D'AFFICHAGE PCN SEGMENTS (NOUVEAU SYSTÈME RAZBAM)
-----------------------------------------------------------

-- Fonction pour récupérer les segments gauches (PCN_UL_SEG0 à PCN_UL_SEG7)
local function getPCNLeftSegments()
    local segments = {}
    
    -- Récupère chaque segment individuellement via les arguments DCS
    for i = 0, 7 do
        local arg_value = LoGetAircraftDrawArgumentValue(900 + i) -- Arguments segments PCN UL
        if arg_value and arg_value > 0 then
            segments[i + 1] = string.char(48 + math.floor(arg_value * 10)) -- Conversion en caractère
        else
            segments[i + 1] = " "
        end
    end
    
    return table.concat(segments)
end

-- Fonction pour récupérer les segments droits (PCN_UR_SEG0 à PCN_UR_SEG7)  
local function getPCNRightSegments()
    local segments = {}
    
    -- Récupère chaque segment individuellement via les arguments DCS
    for i = 0, 7 do
        local arg_value = LoGetAircraftDrawArgumentValue(910 + i) -- Arguments segments PCN UR
        if arg_value and arg_value > 0 then
            segments[i + 1] = string.char(48 + math.floor(arg_value * 10)) -- Conversion en caractère
        else
            segments[i + 1] = " "
        end
    end
    
    return table.concat(segments)
end

-- Fonction pour récupérer les segments PREP (PCN_BL_SEG0 à PCN_BL_SEG6)
local function getPCNPrepSegments()
    local segments = {}
    
    -- Récupère chaque segment PREP
    for i = 0, 6 do
        local arg_value = LoGetAircraftDrawArgumentValue(920 + i) -- Arguments segments PCN BL (PREP)
        if arg_value and arg_value > 0 then
            segments[i + 1] = string.char(48 + math.floor(arg_value * 10))
        else
            segments[i + 1] = " "
        end
    end
    
    return table.concat(segments)
end

-- Fonction pour récupérer les segments DEST (PCN_BR_SEG0 à PCN_BR_SEG6)
local function getPCNDestSegments()
    local segments = {}
    
    -- Récupère chaque segment DEST
    for i = 0, 6 do
        local arg_value = LoGetAircraftDrawArgumentValue(930 + i) -- Arguments segments PCN BR (DEST)
        if arg_value and arg_value > 0 then
            segments[i + 1] = string.char(48 + math.floor(arg_value * 10))
        else
            segments[i + 1] = " "
        end
    end
    
    return table.concat(segments)
end

-- Fonction pour les indicateurs gauches (N/S/+/-)
local function getPCNLeftIndicators()
    local n_value = LoGetAircraftDrawArgumentValue(901) -- PCN_UL_N
    local s_value = LoGetAircraftDrawArgumentValue(902) -- PCN_UL_S  
    local p_value = LoGetAircraftDrawArgumentValue(903) -- PCN_UL_P
    local m_value = LoGetAircraftDrawArgumentValue(904) -- PCN_UL_M
    
    local indicators = ""
    
    if n_value and n_value > 0.5 then indicators = indicators .. "N" end
    if s_value and s_value > 0.5 then indicators = indicators .. "S" end
    if p_value and p_value > 0.5 then indicators = indicators .. "+" end
    if m_value and m_value > 0.5 then indicators = indicators .. "-" end
    
    if indicators == "" then
        return " "
    elseif string.len(indicators) > 1 then
        return "*" -- Multiple indicateurs actifs
    else
        return indicators
    end
end

-- Fonction pour les indicateurs droits (E/W/+/-)
local function getPCNRightIndicators()
    local e_value = LoGetAircraftDrawArgumentValue(911) -- PCN_UR_E
    local w_value = LoGetAircraftDrawArgumentValue(912) -- PCN_UR_W
    local p_value = LoGetAircraftDrawArgumentValue(913) -- PCN_UR_P
    local m_value = LoGetAircraftDrawArgumentValue(914) -- PCN_UR_M
    
    local indicators = ""
    
    if e_value and e_value > 0.5 then indicators = indicators .. "E" end
    if w_value and w_value > 0.5 then indicators = indicators .. "W" end
    if p_value and p_value > 0.5 then indicators = indicators .. "+" end
    if m_value and m_value > 0.5 then indicators = indicators .. "-" end
    
    if indicators == "" then
        return " "
    elseif string.len(indicators) > 1 then
        return "*" -- Multiple indicateurs actifs
    else
        return indicators
    end
end

-----------------------------------------------------------
-- FONCTIONS ALTERNATIVES PAR LIST_INDICATION (AU CAS OÙ)
-----------------------------------------------------------

-- Fonction alternative utilisant list_indication pour les segments gauches
local function getPCNLeftSegmentsAlt()
    local li = list_indication(9)
    if not li then return "        " end
    
    local segments = {"", "", "", "", "", "", "", ""}
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    
    while true do
        local name, value = m()
        if not name then break end
        
        -- Recherche des segments UL
        for i = 0, 7 do
            if name == "PCN_UL_SEG" .. i then
                if value and value ~= "" then
                    segments[i + 1] = tostring(value)
                end
            end
        end
    end
    
    return table.concat(segments)
end

-- Fonction alternative utilisant list_indication pour les segments droits
local function getPCNRightSegmentsAlt()
    local li = list_indication(9)
    if not li then return "        " end
    
    local segments = {"", "", "", "", "", "", "", ""}
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    
    while true do
        local name, value = m()
        if not name then break end
        
        -- Recherche des segments UR
        for i = 0, 7 do
            if name == "PCN_UR_SEG" .. i then
                if value and value ~= "" then
                    segments[i + 1] = tostring(value)
                end
            end
        end
    end
    
    return table.concat(segments)
end

-- Fonction alternative pour PREP segments
local function getPCNPrepSegmentsAlt()
    local li = list_indication(10)
    if not li then return "       " end
    
    local segments = {"", "", "", "", "", "", ""}
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    
    while true do
        local name, value = m()
        if not name then break end
        
        -- Recherche des segments BL (PREP)
        for i = 0, 6 do
            if name == "PCN_BL_SEG" .. i then
                if value and value ~= "" then
                    segments[i + 1] = tostring(value)
                end
            end
        end
    end
    
    return table.concat(segments)
end

-- Fonction alternative pour DEST segments
local function getPCNDestSegmentsAlt()
    local li = list_indication(10)
    if not li then return "       " end
    
    local segments = {"", "", "", "", "", "", ""}
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    
    while true do
        local name, value = m()
        if not name then break end
        
        -- Recherche des segments BR (DEST)
        for i = 0, 6 do
            if name == "PCN_BR_SEG" .. i then
                if value and value ~= "" then
                    segments[i + 1] = tostring(value)
                end
            end
        end
    end
    
    return table.concat(segments)
end

-----------------------------------------------------------
-- DÉFINITIONS DES SORTIES PCN SEGMENTS
-----------------------------------------------------------

-- Méthode principale (Draw Arguments)
defineString("PCN_SEG_LEFT", getPCNLeftSegments, 8, "PCN SEGMENTS", "PCN Segments Gauche (UL_SEG0-7)")
defineString("PCN_SEG_RIGHT", getPCNRightSegments, 8, "PCN SEGMENTS", "PCN Segments Droit (UR_SEG0-7)")
defineString("PCN_SEG_PREP", getPCNPrepSegments, 7, "PCN SEGMENTS", "PCN Segments PREP (BL_SEG0-6)")
defineString("PCN_SEG_DEST", getPCNDestSegments, 7, "PCN SEGMENTS", "PCN Segments DEST (BR_SEG0-6)")
defineString("PCN_IND_LEFT", getPCNLeftIndicators, 1, "PCN SEGMENTS", "PCN Indicateurs Gauche (N/S/+/-)")
defineString("PCN_IND_RIGHT", getPCNRightIndicators, 1, "PCN SEGMENTS", "PCN Indicateurs Droit (E/W/+/-)")

-- Méthode alternative (List Indication)  
defineString("PCN_SEG_LEFT_ALT", getPCNLeftSegmentsAlt, 8, "PCN SEGMENTS ALT", "PCN Segments Gauche (Alternative)")
defineString("PCN_SEG_RIGHT_ALT", getPCNRightSegmentsAlt, 8, "PCN SEGMENTS ALT", "PCN Segments Droit (Alternative)")
defineString("PCN_SEG_PREP_ALT", getPCNPrepSegmentsAlt, 7, "PCN SEGMENTS ALT", "PCN Segments PREP (Alternative)")
defineString("PCN_SEG_DEST_ALT", getPCNDestSegmentsAlt, 7, "PCN SEGMENTS ALT", "PCN Segments DEST (Alternative)")

-----------------------------------------------------------
-- SEGMENTS INDIVIDUELS POUR DEBUG/ANALYSE FINE
-----------------------------------------------------------

-- Segments individuels gauches
for i = 0, 7 do
    local function getSegmentUL(seg_num)
        return function()
            local li = list_indication(9)
            if not li then return " " end
            
            local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
            while true do
                local name, value = m()
                if not name then break end
                
                if name == "PCN_UL_SEG" .. seg_num then
                    return value or " "
                end
            end
            return " "
        end
    end
    
    defineString("PCN_UL_SEG" .. i, getSegmentUL(i), 6, "PCN DEBUG", "PCN UL Segment " .. i)
end

-- Segments individuels droits
for i = 0, 7 do
    local function getSegmentUR(seg_num)
        return function()
            local li = list_indication(9)
            if not li then return " " end
            
            local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
            while true do
                local name, value = m()
                if not name then break end
                
                if name == "PCN_UR_SEG" .. seg_num then
                    return value or " "
                end
            end
            return " "
        end
    end
    
    defineString("PCN_UR_SEG" .. i, getSegmentUR(i), 6, "PCN DEBUG", "PCN UR Segment " .. i)
end

BIOS.protocol.endModule()