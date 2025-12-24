-- GOON SNIPER - DEACTIVATION FIX (v2.0)
local LogoID = "rbxassetid://0" 
local Version = "v2.0"

-- [0] INITIALIZATION
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(2) 
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui", 10)
if not PlayerGui then PlayerGui = Player:WaitForChild("PlayerGui") end

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

-- [3] CONFIGURATION
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

-- [4] SNIPER FUNCTIONS
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
        local l_DataStream2_0 = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DataStream2")
        if getgenv().UpdateEvent then getgenv().UpdateEvent:Disconnect() end
        getgenv().UpdateEvent = l_DataStream2_0.OnClientEvent:Connect(function(f, Name, Data)
            if f=="UpdateData" and Name == "Booths" then end
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

-- [5] MAIN LOOP (FIXED)
local function MainLoop()
    local DataService 
    pcall(function() DataService = require(ReplicatedStorage.Modules.DataService) end)
    local MyTokens = 0
    if DataService then pcall(function() MyTokens = DataService:GetData().TradeData.Tokens end) end

    local Data = getgenv().boothData
    if not Data or not Data.Booths then return end 

    for BoothId, BoothData in pairs(Data.Booths) do
        -- [FIX] Stop scanning immediately if disabled
        if not getgenv().SniperEnabled then break end

        local Owner = BoothData.Owner
        if Owner and Data.Players[Owner] and Data.Players[Owner].Listings then
            local realPlayer = nil
            for _, Plr in pairs(Players:GetChildren()) do
                if Plr.UserId == tonumber(string.split(Owner, "_")[2]) then realPlayer = Plr break end
            end
            
            for ListingId, ListingData in pairs(Data.Players[Owner].Listings) do
                -- [FIX] Double check loop status before processing next item
                if not getgenv().SniperEnabled then break end

                if ListingData.ItemType == "Pet" then
                    local ItemData = Data.Players[Owner].Items[ListingData.ItemId]
                    if ItemData then
                        local Type = ItemData.PetType
                        local PetData = ItemData.PetData
                        local Price = ListingData.Price
                        local Weight = PetData.BaseWeight * 1.1
                        local MaxWeight = Weight * 10
                        
                        local Settings = getgenv().CurrentFilters[Type]
                        if Settings then
                            local MinW = Settings[1] or 0
                            local MaxP = Settings[2] or 9999999
                            
                            if not SeenListings[ListingId] then
                                print("🔎 FOUND:", Type, "| Price:", Price, "| Weight:", math.floor(MaxWeight).."kg")
                                SeenListings[ListingId] = true
                            end
                            
                            if MaxWeight >= MinW and Price <= MaxP and realPlayer ~= Player then
                                if Price <= MyTokens then
                                    -- [FIX] Final check before buying to prevent "late" buys
                                    if getgenv().SniperEnabled then
                                        local X,Y = ReplicatedStorage.GameEvents.TradeEvents.Booths.BuyListing:InvokeServer(realPlayer, ListingId)
                                        if X then
                                            Sniped(Type, MaxWeight, Price)
                                            task.wait(5)
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
end

-- [6] UI BUILDER
local function LoadSniperUI()
    if getgenv().GoonGUI then getgenv().GoonGUI:Destroy() end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GoonSniperUI"
    ScreenGui.Parent = PlayerGui
    getgenv().GoonGUI = ScreenGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
    MainFrame.Size = UDim2.new(0, 260, 0, 420)
    MainFrame.Active = true; MainFrame.Draggable = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.Text = "GOON SNIPER"
    Title.TextColor3 = Color3.fromRGB(50, 255, 100)
    Title.Size = UDim2.new(1, -70, 0, 25)
    Title.Position = UDim2.new(0, 15, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBlack
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextSize = 18

    local VerLabel = Instance.new("TextLabel")
    VerLabel.Parent = MainFrame
    VerLabel.Text = Version
    VerLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    VerLabel.Size = UDim2.new(0, 40, 0, 25)
    VerLabel.Position = UDim2.new(1, -75, 0, 10)
    VerLabel.BackgroundTransparency = 1
    VerLabel.Font = Enum.Font.GothamBold
    VerLabel.TextSize = 12
    VerLabel.TextXAlignment = Enum.TextXAlignment.Right

    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = MainFrame
    MinBtn.Text = "-"
    MinBtn.BackgroundTransparency = 1
    MinBtn.Position = UDim2.new(1, -30, 0, 10)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinBtn.TextSize = 20
    local Minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then MainFrame:TweenSize(UDim2.new(0, 260, 0, 50), "Out", "Quad", 0.3, true); MinBtn.Text = "+"
        else MainFrame:TweenSize(UDim2.new(0, 260, 0, 420), "Out", "Quad", 0.3, true); MinBtn.Text = "-" end
    end)

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
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) 
    DropdownFrame.Visible = false
    DropdownFrame.ZIndex = 10 
    DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, #PetList * 30)
    DropdownFrame.ScrollBarThickness = 6
    Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0,6)
    
    local ListLayout = Instance.new("UIListLayout"); 
    ListLayout.Parent = DropdownFrame
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

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

    local TargetList = Instance.new("ScrollingFrame")
    TargetList.Parent = MainFrame
    TargetList.Size = UDim2.new(1, -30, 0, 100)
    TargetList.Position = UDim2.new(0, 15, 0, 190)
    TargetList.BackgroundColor3 = Color3.fromRGB(20,20,20)
    TargetList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TargetList.ScrollBarThickness = 6
    Instance.new("UICorner", TargetList).CornerRadius = UDim.new(0,4)
    
    local TargetLayout = Instance.new("UIListLayout"); 
    TargetLayout.Parent = TargetList
    TargetLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TargetLayout.Padding = UDim.new(0, 2)

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

    -- Logic
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
        local b = Instance.new("TextButton"); 
        b.Parent = DropdownFrame; 
        b.Size = UDim2.new(1,0,0,30); 
        b.Text = p; 
        b.BackgroundColor3 = Color3.fromRGB(25,25,25); 
        b.TextColor3 = Color3.fromRGB(255,255,255) 
        b.Font = Enum.Font.Gotham
        b.ZIndex = 11 
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

    RefreshList()
    if getgenv().SniperEnabled then 
        ToggleBtn.Text = "DEACTIVATE"; ToggleBtn.TextColor3 = Color3.fromRGB(255,50,50); Stroke.Color = Color3.fromRGB(255,50,50); StatusLbl.Text = "STATUS: AUTO-RESUMED"
    end
    
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

-- [7] START (NO AUTH)
LoadData()
LoadConfig()
LoadSniperUI()
