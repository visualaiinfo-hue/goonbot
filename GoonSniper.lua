-- GOON SNIPER - MASTER DEV VERSION (Live Key Check Fix)
local LogoID = "rbxassetid://0" 

-- [1] CONFIGURATION: YOUR GITHUB LINK
-- I removed the specific commit hash so this always points to the LATEST version on GitHub
local KeyURL = "https://gist.githubusercontent.com/visualaiinfo-hue/5a1b8a1d32a3e9360a7d3d26cd75123e/raw/gistfile1.txt" 

-- [0] INITIALIZATION & SAFETY
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(2) -- Allow executor to stabilize
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Player = Players.LocalPlayer

-- Safe GUI Load
local PlayerGui = Player:WaitForChild("PlayerGui", 10)
if not PlayerGui then PlayerGui = Player:WaitForChild("PlayerGui") end

local KeyFile = "goon_auth_dev.txt"
local ConfigFile = "goon_config_dev.json"
local TradeWorldID = 129954712878723 

-- [1] PET DATABASE
local PetList = {
    "Koi", "Mimic Octopus", "Peacock", "Raccoon", "Kitsune", "Rainbow Dilophosaurus",
    "French Fry Ferret", "Pancake Mole", "Sushi Bear", "Spaghetti Sloth", "Bagel Bunny",
    "Frog", "Mole", "Echo Frog", "Shiba Inu", "Nihonzaru", "Tanuki", "Tanchozuru", "Kappa",
    "Ostrich", "Capybara", "Scarlet Macaw", "Wasp", "Tarantula Hawk", "Moth", "Butterfly",
    "Disco Bee", "Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"
}
table.sort(PetList)

-- [2] GLOBAL VARIABLES
getgenv().SniperEnabled = false
getgenv().CurrentFilters = {}
getgenv().LastFound = tick()
local SeenListings = {}

-- [3] CONFIGURATION HANDLERS
local function SaveConfig()
    if writefile then
        local data = { Enabled = getgenv().SniperEnabled, Filters = getgenv().CurrentFilters }
        writefile(ConfigFile, HttpService:JSONEncode(data))
    end
end

local function LoadConfig()
    if isfile and isfile(ConfigFile) then
        pcall(function()
            local result = HttpService:JSONDecode(readfile(ConfigFile))
            getgenv().SniperEnabled = result.Enabled
            getgenv().CurrentFilters = result.Filters or {}
        end)
    end
end

-- [4] UPDATED KEY SYSTEM LOGIC (Cache Buster Fix)
local function CheckKey(inputKey)
    -- Clean the input
    inputKey = inputKey:gsub("%s+", "") -- Remove spaces
    if inputKey == "" then return false end
    
    -- Cache Buster: Adds a random number to the URL so it ignores old saved versions
    local RefreshURL = KeyURL .. "?t=" .. tostring(math.floor(tick()))
    
    local success, response = pcall(function()
        return game:HttpGet(RefreshURL)
    end)
    
    if success then
        -- Optional: Print response to console for debugging (remove in final)
        print("DEBUG: GitHub Response ->", response) 
        
        -- Check if the key is inside the file
        if string.find(response, inputKey) then
            return true
        else
            warn("⚠️ Key not found in online list.")
            return false
        end
    else
        warn("⚠️ Failed to connect to GitHub: " .. tostring(response))
        return false
    end
end

-- [5] SNIPER FUNCTIONS
local function GCScan()
    if not getgc then return nil end
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" then
            if rawget(v, "Booths") and rawget(v, "Players") and rawget(v, "Active") == nil then
                if type(v.Booths) == "table" and type(v.Players) == "table" then return v end
            end
        end
    end
    return nil
end

local function LoadData()
    local liveData = GCScan()
    if liveData then
        getgenv().boothData = liveData
    else
        getgenv().boothData = {Booths = {}, Players = {}}
        -- Passive Hook (Fallback)
        local l_DataStream2_0 = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DataStream2")
        if getgenv().UpdateEvent then getgenv().UpdateEvent:Disconnect() end
        getgenv().UpdateEvent = l_DataStream2_0.OnClientEvent:Connect(function(f, Name, Data)
            if f=="UpdateData" and Name == "Booths" then 
                -- Logic to update passive table
            end
        end)
    end
end

