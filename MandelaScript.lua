--[[
    STEAL AN EGG  |  FARM GUI  |  Xeno
    Ciclo: detectar -> TP al huevo -> robar -> TP ANTES del spawn ->
           soltar 2s -> agarrar otra vez -> TP al spawn (linea segura).

    Xeno es externo: usamos remotes oficiales del juego + hop TP
    (TP instantaneo lo detecta el anti-teleport y el huevo vuelve al nido).

    USO:
    1. Ejecuta en Xeno dentro de Steal An Egg.
    2. (Opcional) Ponte justo ANTES de la linea roja y pulsa Marcar Pre-Spawn.
       Ponte en tu base y pulsa Marcar Spawn. Si no, se auto-marca.
    3. Elige MEJOR o un huevo de la lista.
    4. Pulsa FARM.
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players           = game:GetService("Players")
local UIS               = game:GetService("UserInputService")
local VIM               = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local GuiService        = game:GetService("GuiService")

local lp      = Players.LocalPlayer
local USER_ID = lp.UserId
local pg      = lp:WaitForChild("PlayerGui")

_G.__SAEFarmGen = (_G.__SAEFarmGen or 0) + 1
local GEN = _G.__SAEFarmGen

local old = pg:FindFirstChild("XenoFarmGui")
if old then old:Destroy() end

----------------------------------------------------------------
-- API opcional de executor
----------------------------------------------------------------
local firePP, fireCD, fireTI, fireSig
pcall(function() firePP  = fireproximityprompt end)
pcall(function() fireCD  = fireclickdetector end)
pcall(function() fireTI  = firetouchinterest end)
pcall(function() fireSig = firesignal end)

----------------------------------------------------------------
-- Modulos oficiales del juego (si Xeno deja require)
----------------------------------------------------------------
local function tryRequire(path)
    local node = ReplicatedStorage
    for part in string.gmatch(path, "[^%.]+") do
        node = node and node:FindFirstChild(part)
        if not node then return nil end
    end
    local ok, mod = pcall(require, node)
    if ok then return mod end
    return nil
end

local EggCmds   = tryRequire("Library.Client.EggCmds")
local PlotCmds  = tryRequire("Library.Client.PlotCmds")
local Save      = tryRequire("Library.Client.Save")
local AssetsDir = tryRequire("Directory.Assets")
local TimeUtil  = tryRequire("Library.Util.AreaEggResetTimeUtil")

----------------------------------------------------------------
-- Remotes (nombres actuales + busqueda por si los renombran)
----------------------------------------------------------------
local function findRemote(exact, contains)
    local best
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("RemoteFunction") or d:IsA("RemoteEvent") then
            if d.Name == exact then return d end
            if contains and string.find(d.Name, contains, 1, true) then
                best = best or d
            end
        end
    end
    return best
end

local CarryRemote    = findRemote("RF/EggWorld/AskFieldEggCarry", "AskFieldEggCarry")
                    or findRemote("Eggs: RequestCarryAreaEgg", "RequestCarryAreaEgg")
local SnapshotRemote = findRemote("RF/EggWorld/AskFieldEggSnapshot", "AskFieldEggSnapshot")
local PlaceRemote    = findRemote("RF/EggWorld/AskPlaceEgg", "AskPlaceEgg")
                    or findRemote("Eggs: RequestPlaceEgg", "RequestPlaceEgg")
local DropRemote     = findRemote("RF/EggWorld/AskDropFieldEgg", "AskDrop")
                    or findRemote("Eggs: RequestDropHeldAreaEgg", "DropHeld")
                    or findRemote("RF/EggWorld/AskDropHeld", "DropField")

local function invoke(remote, ...)
    if not remote then return nil, "no-remote" end
    local args = {...}
    if remote:IsA("RemoteFunction") then
        return pcall(function() return remote:InvokeServer(unpack(args)) end)
    end
    local ok, err = pcall(function() remote:FireServer(unpack(args)) end)
    return ok, err
end

----------------------------------------------------------------
-- Config
----------------------------------------------------------------
local CFG = {
    farming   = false,
    selected  = "MEJOR",
    preSpawn  = nil,
    spawn     = nil,
    dropTime  = 2,
    autoPlace = true,
}

local RARITY = {
    Divine = 1000, Eternal = 900, Secret = 800, Cosmic = 700,
    Mythic = 600, Mythical = 600, Legendary = 500, Epic = 400,
    Rare = 300, Uncommon = 200, Common = 100,
}

local AREA_RANK = {
    Forest = 1, Lake = 2, Desert = 3, Jungle = 4, Snow = 5,
    Volcano = 6, ["Abyss Ocean"] = 7, Prehistoric = 8, Cosmic = 9,
    ["Cherry Blossom"] = 10, Sakura = 10, ["Titan Temple"] = 11,
    ["Light Dark"] = 12, ["Angels and Demons"] = 13,
}

----------------------------------------------------------------
-- Personaje / teclas
----------------------------------------------------------------
local function hrp()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function hum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function pressKey(key, hold)
    hold = hold or 0.08
    pcall(function()
        VIM:SendKeyEvent(true,  key, false, game)
        task.wait(hold)
        VIM:SendKeyEvent(false, key, false, game)
    end)
end

local function clickGui(btn)
    if not btn then return end
    pcall(function()
        if fireSig then fireSig(btn.MouseButton1Click) end
        btn.MouseButton1Click:Fire()
    end)
    pcall(function()
        local p = btn.AbsolutePosition
        local s = btn.AbsoluteSize
        local inset = GuiService:GetGuiInset()
        local x = p.X + s.X / 2
        local y = p.Y + s.Y / 2 + inset.Y
        VIM:SendMouseButtonEvent(x, y, 0, true,  game, 1)
        task.wait(0.04)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)
end

----------------------------------------------------------------
-- Mapa: linea segura, base, noche
----------------------------------------------------------------
local function gameplayLine()
    local areas = Workspace:FindFirstChild("__OBJECTS")
    areas = areas and areas:FindFirstChild("Areas")
    local line = areas and areas:FindFirstChild("GameplayZ")
    if line and line:IsA("BasePart") then return line end
    return nil
end

local function plotData()
    if PlotCmds and PlotCmds.GetPlotData then
        local ok, data = pcall(PlotCmds.GetPlotData)
        if ok and type(data) == "table" then return data end
    end
    return nil
end

local function petArea()
    local data = plotData()
    if data and data.PetArea then return data.PetArea end
    return nil
end

local function plotFolder()
    local data = plotData()
    if data and data.PlotFolder then return data.PlotFolder end
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, base in ipairs(plots:GetChildren()) do
            local ok, hit = pcall(function()
                local img = base:FindFirstChild("PlotSign", true)
                img = img and img:FindFirstChild("PlayerPlotSign", true)
                img = img and img:FindFirstChild("Frame", true)
                img = img and img:FindFirstChild("PlayerIcon", true)
                return img and img:IsA("ImageLabel") and tostring(img.Image):find(tostring(USER_ID), 1, true)
            end)
            if ok and hit then return base end
        end
    end
    return nil
end

local function roadY()
    local line = gameplayLine()
    if line then return line.Position.Y + 2.75 end
    local area = petArea()
    if area then return area.Position.Y + 2.65 end
    local p = hrp()
    return p and p.Position.Y or 70
end

local function roadZ()
    local line = gameplayLine()
    if line then return line.Position.Z end
    local area = petArea()
    if area then return area.Position.Z end
    local p = hrp()
    return p and p.Position.Z or 0
end

local function autoPreSpawn()
    local line = gameplayLine()
    if line then
        return CFrame.new(line.Position.X + 14, roadY(), roadZ())
    end
    local area = petArea()
    if area then
        return CFrame.new(area.Position.X + 40, roadY(), roadZ())
    end
    return nil
end

local function autoSpawn()
    local area = petArea()
    if area then
        return CFrame.new(area.Position + Vector3.new(0, 3.1, 0))
    end
    if PlotCmds and PlotCmds.GetRespawnPointCFrame then
        local ok, cf = pcall(PlotCmds.GetRespawnPointCFrame)
        if ok and typeof(cf) == "CFrame" then
            return cf + Vector3.new(0, 2, 0)
        end
    end
    local line = gameplayLine()
    if line then
        return CFrame.new(line.Position.X - 18, roadY(), roadZ())
    end
    return nil
end

local function isNight()
    if TimeUtil and TimeUtil.IsNight then
        local ok, night = pcall(TimeUtil.IsNight, Workspace:GetServerTimeNow())
        if ok then return night == true end
    end
    return false
end

local function anyGuardAt(pos, margin)
    margin = margin or 5
    local areas = Workspace:FindFirstChild("__OBJECTS")
    areas = areas and areas:FindFirstChild("Areas")
    local guards = areas and areas:FindFirstChild("GuardAreas")
    if not guards then return false end
    for _, g in ipairs(guards:GetChildren()) do
        local cf, size
        if g:IsA("Model") then
            cf, size = g:GetBoundingBox()
        elseif g:IsA("BasePart") then
            cf, size = g.CFrame, g.Size
        end
        if cf and size then
            local lp2 = cf:PointToObjectSpace(pos)
            if math.abs(lp2.X) <= size.X / 2 + margin
            and math.abs(lp2.Y) <= size.Y / 2 + margin
            and math.abs(lp2.Z) <= size.Z / 2 + margin then
                return true
            end
        end
    end
    return false
end

----------------------------------------------------------------
-- Hop TP (anti-teleport de Steal An Egg)
----------------------------------------------------------------
local function hopTo(toPos, stepStuds, holdSec)
    local part = hrp()
    if not part or not toPos then return false end
    if typeof(toPos) == "CFrame" then toPos = toPos.Position end
    local y, zRoad = roadY(), roadZ()
    toPos = Vector3.new(toPos.X, y, toPos.Z)
    stepStuds = stepStuds or 14
    holdSec = holdSec or 0.12
    local deadline = os.clock() + 18

    while GEN == _G.__SAEFarmGen and part and part.Parent and (part.Position - toPos).Magnitude > 3.2 do
        if os.clock() > deadline then break end
        local human = hum()
        if human and human.Health < 30 then return false end
        local delta = toPos - part.Position
        local nextPos = part.Position + delta.Unit * math.min(stepStuds, delta.Magnitude)
        nextPos = Vector3.new(nextPos.X, y, nextPos.Z)
        if anyGuardAt(nextPos, 3) then
            local slide = Vector3.new(nextPos.X, y, zRoad)
            if (slide - part.Position).Magnitude > 1 then
                nextPos = part.Position + (slide - part.Position).Unit
                    * math.min(stepStuds, (slide - part.Position).Magnitude)
                nextPos = Vector3.new(nextPos.X, y, nextPos.Z)
            end
            if anyGuardAt(nextPos, 3) then
                nextPos = Vector3.new(part.Position.X - 12, y, zRoad)
            end
        end
        local cf = CFrame.new(nextPos)
        local t0 = os.clock()
        while os.clock() - t0 < 0.07 and GEN == _G.__SAEFarmGen do
            part = hrp()
            if not part then return false end
            part.CFrame = cf
            part.AssemblyLinearVelocity = Vector3.zero
            task.wait()
        end
        part = hrp()
    end

    local dest = CFrame.new(toPos)
    local t1 = os.clock()
    while os.clock() - t1 < holdSec and GEN == _G.__SAEFarmGen do
        part = hrp()
        if not part then return false end
        part.CFrame = dest
        part.AssemblyLinearVelocity = Vector3.zero
        task.wait()
    end
    return true
end

----------------------------------------------------------------
-- Rareza / huevos del mapa
----------------------------------------------------------------
local function rarityOf(cat, extra)
    extra = extra or ""
    local blob = string.lower(tostring(cat) .. " " .. tostring(extra))
    local bestName, bestN = "Common", 100
    if AssetsDir and AssetsDir.Directory and AssetsDir.Directory[cat] then
        local rar = AssetsDir.Directory[cat].Rarity
        if type(rar) == "table" then
            if rar._id then bestName = tostring(rar._id) end
            if tonumber(rar.RarityNumber) then
                bestN = tonumber(rar.RarityNumber) * 100
            end
        end
    end
    for name, n in pairs(RARITY) do
        if string.find(blob, string.lower(name), 1, true) and n > bestN then
            bestName, bestN = name, n
        end
    end
    if string.find(blob, "rainbow", 1, true) then bestN = bestN + 80 end
    if string.find(blob, "gold", 1, true)    then bestN = bestN + 50 end
    if string.find(blob, "silver", 1, true)  then bestN = bestN + 30 end
    if string.find(blob, "shiny", 1, true)   then bestN = bestN + 25 end
    return bestName, bestN
end

local function slotsFolder()
    return Workspace:FindFirstChild("AreaEggSlotsClient")
end

local function snapshotRecords()
    if EggCmds then
        for _, fnName in ipairs({"GetAreaEggSnapshot", "ReadFieldEggs"}) do
            local fn = EggCmds[fnName]
            if type(fn) == "function" then
                local ok, snap = pcall(fn)
                if ok and type(snap) == "table" then
                    return snap.Records or snap
                end
            end
        end
    end
    if SnapshotRemote then
        invoke(SnapshotRemote)
        task.wait(0.1)
        if EggCmds and type(EggCmds.GetAreaEggSnapshot) == "function" then
            local ok, snap = pcall(EggCmds.GetAreaEggSnapshot)
            if ok and type(snap) == "table" then return snap.Records or snap end
        end
    end
    return nil
end

local function worldPart(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
    end
    return inst:FindFirstChildWhichIsA("BasePart", true)
end

local function scanEggs()
    local list, seen = {}, {}
    local origin = hrp() and hrp().Position or Vector3.zero

    local function add(uid, name, pos, inst, area, mut)
        uid = tostring(uid or "")
        if uid == "" or seen[uid] then return end
        if string.find(uid, tostring(USER_ID), 1, true) then return end
        if typeof(pos) ~= "Vector3" then return end
        local rarName, score = rarityOf(name, mut)
        score = score + (AREA_RANK[tostring(area or "")] or 0)
        seen[uid] = true
        table.insert(list, {
            uid    = uid,
            name   = tostring(name or "Egg"),
            rarity = rarName,
            area   = tostring(area or "?"),
            pos    = pos,
            inst   = inst,
            score  = score,
            dist   = (pos - origin).Magnitude,
            mut    = tostring(mut or ""),
        })
    end

    local recs = snapshotRecords()
    if type(recs) == "table" then
        for _, rec in pairs(recs) do
            if type(rec) == "table" and typeof(rec.BottomCFrame) == "CFrame" then
                local state = tostring(rec.State or "Slot")
                if state == "Slot" or state == "Dropped" or state == "Ground" or state == "" then
                    add(
                        rec.Uid,
                        rec.AssetCategory or rec.Name or "Egg",
                        rec.BottomCFrame.Position,
                        nil,
                        rec.AreaId,
                        rec.BaseMutation
                    )
                end
            end
        end
    end

    local folder = slotsFolder()
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            local part = worldPart(child)
            if part then
                local cat = child:GetAttribute("AssetCategory")
                    or child:GetAttribute("Name")
                    or child.Name
                local rar = child:GetAttribute("Rarity") or ""
                local area = child:GetAttribute("AreaId") or child:GetAttribute("Area") or ""
                add(child.Name, cat, part.Position, child, area, rar)
            end
        end
    end

    if CFG.selected ~= "MEJOR" then
        local want = string.lower(CFG.selected)
        local filtered = {}
        for _, e in ipairs(list) do
            if string.lower(e.name) == want then
                table.insert(filtered, e)
            end
        end
        if #filtered > 0 then list = filtered end
    end

    table.sort(list, function(a, b)
        if a.score ~= b.score then return a.score > b.score end
        return a.dist < b.dist
    end)
    return list
end

local function uniqueNames(list)
    local names, seen = {"MEJOR"}, {MEJOR = true}
    for _, e in ipairs(list) do
        if not seen[e.name] then
            seen[e.name] = true
            table.insert(names, e.name)
        end
        if #names >= 50 then break end
    end
    return names
end

local function eggModel(egg)
    if egg.inst and egg.inst.Parent then return egg.inst end
    local folder = slotsFolder()
    if folder then
        local m = folder:FindFirstChild(egg.uid)
        if m then return m end
    end
    return nil
end

----------------------------------------------------------------
-- Robar / soltar / colocar
----------------------------------------------------------------
local function isCarrying()
    local c = lp.Character
    if not c then return false end
    if c:FindFirstChildWhichIsA("Tool") then return true end
    if c:GetAttribute("Carrying") or c:GetAttribute("HoldingEgg") then return true end
    for _, d in ipairs(c:GetChildren()) do
        local n = string.lower(d.Name)
        if string.find(n, "egg", 1, true) then return true end
    end
    return false
end

local function stealEgg(egg)
    if not egg then return false end
    local model = eggModel(egg)
    local part  = model and worldPart(model)
    local dest  = (part and part.Position) or egg.pos
    if not dest then return false end

    local stand = Vector3.new(dest.X - 8, dest.Y, dest.Z)
    if anyGuardAt(stand, 2) then
        stand = Vector3.new(dest.X - 14, dest.Y, roadZ())
    end
    hopTo(stand, 14, 0.16)
    hopTo(dest, 10, 0.22)

    local uid = egg.uid
    local ok, res

    if EggCmds then
        for _, fnName in ipairs({"RequestCarryAreaEgg", "CarryFieldEgg"}) do
            if type(EggCmds[fnName]) == "function" then
                ok, res = pcall(EggCmds[fnName], uid)
                if ok and res == true then return true end
            end
        end
    end

    ok, res = invoke(CarryRemote, { Uid = uid })
    if ok and res == true then return true end
    ok, res = invoke(CarryRemote, uid)
    if ok and res == true then return true end
    ok, res = invoke(CarryRemote, uid, nil)
    if ok and res == true then return true end

    if model then
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                pcall(function() d.HoldDuration = 0 end)
                if firePP then pcall(firePP, d) end
            elseif d:IsA("ClickDetector") and fireCD then
                pcall(fireCD, d)
            elseif d:IsA("BasePart") and fireTI then
                local p = hrp()
                if p then
                    pcall(fireTI, d, p, 0); pcall(fireTI, d, p, true)
                    task.wait(0.04)
                    pcall(fireTI, d, p, 1); pcall(fireTI, d, p, false)
                end
            end
        end
    end
    for _ = 1, 5 do
        pressKey(Enum.KeyCode.E, 0.07)
        task.wait(0.05)
    end
    task.wait(0.2)
    return isCarrying()
end

local function dropHeld()
    if EggCmds then
        for _, fnName in ipairs({"RequestDropHeldAreaEgg", "DropFieldEgg"}) do
            if type(EggCmds[fnName]) == "function" then
                pcall(EggCmds[fnName], "PlayerRequest")
                pcall(EggCmds[fnName])
            end
        end
    end
    invoke(DropRemote, "PlayerRequest")
    invoke(DropRemote)
    pcall(function()
        for _, g in ipairs(pg:GetDescendants()) do
            if g:IsA("TextButton") or g:IsA("ImageButton") then
                local t = string.lower((g.Text or "") .. " " .. g.Name)
                if t == "drop" or string.find(t, "drop", 1, true)
                or string.find(t, "soltar", 1, true) then
                    clickGui(g)
                end
            end
        end
    end)
    pressKey(Enum.KeyCode.Backspace, 0.08)
    local human = hum()
    if human then pcall(function() human:UnequipTools() end) end
end

local function nearestEggAt(pos, maxDist, wantedName)
    maxDist = maxDist or 40
    local best, bestD
    for _, e in ipairs(scanEggs()) do
        local okName = (not wantedName) or wantedName == "MEJOR" or e.name == wantedName or e.uid == wantedName
        if okName then
            local d = (e.pos - pos).Magnitude
            if d <= maxDist and (not bestD or d < bestD) then
                best, bestD = e, d
            end
        end
    end
    return best
end

local function placeHeldOrInventory()
    if not CFG.autoPlace then return end
    local area = petArea()
    local plot = plotFolder()
    if not area then return end
    hopTo(area.Position + Vector3.new(0, 3, 0), 14, 0.25)

    local uid
    if Save and Save.Get then
        local ok, data = pcall(Save.Get)
        if ok and type(data) == "table" and type(data.EggInventory) == "table" then
            for id, rec in pairs(data.EggInventory) do
                local placed = type(rec) == "table" and rec.Placement
                if not placed then uid = tostring(id); break end
            end
        end
    end
    if not uid then return end

    if EggCmds then
        pcall(function()
            if EggCmds.RequestEquipTool then EggCmds.RequestEquipTool(uid) end
        end)
        task.wait(0.08)
        if type(EggCmds.RequestPlaceEgg) == "function" and plot then
            local world = CFrame.new(area.Position + Vector3.new(0, 1, 0))
            local localCf = plot:GetPivot():ToObjectSpace(world)
            pcall(EggCmds.RequestPlaceEgg, { Uid = uid, LocalCFrame = localCf })
            return
        end
    end
    if PlaceRemote and plot then
        local world = CFrame.new(area.Position + Vector3.new(0, 1, 0))
        local localCf = plot:GetPivot():ToObjectSpace(world)
        invoke(PlaceRemote, { Uid = uid, LocalCFrame = localCf })
    end
end

----------------------------------------------------------------
-- GUI
----------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "XenoFarmGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 430)
frame.Position = UDim2.new(0, 16, 0.5, -215)
frame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(70, 70, 90)
stroke.Thickness = 1

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -36, 0, 34)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "  STEAL AN EGG  ·  FARM"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

do
    local dragging, start, startPos
    title.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            start = i.Position
            startPos = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 24)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(255, 140, 140)
closeBtn.TextSize = 14
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function()
    CFG.farming = false
    _G.__SAEFarmGen = GEN + 1
    gui:Destroy()
end)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 34)
status.Position = UDim2.new(0, 10, 0, 38)
status.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
status.Font = Enum.Font.Gotham
status.Text = "Listo"
status.TextColor3 = Color3.fromRGB(180, 180, 200)
status.TextSize = 12
status.TextWrapped = true
status.Parent = frame
Instance.new("UICorner", status).CornerRadius = UDim.new(0, 6)

