-----------------------------------------------------------
-- Plugin DCS-BIOS Hub pour écran PCN M-2000C - VERSION CORRIGÉE
-- Compatible avec le nouveau système de SEGMENTS RAZBAM
-- Utilise les bonnes adresses mémoire du module M-2000C officiel
-- Version: 2.1 - Fix adresses et méthodes
-----------------------------------------------------------

BIOS.protocol.beginModule("M-2000C", 0x7200)
BIOS.protocol.setExportModuleAircrafts({"M-2000C"})

local defineString = BIOS.util.defineString

-----------------------------------------------------------
-- FONCTIONS PCN SEGMENTS CORRIGÉES
-----------------------------------------------------------

-- Fonction pour récupérer les segments gauches via list_indication
local function getPCNLeftSegments()
    local li = list_indication(9)
    if not li then return "        " end
    
    local segments = {"", "", "", "", "", "", "", ""}
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    
    while true do
        local name, value = m()
        if not name then break end
        
        -- Recherche des segments PCN_UL_SEG avec index
        if name and name:match("^PCN_UL_SEG") then
            local seg_index = tonumber(name:match("PCN_UL_SEG(%d+)"))
            if seg_index and seg_index >= 0 and seg_index <= 7 then
                if value and value ~= "" then
                    segments[seg_index + 1] = tostring(value)
                end
            end
        end
    end
    
    return table.concat(segments)
end

-- Fonction pour récupérer les segments droits via list_indication
local function getPCNRightSegments()
    local li = list_indication(9)
    if not li then return "        " end
    
    local segments = {"", "", "", "", "", "", "", ""}
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    
    while true do
        local name, value = m()
        if not name then break end
        
        -- Recherche des segments PCN_UR_SEG avec index
        if name and name:match("^PCN_UR_SEG") then
            local seg_index = tonumber(name:match("PCN_UR_SEG(%d+)"))
            if seg_index and seg_index >= 0 and seg_index <= 7 then
                if value and value ~= "" then
                    segments[seg_index + 1] = tostring(value)
                end
            end
        end
    end
    
    return table.concat(segments)
end

-- Fonction pour récupérer les segments PREP via list_indication
local function getPCNPrepSegments()
    local li = list_indication(10)
    if not li then return "       " end
    
    local segments = {"", "", "", "", "", "", ""}
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    
    while true do
        local name, value = m()
        if not name then break end
        
        -- Recherche des segments PCN_BL_SEG avec index
        if name and name:match("^PCN_BL_SEG") then
            local seg_index = tonumber(name:match("PCN_BL_SEG(%d+)"))
            if seg_index and seg_index >= 0 and seg_index <= 6 then
                if value and value ~= "" then
                    segments[seg_index + 1] = tostring(value)
                end
            end
        end
    end
    
    return table.concat(segments)
end

-- Fonction pour récupérer les segments DEST via list_indication
local function getPCNDestSegments()
    local li = list_indication(10)
    if not li then return "       " end
    
    local segments = {"", "", "", "", "", "", ""}
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    
    while true do
        local name, value = m()
        if not name then break end
        
        -- Recherche des segments PCN_BR_SEG avec index
        if name and name:match("^PCN_BR_SEG") then
            local seg_index = tonumber(name:match("PCN_BR_SEG(%d+)"))
            if seg_index and seg_index >= 0 and seg_index <= 6 then
                if value and value ~= "" then
                    segments[seg_index + 1] = tostring(value)
                end
            end
        end
    end
    
    return table.concat(segments)
end

-- Fonction pour les indicateurs gauches (N/S/+/-)
local function getPCNLeftIndicators()
    local li = list_indication(9)
    if not li then return " " end
    
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    local count = 0
    local ret = " "
    
    while true do
        local name, value = m()
        if not name then break end
        
        if name == "PCN_UL_N" then
            count = count + 1
            ret = "N"
        elseif name == "PCN_UL_S" then
            count = count + 1
            ret = "S"
        elseif name == "PCN_UL_P" then
            count = count + 1
            ret = "+"
        elseif name == "PCN_UL_M" then
            count = count + 1
            ret = "-"
        end
    end
    
    if count > 1 then ret = "*" end
    return ret