local function Sniped(PetName, Weight, Price)
    local function FormatPrice(n)
        return tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    end
    local Embed_Data = {
        description="\n🕙 **Sniped At**: <t:"..math.floor(tick())..":R>\n-# account: ||"..Player.Name.."||",
        color=65280, 
        author={name=`GOON SNIPER: Got {PetName}({math.floor(Weight*100)/100}kg) for {FormatPrice(Price)}`}
    }
    local newData = HttpService:JSONEncode({embeds={Embed_Data}})
    local request = http_request or request or HttpPost or syn.request
    request({Url = "https://discord.com/api/webhooks/1453157686467367085/YwXMx09qDmAEnKYk_7KhtvAYWLPYWLc2fynfiGwPxyUoCcIBUwDUZkk9M3_PJ4DBim0w", Body = newData, Method = "POST", Headers = {["content-type"] = "application/json"}})
end

local function Hop()
    local success, err = pcall(function()
        local Api = "https://games.roblox.com/v1/games/"..TradeWorldID.."/servers/Public?sortOrder=Desc&limit=100"
        local Raw = game:HttpGet(Api)
        local Servers = HttpService:JSONDecode(Raw).data
        for i = #Servers, 2, -1 do local j = math.random(i); Servers[i], Servers[j] = Servers[j], Servers[i] end
        for _, v in pairs(Servers) do
            if v.playing and (v.maxPlayers - v.playing) >= 2 and v.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(TradeWorldID, v.id, Player)
                task.wait(5)
                return
            end
        end
    end)
    if not success then TeleportService:Teleport(TradeWorldID, Player) end
end

