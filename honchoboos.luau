local workspace = game:GetService("Workspace")

local HIGHLIGHT_COLOR = Color3.fromRGB(0, 255, 0)
local OUTLINE_COLOR = Color3.fromRGB(255, 255, 255)

local bossDefeated = false
local bossActive = false

local function isBossAlive()
    local players = game:GetService("Players")
    local player = players.LocalPlayer
    if not player then return false end

    local gui = player:FindFirstChild("PlayerGui")
    if gui then
        for _, obj in pairs(gui:GetDescendants()) do
            if obj.Name == "BossHealthBar" or obj.Name == "HonchoIndicator" then
                return true
            end
        end
    end

    local honcho = workspace:FindFirstChild("Honcho")
    if honcho and honcho:IsA("Model") then
        return true
    end

    return false
end

local function getTargetNumbersFromScreens()
    local targets = {}
    local rooms = workspace:FindFirstChild("CurrentRooms")
    if not rooms then return targets end

    for _, obj in pairs(rooms:GetDescendants()) do
        if obj.Name == "ArchivesPackageDeposit" then
            local label = obj:FindFirstChild("Screen")
                and obj.Screen:FindFirstChild("Text")
                and obj.Screen.Text:FindFirstChild("Label")
            if label and label:IsA("TextLabel") then
                local text = label.Text
                if text ~= "" and text ~= "---" and string.match(text, "^%u%-%d+$") then
                    table.insert(targets, text)
                end
            end
        end
    end
    return targets
end

local function clearAllHighlights()
    local rooms = workspace:FindFirstChild("CurrentRooms")
    if not rooms then return end
    
    for _, obj in pairs(rooms:GetDescendants()) do
        if obj.Name == "ArchivesStorageBox" then
            local existingHighlight = obj:FindFirstChild("DynamicGreenESP")
            if existingHighlight then
                existingHighlight:Destroy()
            end
        end
    end
end

local function doHonchoESP()
    local rooms = workspace:FindFirstChild("CurrentRooms")
    if not rooms then 
        clearAllHighlights()
        return 
    end

    local bossAlive = isBossAlive()
    
    if not bossAlive and bossActive then
        bossDefeated = true
        bossActive = false
        clearAllHighlights()
        print("Босс побеждён, подсветка отключена")
        return
    end

    if bossDefeated then
        return
    end

    if bossAlive then
        bossActive = true
    end

    local targetNumbers = getTargetNumbersFromScreens()
    
    if #targetNumbers == 0 then
        clearAllHighlights()
        return
    end

    for _, obj in pairs(rooms:GetDescendants()) do
        if obj.Name == "ArchivesStorageBox" and obj:IsA("Model") then
            local boxLabel = obj:FindFirstChild("Handle")
                and obj.Handle:FindFirstChild("Label")
                and obj.Handle.Label:FindFirstChild("Text")
                and obj.Handle.Label.Text:FindFirstChild("Label")

            if boxLabel and boxLabel:IsA("TextLabel") then
                local currentBoxNumber = boxLabel.Text
                local existingHighlight = obj:FindFirstChild("DynamicGreenESP")

                local shouldHighlight = false
                for _, target in pairs(targetNumbers) do
                    if currentBoxNumber == target then
                        shouldHighlight = true
                        break
                    end
                end

                if shouldHighlight then
                    if not existingHighlight then
                        local hl = Instance.new("Highlight")
                        hl.Name = "DynamicGreenESP"
                        hl.FillColor = HIGHLIGHT_COLOR
                        hl.FillTransparency = 0.3
                        hl.OutlineColor = OUTLINE_COLOR
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = obj
                    end
                else
                    if existingHighlight then
                        existingHighlight:Destroy()
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.2) do
        pcall(doHonchoESP)
    end
end)

print("Ready")