end

-- Fonction pour les indicateurs droits (E/W/+/-)
local function getPCNRightIndicators()
    local li = list_indication(9)
    if not li then return " " end
    
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    local count = 0
    local ret = " "
    
    while true do
        local name, value = m()
        if not name then break end
        
        if name == "PCN_UR_E" then
            count = count + 1
            ret = "E"
        elseif name == "PCN_UR_W" or name == "PCN_UR_O" then
            count = count + 1
            ret = "W"
        elseif name == "PCN_UR_P" then
            count = count + 1
            ret = "+"
        elseif name == "PCN_UR_M" then
            count = count + 1
            ret = "-"
        end
    end
    
    if count > 1 then ret = "*" end
    return ret
end

-----------------------------------------------------------
-- FONCTIONS DE DEBUG - POUR ANALYSER LES INDICATIONS
-----------------------------------------------------------

-- Fonction de debug pour lister toutes les indications niveau 9
local function getPCNDebugList9()
    local li = list_indication(9)
    if not li then return "NO_IND_9" end
    
    local debug_info = ""
    local count = 0
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    
    while true do
        local name, value = m()
        if not name then break end
        
        if name and name:match("PCN_") then
            count = count + 1
            if count <= 3 then -- Limite pour éviter chaînes trop longues
                debug_info = debug_info .. name .. ":" .. (value or "nil") .. ";"
            end
        end
    end
    
    if debug_info == "" then
        return "NO_PCN_DATA"
    else
        return debug_info:sub(1, 30) -- Limite à 30 caractères
    end
end

-- Fonction de debug pour lister toutes les indications niveau 10
local function getPCNDebugList10()
    local li = list_indication(10)
    if not li then return "NO_IND_10" end
    
    local debug_info = ""
    local count = 0
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    
    while true do
        local name, value = m()
        if not name then break end
        
        if name and name:match("PCN_") then
            count = count + 1
            if count <= 3 then
                debug_info = debug_info .. name .. ":" .. (value or "nil") .. ";"
            end
        end
    end
    
    if debug_info == "" then
        return "NO_PCN_DATA"
    else
        return debug_info:sub(1, 30)
    end
end

-----------------------------------------------------------
-- DÉFINITIONS DES SORTIES PCN (ADRESSES CORRIGÉES)
-----------------------------------------------------------

-- Sorties principales PCN segments
defineString("PCN_SEG_LEFT", getPCNLeftSegments, 8, "PCN SEGMENTS", "PCN Segments Gauche (UL_SEG0-7)")
defineString("PCN_SEG_RIGHT", getPCNRightSegments, 8, "PCN SEGMENTS", "PCN Segments Droit (UR_SEG0-7)")
defineString("PCN_SEG_PREP", getPCNPrepSegments, 7, "PCN SEGMENTS", "PCN Segments PREP (BL_SEG0-6)")
defineString("PCN_SEG_DEST", getPCNDestSegments, 7, "PCN SEGMENTS", "PCN Segments DEST (BR_SEG0-6)")
defineString("PCN_IND_LEFT", getPCNLeftIndicators, 1, "PCN SEGMENTS", "PCN Indicateurs Gauche (N/S/+/-)")
defineString("PCN_IND_RIGHT", getPCNRightIndicators, 1, "PCN SEGMENTS", "PCN Indicateurs Droit (E/W/+/-)")

-- Sorties de debug
defineString("PCN_DEBUG_9", getPCNDebugList9, 30, "PCN DEBUG", "PCN Debug Indication 9")
defineString("PCN_DEBUG_10", getPCNDebugList10, 30, "PCN DEBUG", "PCN Debug Indication 10")

-----------------------------------------------------------
-- SEGMENTS INDIVIDUELS POUR ANALYSE DÉTAILLÉE
-----------------------------------------------------------

-- Segments individuels gauches pour debug
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

-- Segments individuels droits pour debug
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