local function setStatus(text, color)
    status.Text = text
    status.TextColor3 = color or Color3.fromRGB(180, 180, 200)
end

local function mkBtn(text, y, color, h)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, h or 30)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = color
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 13
    b.AutoButtonColor = true
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local farmBtn  = mkBtn("FARM", 80, Color3.fromRGB(34, 170, 90), 34)
local preBtn   = mkBtn("Marcar Pre-Spawn  (antes de la linea)", 120, Color3.fromRGB(50, 50, 70))
local spawnBtn = mkBtn("Marcar Spawn / Base", 154, Color3.fromRGB(50, 50, 70))
local placeBtn = mkBtn("Auto Place: ON", 188, Color3.fromRGB(34, 90, 70), 24)
placeBtn.TextSize = 12

local selLabel = Instance.new("TextLabel")
selLabel.Size = UDim2.new(1, -20, 0, 16)
selLabel.Position = UDim2.new(0, 10, 0, 216)
selLabel.BackgroundTransparency = 1
selLabel.Font = Enum.Font.Gotham
selLabel.Text = "Objetivo: MEJOR"
selLabel.TextColor3 = Color3.fromRGB(160, 220, 180)
selLabel.TextSize = 12
selLabel.TextXAlignment = Enum.TextXAlignment.Left
selLabel.Parent = frame