-- [6] MAIN LOOP LOGIC
local function MainLoop()
    local DataService 
    pcall(function() DataService = require(ReplicatedStorage.Modules.DataService) end)
    local MyTokens = 0
    if DataService then pcall(function() MyTokens = DataService:GetData().TradeData.Tokens end) end

    local Data = getgenv().boothData
    if not Data or not Data.Booths then return end 

    for BoothId, BoothData in pairs(Data.Booths) do
        local Owner = BoothData.Owner
        if Owner and Data.Players[Owner] and Data.Players[Owner].Listings then
            local realPlayer = nil
            for _, Plr in pairs(Players:GetChildren()) do
                if Plr.UserId == tonumber(string.split(Owner, "_")[2]) then realPlayer = Plr break end
            end
            
            for ListingId, ListingData in pairs(Data.Players[Owner].Listings) do
                if ListingData.ItemType == "Pet" then
                    local ItemData = Data.Players[Owner].Items[ListingData.ItemId]
                    if ItemData then
                        local Type = ItemData.PetType
                        local PetData = ItemData.PetData
                        local Price = ListingData.Price
                        local Weight = PetData.BaseWeight * 1.1
                        local MaxWeight = Weight * 10
                        
                        -- CHECK FILTER
                        local Settings = getgenv().CurrentFilters[Type]
                        if Settings then
                            local MinW = Settings[1] or 0
                            local MaxP = Settings[2] or 9999999
                            
                            if not SeenListings[ListingId] then
                                print("🔎 FOUND:", Type, "| Price:", Price)
                                SeenListings[ListingId] = true
                            end
                            
                            if MaxWeight >= MinW and Price <= MaxP and realPlayer ~= Player then
                                if Price <= MyTokens then
                                    local X,Y = ReplicatedStorage.GameEvents.TradeEvents.Booths.BuyListing:InvokeServer(realPlayer, ListingId)
                                    if X then
                                        Sniped(Type, MaxWeight, Price)
                                        task.wait(5) -- 5s Delay
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- [7] UI BUILDER
local function LoadSniperUI()
    if getgenv().GoonGUI then getgenv().GoonGUI:Destroy() end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GoonSniperUI"
    ScreenGui.Parent = PlayerGui
    getgenv().GoonGUI = ScreenGui

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
    MainFrame.Size = UDim2.new(0, 260, 0, 420)
    MainFrame.Active = true; MainFrame.Draggable = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    -- Header
    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.Text = "GOON SNIPER DEV"
    Title.TextColor3 = Color3.fromRGB(50, 255, 100)
    Title.Size = UDim2.new(1, -50, 0, 25)
    Title.Position = UDim2.new(0, 15, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBlack
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextSize = 18

    -- Status
    local StatusLbl = Instance.new("TextLabel")
    StatusLbl.Parent = MainFrame
    StatusLbl.Text = "STATUS: IDLE"
    StatusLbl.TextColor3 = Color3.fromRGB(150,150,150)
    StatusLbl.Size = UDim2.new(1, -30, 0, 20)
    StatusLbl.Position = UDim2.new(0, 15, 0, 35)
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.Font = Enum.Font.Code
    StatusLbl.TextSize = 12
    StatusLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Dropdown
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Parent = MainFrame
    DropdownBtn.Text = "Select Pet >"
    DropdownBtn.Size = UDim2.new(1, -30, 0, 30)
    DropdownBtn.Position = UDim2.new(0, 15, 0, 65)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    DropdownBtn.TextColor3 = Color3.fromRGB(200,200,200)
    DropdownBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0,6)

    local DropdownFrame = Instance.new("ScrollingFrame")
    DropdownFrame.Parent = MainFrame
    DropdownFrame.Size = UDim2.new(1, -30, 0, 150)
    DropdownFrame.Position = UDim2.new(0, 15, 0, 100)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    DropdownFrame.Visible = false
    DropdownFrame.ZIndex = 5
    Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0,6)
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Parent = DropdownFrame

    -- Inputs
    local WeightBox = Instance.new("TextBox")
    WeightBox.Parent = MainFrame
    WeightBox.PlaceholderText = "Min Weight"
    WeightBox.Size = UDim2.new(0.45, 0, 0, 30)
    WeightBox.Position = UDim2.new(0, 15, 0, 105)
    WeightBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
    WeightBox.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", WeightBox).CornerRadius = UDim.new(0,6)

    local PriceBox = Instance.new("TextBox")
    PriceBox.Parent = MainFrame
    PriceBox.PlaceholderText = "Max Price"
    PriceBox.Size = UDim2.new(0.45, 0, 0, 30)
    PriceBox.Position = UDim2.new(0.55, -5, 0, 105)
    PriceBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
    PriceBox.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", PriceBox).CornerRadius = UDim.new(0,6)

    local AddBtn = Instance.new("TextButton")
    AddBtn.Parent = MainFrame
    AddBtn.Text = "ADD TARGET"
    AddBtn.Size = UDim2.new(1, -30, 0, 30)
    AddBtn.Position = UDim2.new(0, 15, 0, 145)
    AddBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    AddBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", AddBtn).CornerRadius = UDim.new(0,6)

    -- List
    local TargetList = Instance.new("ScrollingFrame")
    TargetList.Parent = MainFrame
    TargetList.Size = UDim2.new(1, -30, 0, 100)
    TargetList.Position = UDim2.new(0, 15, 0, 190)
    TargetList.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Instance.new("UICorner", TargetList).CornerRadius = UDim.new(0,4)
    local TargetLayout = Instance.new("UIListLayout")
    TargetLayout.Parent = TargetList

    -- Controls
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = MainFrame
    ToggleBtn.Text = "ACTIVATE SNIPER"
    ToggleBtn.Size = UDim2.new(1, -30, 0, 40)
    ToggleBtn.Position = UDim2.new(0, 15, 0, 305)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    ToggleBtn.TextColor3 = Color3.fromRGB(50,255,100)
    ToggleBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0,6)
    local Stroke = Instance.new("UIStroke"); Stroke.Parent = ToggleBtn; Stroke.Color = Color3.fromRGB(50,255,100); Stroke.Thickness = 1; Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local HopBtn = Instance.new("TextButton")
    HopBtn.Parent = MainFrame
    HopBtn.Text = "FORCE HOP"
    HopBtn.Size = UDim2.new(1, -30, 0, 25)
    HopBtn.Position = UDim2.new(0, 15, 0, 355)
    HopBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    HopBtn.TextColor3 = Color3.fromRGB(255,255,255)
    HopBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", HopBtn).CornerRadius = UDim.new(0,6)

    -- UI Logic
    local SelectedPet = nil
    
    local function RefreshList()
        for _,v in pairs(TargetList:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
        for pet, cfg in pairs(getgenv().CurrentFilters) do
            local Row = Instance.new("Frame"); Row.Parent = TargetList; Row.Size = UDim2.new(1,0,0,25); Row.BackgroundTransparency = 1
            local Lbl = Instance.new("TextLabel"); Lbl.Parent = Row; Lbl.Text = pet.." ("..cfg[1].."kg / $"..cfg[2]..")"; Lbl.Size = UDim2.new(0.8,0,1,0); Lbl.TextColor3 = Color3.fromRGB(200,200,200); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 11; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Position = UDim2.new(0,5,0,0)
            local Del = Instance.new("TextButton"); Del.Parent = Row; Del.Text = "X"; Del.Size = UDim2.new(0.2,0,1,0); Del.Position = UDim2.new(0.8,0,0,0); Del.TextColor3 = Color3.fromRGB(255,50,50); Del.BackgroundTransparency = 1; Del.Font = Enum.Font.GothamBold
            Del.MouseButton1Click:Connect(function() getgenv().CurrentFilters[pet] = nil; RefreshList(); SaveConfig() end)
        end
    end

    for _,p in ipairs(PetList) do
        local b = Instance.new("TextButton"); b.Parent = DropdownFrame; b.Size = UDim2.new(1,0,0,30); b.Text = p; b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.TextColor3 = Color3.fromRGB(200,200,200)
        b.MouseButton1Click:Connect(function() SelectedPet = p; DropdownBtn.Text = p; DropdownFrame.Visible = false end)
    end

    DropdownBtn.MouseButton1Click:Connect(function() DropdownFrame.Visible = not DropdownFrame.Visible end)
    AddBtn.MouseButton1Click:Connect(function() 
        if SelectedPet and tonumber(WeightBox.Text) and tonumber(PriceBox.Text) then
            getgenv().CurrentFilters[SelectedPet] = {tonumber(WeightBox.Text), tonumber(PriceBox.Text)}
            RefreshList(); SaveConfig()
        end
    end)

    ToggleBtn.MouseButton1Click:Connect(function()
        getgenv().SniperEnabled = not getgenv().SniperEnabled
        SaveConfig()
        if getgenv().SniperEnabled then
            ToggleBtn.Text = "DEACTIVATE"; ToggleBtn.TextColor3 = Color3.fromRGB(255,50,50); Stroke.Color = Color3.fromRGB(255,50,50); StatusLbl.Text = "STATUS: ACTIVE"
        else
            ToggleBtn.Text = "ACTIVATE SNIPER"; ToggleBtn.TextColor3 = Color3.fromRGB(50,255,100); Stroke.Color = Color3.fromRGB(50,255,100); StatusLbl.Text = "STATUS: IDLE"
        end
    end)
    HopBtn.MouseButton1Click:Connect(Hop)

    -- Init
    RefreshList()
    if getgenv().SniperEnabled then 
        ToggleBtn.Text = "DEACTIVATE"; ToggleBtn.TextColor3 = Color3.fromRGB(255,50,50); Stroke.Color = Color3.fromRGB(255,50,50); StatusLbl.Text = "STATUS: AUTO-RESUMED"
    end
    
    -- Status Loop
    task.spawn(function()
        while true do
            task.wait()
            if getgenv().SniperEnabled then
                if game.PlaceId ~= TradeWorldID then
                    StatusLbl.Text = "WRONG WORLD! HOPPING..."
                    TeleportService:Teleport(TradeWorldID, Player)
                    task.wait(10)
                else
                    pcall(MainLoop)
                    if tick() - getgenv().LastFound > 60 then
                        StatusLbl.Text = "SERVER DRY - HOPPING..."
                        Hop()
                        getgenv().LastFound = tick() + 60
                    end
                end
            end
        end
    end)
end

-- [8] AUTHENTICATION
local function AuthFlow()
    if getgenv().KeyGUI then getgenv().KeyGUI:Destroy() end
    if isfile(KeyFile) and CheckKey(readfile(KeyFile)) then
        LoadData()
        LoadConfig()
        LoadSniperUI()
        return
    end

    local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "GoonAuth"; ScreenGui.Parent = PlayerGui; getgenv().KeyGUI = ScreenGui
    local Frame = Instance.new("Frame"); Frame.Parent = ScreenGui; Frame.Size = UDim2.new(0,300,0,150); Frame.Position = UDim2.new(0.5,-150,0.4,-75); Frame.BackgroundColor3 = Color3.fromRGB(15,15,15); Frame.Active = true; Frame.Draggable = true
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,8)
    
    local KeyBox = Instance.new("TextBox"); KeyBox.Parent = Frame; KeyBox.Size = UDim2.new(0.8,0,0,40); KeyBox.Position = UDim2.new(0.1,0,0.3,0); KeyBox.PlaceholderText = "Enter Key"; KeyBox.BackgroundColor3 = Color3.fromRGB(30,30,30); KeyBox.TextColor3 = Color3.fromRGB(255,255,255)
    local Submit = Instance.new("TextButton"); Submit.Parent = Frame; Submit.Size = UDim2.new(0.8,0,0,40); Submit.Position = UDim2.new(0.1,0,0.65,0); Submit.Text = "LOGIN"; Submit.BackgroundColor3 = Color3.fromRGB(46,204,113)
    
    Submit.MouseButton1Click:Connect(function()
        if CheckKey(KeyBox.Text) then
            writefile(KeyFile, KeyBox.Text)
            LoadData()
            LoadConfig()
            LoadSniperUI()
        else
            Submit.Text = "INVALID"; task.wait(1); Submit.Text = "LOGIN"
        end
    end)
end

-- [9] START
AuthFlow()