local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -20, 0, 14)
listLabel.Position = UDim2.new(0, 10, 0, 232)
listLabel.BackgroundTransparency = 1
listLabel.Font = Enum.Font.Gotham
listLabel.Text = "Huevos en el mapa"
listLabel.TextColor3 = Color3.fromRGB(130, 130, 150)
listLabel.TextSize = 11
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 0, 140)
scroll.Position = UDim2.new(0, 10, 0, 248)
scroll.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = frame
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)
local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, 3)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
local pad = Instance.new("UIPadding", scroll)
pad.PaddingTop = UDim.new(0, 4)
pad.PaddingLeft = UDim.new(0, 4)
pad.PaddingRight = UDim.new(0, 4)

local refreshBtn = mkBtn("Escanear mapa", 396, Color3.fromRGB(50, 50, 70), 24)
refreshBtn.TextSize = 12

local function paintFarm()
    if CFG.farming then
        farmBtn.Text = "STOP"
        farmBtn.BackgroundColor3 = Color3.fromRGB(190, 50, 60)
    else
        farmBtn.Text = "FARM"
        farmBtn.BackgroundColor3 = Color3.fromRGB(34, 170, 90)
    end
end

local function rebuildList()
    for _, ch in ipairs(scroll:GetChildren()) do
        if ch:IsA("TextButton") then ch:Destroy() end
    end
    local found = scanEggs()
    local names = uniqueNames(found)
    for i, name in ipairs(names) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -8, 0, 24)
        b.BackgroundColor3 = (CFG.selected == name)
            and Color3.fromRGB(34, 90, 60) or Color3.fromRGB(36, 36, 48)
        b.Font = Enum.Font.Gotham
        b.Text = (name == "MEJOR") and "  MEJOR  (mayor rareza)" or ("  " .. name)
        b.TextColor3 = Color3.fromRGB(230, 230, 240)
        b.TextSize = 12
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.LayoutOrder = i
        b.Parent = scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(function()
            CFG.selected = name
            selLabel.Text = "Objetivo: " .. name
            rebuildList()
        end)
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(0, #names * 27 + 8))
    local top = found[1]
    if top then
        listLabel.Text = string.format("%d huevos  |  top: %s [%s]", #found, top.name, top.rarity)
    else
        listLabel.Text = "0 huevos (noche o reset?)"
    end
end

preBtn.MouseButton1Click:Connect(function()
    local p = hrp()
    if not p then return end
    CFG.preSpawn = p.CFrame
    preBtn.Text = "Pre-Spawn marcado"
    preBtn.BackgroundColor3 = Color3.fromRGB(34, 90, 70)
    setStatus("Pre-Spawn OK (antes de la linea)", Color3.fromRGB(140, 220, 160))
end)

spawnBtn.MouseButton1Click:Connect(function()
    local p = hrp()
    if not p then return end
    CFG.spawn = p.CFrame
    spawnBtn.Text = "Spawn marcado"
    spawnBtn.BackgroundColor3 = Color3.fromRGB(34, 90, 70)
    setStatus("Spawn / base OK", Color3.fromRGB(140, 220, 160))
end)

placeBtn.MouseButton1Click:Connect(function()
    CFG.autoPlace = not CFG.autoPlace
    placeBtn.Text = CFG.autoPlace and "Auto Place: ON" or "Auto Place: OFF"
    placeBtn.BackgroundColor3 = CFG.autoPlace and Color3.fromRGB(34, 90, 70) or Color3.fromRGB(50, 50, 70)
end)

refreshBtn.MouseButton1Click:Connect(function()
    rebuildList()
    setStatus("Mapa escaneado", Color3.fromRGB(180, 180, 220))
end)

task.spawn(function()
    if not CFG.spawn then
        CFG.spawn = autoSpawn()
        if CFG.spawn then
            spawnBtn.Text = "Spawn (auto base)"
            spawnBtn.BackgroundColor3 = Color3.fromRGB(40, 70, 90)
        end
    end
    if not CFG.preSpawn then
        CFG.preSpawn = autoPreSpawn()
        if CFG.preSpawn then
            preBtn.Text = "Pre-Spawn (auto linea)"
            preBtn.BackgroundColor3 = Color3.fromRGB(40, 70, 90)
        end
    end
    rebuildList()
end)

----------------------------------------------------------------
-- Loop FARM
----------------------------------------------------------------
local function farmOnce()
    if GEN ~= _G.__SAEFarmGen then return false end
    if not CFG.preSpawn then CFG.preSpawn = autoPreSpawn() end
    if not CFG.spawn    then CFG.spawn    = autoSpawn()    end
    if not CFG.preSpawn or not CFG.spawn then
        setStatus("Marca Pre-Spawn y Spawn", Color3.fromRGB(255, 180, 80))
        return false
    end
    if not hrp() then
        lp.CharacterAdded:Wait()
        task.wait(0.8)
        return true
    end
    if isNight() then
        setStatus("Noche / reset — esperando dia...", Color3.fromRGB(180, 160, 255))
        task.wait(1)
        return true
    end

    setStatus("Buscando " .. CFG.selected .. "...", Color3.fromRGB(180, 200, 255))
    local found = scanEggs()
    if #found == 0 then
        setStatus("Sin huevos, reintentando...", Color3.fromRGB(255, 200, 120))
        task.wait(0.9)
        return true
    end

    local target = found[1]
    setStatus(string.format("TP -> %s  [%s]  %s", target.name, target.rarity, target.area),
        Color3.fromRGB(180, 255, 180))
    local stole = stealEgg(target)
    task.wait(0.15)
    if not stole and not isCarrying() then
        setStatus("No se agarro, siguiente...", Color3.fromRGB(255, 160, 120))
        task.wait(0.4)
        return true
    end

    setStatus("TP a Pre-Spawn (antes de la linea)", Color3.fromRGB(180, 220, 255))
    hopTo(CFG.preSpawn, 16, 0.18)
    task.wait(0.12)

    setStatus("Soltando 2s...", Color3.fromRGB(255, 210, 140))
    dropHeld()
    task.wait(CFG.dropTime)

    setStatus("Re-agarrando...", Color3.fromRGB(180, 255, 200))
    local prePos = (typeof(CFG.preSpawn) == "CFrame") and CFG.preSpawn.Position or CFG.preSpawn
    local dropped = nearestEggAt(prePos, 45, target.uid)
                 or nearestEggAt(prePos, 45, target.name)
                 or nearestEggAt(prePos, 30, nil)
    if dropped then
        stealEgg(dropped)
    else
        for _ = 1, 6 do pressKey(Enum.KeyCode.E, 0.07); task.wait(0.05) end
    end
    task.wait(0.15)

    setStatus("TP al Spawn / base", Color3.fromRGB(160, 255, 180))
    hopTo(CFG.spawn, 16, 0.22)
    task.wait(0.35)

    placeHeldOrInventory()
    setStatus("Ciclo listo", Color3.fromRGB(160, 220, 180))
    return true
end

farmBtn.MouseButton1Click:Connect(function()
    CFG.farming = not CFG.farming
    paintFarm()
    if CFG.farming then
        setStatus("FARM ON", Color3.fromRGB(120, 255, 160))
        task.spawn(function()
            while CFG.farming and gui.Parent and GEN == _G.__SAEFarmGen do
                local ok, err = pcall(farmOnce)
                if not ok then
                    setStatus("Error: " .. tostring(err), Color3.fromRGB(255, 120, 120))
                    task.wait(1)
                end
                task.wait(0.12)
            end
            if gui.Parent then setStatus("FARM OFF", Color3.fromRGB(200, 200, 210)) end
        end)
    else
        setStatus("FARM OFF", Color3.fromRGB(200, 200, 210))
    end
end)

task.spawn(function()
    while gui.Parent and GEN == _G.__SAEFarmGen do
        if not CFG.farming then pcall(rebuildList) end
        task.wait(3)
    end
end)

paintFarm()
setStatus("Steal An Egg listo. Pulsa FARM.", Color3.fromRGB(180, 180, 200))
