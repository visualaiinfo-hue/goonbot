-- GOON SNIPER - GITHUB KEY SYSTEM (Final Version)
local LogoID = "rbxassetid://0" -- REPLACE 0 WITH YOUR IMAGE ID

-- [1] CONFIGURATION: YOUR GITHUB LINK
-- PASTE THE "RAW" GIST LINK YOU COPIED IN STEP 2 HERE:
local KeyURL = "https://gist.githubusercontent.com/EXAMPLE/RAW/KEYS.TXT" 

-- [2] KEY SYSTEM LOGIC
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local KeyFile = "goon_sniper_key.txt"

-- Hard Load Safety
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(5) -- Wait for Volt/Delta to initialize
local PlayerGui = Player:WaitForChild("PlayerGui", 10)
if not PlayerGui then PlayerGui = Player:WaitForChild("PlayerGui") end

-- Function to check key against online list
local function CheckKey(inputKey)
    -- Remove extra spaces
    inputKey = inputKey:gsub("%s+", "")
    if inputKey == "" then return false end
    
    local success, response = pcall(function()
        -- Using game:HttpGet is standard for executors to read websites
        return game:HttpGet(KeyURL)
    end)
    
    if success then
        -- We check if the response (your file) contains the input key
        if string.find(response, inputKey) then
            return true
        else
            return false
        end
    else
        warn("⚠️ Failed to connect to Key Server. Check your Internet or URL.")
        return false
    end
end

-- Function to Run the Main Sniper (The Payload)
local function LoadSniper()
    if getgenv().KeyGUI then getgenv().KeyGUI:Destroy() end
    
    -- ==============================================================
    --                START OF SNIPER SCRIPT
    -- ==============================================================
    
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TeleportService = game:GetService("TeleportService")
    local TradeWorldID = 129954712878723 

    -- PET DATABASE
    local PetList = {
        "Koi", "Mimic Octopus", "Peacock", "Raccoon", "Kitsune", "Rainbow Dilophosaurus",
        "French Fry Ferret", "Pancake Mole", "Sushi Bear", "Spaghetti Sloth", "Bagel Bunny",
        "Frog", "Mole", "Echo Frog", "Shiba Inu", "Nihonzaru", "Tanuki", "Tanchozuru", "Kappa",
        "Ostrich", "Capybara", "Scarlet Macaw", "Wasp", "Tarantula Hawk", "Moth", "Butterfly",
        "Disco Bee", "Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"
    }
    table.sort(PetList) 

    -- CONFIGURATION SYSTEM
    local ConfigFile = "goon_sniper_v3.json"
    getgenv().CurrentFilters = {} 

    local function SaveConfig()
        if writefile then
            local data = {
                Enabled = getgenv().SniperEnabled,
                Filters = getgenv().CurrentFilters
            }
            writefile(ConfigFile, HttpService:JSONEncode(data))
        end
    end

    local function LoadConfig()
        if isfile and isfile(ConfigFile) then
            local success, result = pcall(function()
                return HttpService:JSONDecode(readfile(ConfigFile))
            end)
            if success and result then
                getgenv().SniperEnabled = result.Enabled
                getgenv().CurrentFilters = result.Filters or {}
                return true
            end
        end
        return false
    end

    -- GUI CREATION
    if getgenv().GoonGUI then getgenv().GoonGUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GoonSniperUI"
    ScreenGui.Parent = PlayerGui
    getgenv().GoonGUI = ScreenGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
    MainFrame.Size = UDim2.new(0, 260, 0, 400) 
    MainFrame.Active = true
    MainFrame.Draggable = true 

    local function AddCorner(inst, rad)
        local ui = Instance.new("UICorner")
        ui.CornerRadius = UDim.new(0, rad)
        ui.Parent = inst
    end
    AddCorner(MainFrame, 8)

    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 10) 
    Title.Size = UDim2.new(1, -50, 0, 25)
    Title.Font = Enum.Font.GothamBlack
    Title.Text = "GOON SNIPER"
    Title.TextColor3 = Color3.fromRGB(50, 255, 100) 
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = MainFrame
    MinBtn.BackgroundTransparency = 1
    MinBtn.Position = UDim2.new(1, -30, 0, 10)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinBtn.TextSize = 20

    local Minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            MainFrame:TweenSize(UDim2.new(0, 260, 0, 50), "Out", "Quad", 0.3, true)
            MinBtn.Text = "+"
        else
            MainFrame:TweenSize(UDim2.new(0, 260, 0, 400), "Out", "Quad", 0.3, true)
            MinBtn.Text = "-"
        end
    end)

    local StatusLbl = Instance.new("TextLabel")
    StatusLbl.Parent = MainFrame
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.Position = UDim2.new(0, 15, 0, 40)
    StatusLbl.Size = UDim2.new(1, -30, 0, 20)
    StatusLbl.Font = Enum.Font.Code 
    StatusLbl.Text = "STATUS: IDLE"
    StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatusLbl.TextSize = 12
    StatusLbl.TextXAlignment = Enum.TextXAlignment.Left

    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Parent = MainFrame
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropdownBtn.Position = UDim2.new(0, 15, 0, 70)
    DropdownBtn.Size = UDim2.new(1, -30, 0, 35)
    DropdownBtn.Font = Enum.Font.GothamBold
    DropdownBtn.Text = "Select Pet >"
    DropdownBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    DropdownBtn.TextSize = 14
    DropdownBtn.AutoButtonColor = false
    AddCorner(DropdownBtn, 6)

    local DropdownFrame = Instance.new("ScrollingFrame")
    DropdownFrame.Name = "Dropdown"
    DropdownFrame.Parent = MainFrame
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    DropdownFrame.Position = UDim2.new(0, 15, 0, 108)
    DropdownFrame.Size = UDim2.new(1, -30, 0, 150)
    DropdownFrame.Visible = false
    DropdownFrame.ZIndex = 10
    DropdownFrame.ScrollBarThickness = 4
    AddCorner(DropdownFrame, 6)

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = DropdownFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local WeightBox = Instance.new("TextBox")
    WeightBox.Parent = MainFrame
    WeightBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    WeightBox.Position = UDim2.new(0, 15, 0, 115)
    WeightBox.Size = UDim2.new(0.45, 0, 0, 35)
    WeightBox.Font = Enum.Font.Gotham
    WeightBox.PlaceholderText = "Min Weight"
    WeightBox.Text = ""
    WeightBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    WeightBox.TextSize = 13
    AddCorner(WeightBox, 6)

    local PriceBox = Instance.new("TextBox")
    PriceBox.Parent = MainFrame
    PriceBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    PriceBox.Position = UDim2.new(0.55, -5, 0, 115) 
    PriceBox.Size = UDim2.new(0.45, 0, 0, 35)
    PriceBox.Font = Enum.Font.Gotham
    PriceBox.PlaceholderText = "Max Price"
    PriceBox.Text = ""
    PriceBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    PriceBox.TextSize = 13
    AddCorner(PriceBox, 6)

    local AddBtn = Instance.new("TextButton")
    AddBtn.Parent = MainFrame
    AddBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113) 
    AddBtn.Position = UDim2.new(0, 15, 0, 160)
    AddBtn.Size = UDim2.new(1, -30, 0, 30)
    AddBtn.Font = Enum.Font.GothamBold
    AddBtn.Text = "ADD TO LIST"
    AddBtn.TextColor3 = Color3.fromRGB(25, 25, 25)
    AddBtn.TextSize = 13
    AddCorner(AddBtn, 6)

    local ListLabel = Instance.new("TextLabel")
    ListLabel.Parent = MainFrame
    ListLabel.BackgroundTransparency = 1
    ListLabel.Position = UDim2.new(0, 15, 0, 200)
    ListLabel.Size = UDim2.new(1, -30, 0, 20)
    ListLabel.Font = Enum.Font.GothamBold
    ListLabel.Text = "ACTIVE TARGETS:"
    ListLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    ListLabel.TextSize = 12
    ListLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TargetList = Instance.new("ScrollingFrame")
    TargetList.Name = "TargetList"
    TargetList.Parent = MainFrame
    TargetList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TargetList.Position = UDim2.new(0, 15, 0, 220)
    TargetList.Size = UDim2.new(1, -30, 0, 80)
    TargetList.ScrollBarThickness = 3
    AddCorner(TargetList, 4)

    local TargetLayout = Instance.new("UIListLayout")
    TargetLayout.Parent = TargetList
    TargetLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TargetLayout.Padding = UDim.new(0, 2)

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = MainFrame
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) 
    ToggleBtn.Position = UDim2.new(0, 15, 0, 310)
    ToggleBtn.Size = UDim2.new(1, -30, 0, 40)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = "ACTIVATE SNIPER"
    ToggleBtn.TextColor3 = Color3.fromRGB(50, 255, 100) 
    ToggleBtn.TextSize = 14
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = ToggleBtn
    Stroke.Color = Color3.fromRGB(50, 255, 100)
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    AddCorner(ToggleBtn, 6)

    local HopBtn = Instance.new("TextButton")
    HopBtn.Parent = MainFrame
    HopBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    HopBtn.Position = UDim2.new(0, 15, 0, 360)
    HopBtn.Size = UDim2.new(1, -30, 0, 25)
    HopBtn.Font = Enum.Font.GothamBold
    HopBtn.Text = "FORCE HOP"
    HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    HopBtn.TextSize = 11
    AddCorner(HopBtn, 6)

    -- LOGIC
    local SelectedPet = nil
    local function UpdateListVisuals()
        for _, child in pairs(TargetList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        for pet, settings in pairs(getgenv().CurrentFilters) do
            local Row = Instance.new("Frame")
            Row.Parent = TargetList
            Row.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Row.Size = UDim2.new(1, 0, 0, 25)
            Row.BorderSizePixel = 0
            
            local PName = Instance.new("TextLabel")
            PName.Parent = Row
            PName.BackgroundTransparency = 1
            PName.Position = UDim2.new(0, 5, 0, 0)
            PName.Size = UDim2.new(0.6, 0, 1, 0)
            PName.Font = Enum.Font.Gotham
            PName.Text = pet .. " (" .. settings[1] .. "kg)"
            PName.TextColor3 = Color3.fromRGB(200, 200, 200)
            PName.TextSize = 11
            PName.TextXAlignment = Enum.TextXAlignment.Left
            
            local PPrice = Instance.new("TextLabel")
            PPrice.Parent = Row
            PPrice.BackgroundTransparency = 1
            PPrice.Position = UDim2.new(0.6, 0, 0, 0)
            PPrice.Size = UDim2.new(0.3, 0, 1, 0)
            PPrice.Font = Enum.Font.GothamBold
            PPrice.Text = "$" .. settings[2]
            PPrice.TextColor3 = Color3.fromRGB(46, 204, 113)
            PPrice.TextSize = 11
            PPrice.TextXAlignment = Enum.TextXAlignment.Right
            
            local DelBtn = Instance.new("TextButton")
            DelBtn.Parent = Row
            DelBtn.BackgroundTransparency = 1
            DelBtn.Position = UDim2.new(0.9, 0, 0, 0)
            DelBtn.Size = UDim2.new(0.1, 0, 1, 0)
            DelBtn.Text = "X"
            DelBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
            DelBtn.Font = Enum.Font.GothamBold
            DelBtn.TextSize = 12
            
            DelBtn.MouseButton1Click:Connect(function()
                getgenv().CurrentFilters[pet] = nil
                UpdateListVisuals() 
                SaveConfig()
            end)
        end
    end

    for _, petName in ipairs(PetList) do
        local btn = Instance.new("TextButton")
        btn.Parent = DropdownFrame
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Text = petName
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        btn.MouseButton1Click:Connect(function()
            SelectedPet = petName
            DropdownBtn.Text = petName
            DropdownFrame.Visible = false
        end)
    end

    DropdownBtn.MouseButton1Click:Connect(function()
        DropdownFrame.Visible = not DropdownFrame.Visible
    end)

    AddBtn.MouseButton1Click:Connect(function()
        if SelectedPet and tonumber(WeightBox.Text) and tonumber(PriceBox.Text) then
            getgenv().CurrentFilters[SelectedPet] = {
                tonumber(WeightBox.Text), 
                tonumber(PriceBox.Text)
            }
            UpdateListVisuals() 
            SaveConfig() 
        else
            AddBtn.Text = "INVALID INPUT"
            task.wait(1)
            AddBtn.Text = "ADD TO LIST"
        end
    end)

    LoadConfig() 
    UpdateListVisuals() 
    getgenv().LastFound = tick()
    local SeenListings = {} 

    if getgenv().SniperEnabled then
        ToggleBtn.Text = "DEACTIVATE"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 50, 50) 
        Stroke.Color = Color3.fromRGB(255, 50, 50)
        StatusLbl.Text = "STATUS: AUTO-RESUMED..."
    end

    local DataService
    pcall(function()
        DataService = require(ReplicatedStorage.Modules.DataService)
    end)

    local function Hop()
        StatusLbl.Text = "STATUS: FINDING SERVER..."
        local success, err = pcall(function()
            local Api = "https://games.roblox.com/v1/games/"..TradeWorldID.."/servers/Public?sortOrder=Desc&limit=100"
            local Raw = game:HttpGet(Api)
            local Servers = HttpService:JSONDecode(Raw).data
            for i = #Servers, 2, -1 do
                local j = math.random(i)
                Servers[i], Servers[j] = Servers[j], Servers[i]
            end
            for _, v in pairs(Servers) do
                if v.playing and (v.maxPlayers - v.playing) >= 2 and v.id ~= game.JobId then
                    StatusLbl.Text = "STATUS: JOINING SERVER..."
                    TeleportService:TeleportToPlaceInstance(TradeWorldID, v.id, Player)
                    task.wait(5)
                    return
                end
            end
        end)
        if not success then
            StatusLbl.Text = "STATUS: RETRYING HOP..."
            task.wait(2)
            TeleportService:Teleport(TradeWorldID, Player)
        end
    end
    HopBtn.MouseButton1Click:Connect(Hop)

    local function GCScan()
        if not getgc then return nil end
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                if rawget(v, "Booths") and rawget(v, "Players") and rawget(v, "Active") == nil then
                    if type(v.Booths) == "table" and type(v.Players) == "table" then
                        return v
                    end
                end
            end
        end
        return nil
    end

    local liveData = GCScan()
    if liveData then
        getgenv().boothData = liveData
    else
        getgenv().boothData = {Booths = {}, Players = {}}
        local l_DataStream2_0 = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DataStream2");
        if getgenv().UpdateEvent then getgenv().UpdateEvent:Disconnect() end
        getgenv().UpdateEvent = l_DataStream2_0.OnClientEvent:Connect(function(f, Name, Data)
            if f=="UpdateData" and Name == "Booths" then
            end
        end)
    end

    function getAllListings()
        local Data = getgenv().boothData
        if not Data or not Data.Booths then return {} end 
        local Listings = {}
        for BoothId,BoothData in pairs(Data.Booths) do
            local Owner = BoothData.Owner
            if not Owner then continue end
            if not Data.Players[Owner] or not Data.Players[Owner].Listings then continue end
            local realPlayer = table.foreach(Players:GetChildren(), function(_,Plr)
                if Plr.UserId == tonumber(string.split(Owner, "_")[2]) then return Plr end
            end)
            for ListingId, ListingData in pairs(Data.Players[Owner].Listings) do
                if ListingData.ItemType=="Pet" then
                    local ItemId = ListingData.ItemId
                    local Price = ListingData.Price
                    if not Data.Players[Owner].Items or not Data.Players[Owner].Items[ItemId] then continue end
                    local ItemData = Data.Players[Owner].Items[ItemId]
                    if ItemData then
                        local Type = ItemData.PetType
                        local PetData = ItemData.PetData
                        if not PetData.IsFavorite then
                            local Weight = PetData.BaseWeight*1.1
                            local MaxWeight = Weight*10
                            table.insert(Listings, {
                                Owner = Owner, Player = realPlayer, ListingId = ListingId, ItemId = ItemId,
                                PetType = Type, PetWeight = Weight, PetMax = MaxWeight, Price = Price
                            })
                        end
                    end
                end
            end
        end
        return Listings
    end

    function Sniped(PetName, Weight, Price)
        local function FormatPrice(n)
            n = tonumber(n) or 0
            local s = tostring(math.floor(n)):reverse():gsub("(%d%d%d)", "%1,"):reverse()
            return s:gsub("^,", "")
        end
        local Embed_Data =  {
            description="\n🕙 **Sniped At**: <t:"..math.floor(tick())..":R>\n-# account: ||"..Player.Name.."||",
            color=65280, 
            author={name=`GOON SNIPER: Got {PetName}({math.floor(Weight*100)/100}kg) for {FormatPrice(Price)}`}
        }
        local newData = HttpService:JSONEncode({embeds={Embed_Data}})
        local request = http_request or request or HttpPost or syn.request
        request({Url = "https://discord.com/api/webhooks/1453157686467367085/YwXMx09qDmAEnKYk_7KhtvAYWLPYWLc2fynfiGwPxyUoCcIBUwDUZkk9M3_PJ4DBim0w", Body = newData, Method = "POST", Headers = {["content-type"] = "application/json"}})
    end

    function MainLoop()
        local Listings = getAllListings()
        local MyTokens = 0
        pcall(function()
            if DataService then MyTokens = DataService:GetData().TradeData.Tokens end
        end)

        for _,Data in pairs(Listings) do
            local Settings = getgenv().CurrentFilters[Data.PetType]
            if Settings then
                local MinWeight = Settings[1] or 0
                local MaxPrice = Settings[2] or 9999999
                
                if not SeenListings[Data.ListingId] then
                    print("🔎 FOUND INTEREST:", Data.PetType, "| Price:", Data.Price, "| Weight:", math.floor(Data.PetMax))
                    SeenListings[Data.ListingId] = true 
                end

                if Data.PetMax >= MinWeight and Data.Price <= MaxPrice and Data.Player ~= Player then
                    if Data.Price <= MyTokens then
                        getgenv().LastFound = tick()
                        local X,Y = ReplicatedStorage.GameEvents.TradeEvents.Booths.BuyListing:InvokeServer(Data.Player, Data.ListingId)
                        if X then
                            Sniped(Data.PetType, Data.PetMax, Data.Price)
                            StatusLbl.Text = "STATUS: COOLDOWN (5s)..."
                            StatusLbl.TextColor3 = Color3.fromRGB(255, 200, 0)
                            task.wait(5)
                            StatusLbl.Text = "STATUS: SCANNING..."
                            StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
                        end
                    end
                end
            end
        end
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        getgenv().SniperEnabled = not getgenv().SniperEnabled
        SaveConfig() 
        if getgenv().SniperEnabled then
            ToggleBtn.Text = "DEACTIVATE"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 50, 50) 
            Stroke.Color = Color3.fromRGB(255, 50, 50)
            StatusLbl.Text = "STATUS: SCANNING..."
            getgenv().LastFound = tick()
            SeenListings = {} 
        else
            ToggleBtn.Text = "ACTIVATE SNIPER"
            ToggleBtn.TextColor3 = Color3.fromRGB(50, 255, 100) 
            Stroke.Color = Color3.fromRGB(50, 255, 100)
            StatusLbl.Text = "STATUS: IDLE"
        end
    end)

    task.spawn(function()
        while true do
            task.wait()
            if getgenv().SniperEnabled then
                if game.PlaceId ~= TradeWorldID then
                    StatusLbl.Text = "STATUS: WRONG WORLD! (60s)"
                    StatusLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
                    local Teleporting = true
                    for i = 60, 1, -1 do
                        if not getgenv().SniperEnabled then 
                            Teleporting = false
                            break 
                        end
                        StatusLbl.Text = "STATUS: TELEPORTING IN " .. i .. "s..."
                        task.wait(1)
                    end
                    if Teleporting and getgenv().SniperEnabled then
                        StatusLbl.Text = "STATUS: TELEPORTING..."
                        TeleportService:Teleport(TradeWorldID, Player)
                        task.wait(10)
                    end
                else
                    pcall(MainLoop)
                    local TimeSince = tick() - getgenv().LastFound
                    if TimeSince > 60 then
                        StatusLbl.Text = "STATUS: SERVER DRY. HOPPING..."
                        Hop()
                        getgenv().LastFound = tick() + 60
                    elseif TimeSince > 10 and string.find(StatusLbl.Text, "COOLDOWN") == nil then
                        StatusLbl.Text = "STATUS: SCANNING... ("..math.floor(60 - TimeSince).."s)"
                    end
                end
            end
        end
    end)

    Player.Idled:Connect(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
    
    -- ==============================================================
    --                END OF MAIN SNIPER SCRIPT
    -- ==============================================================
end

-- [5] KEY GUI (First Load)
local function CreateKeyUI()
    if getgenv().KeyGUI then getgenv().KeyGUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GoonKeySystem"
    ScreenGui.Parent = PlayerGui
    getgenv().KeyGUI = ScreenGui

    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame.Size = UDim2.new(0, 300, 0, 180)
    Frame.Position = UDim2.new(0.5, -150, 0.4, -90)
    Frame.Active = true
    Frame.Draggable = true
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.Text = "GOON SNIPER ACCESS"
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 20
    Title.TextColor3 = Color3.fromRGB(50, 255, 100)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1

    local KeyBox = Instance.new("TextBox")
    KeyBox.Parent = Frame
    KeyBox.Size = UDim2.new(0.8, 0, 0, 40)
    KeyBox.Position = UDim2.new(0.1, 0, 0.35, 0)
    KeyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyBox.PlaceholderText = "Enter License Key..."
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.TextSize = 14
    
    local corner2 = Instance.new("UICorner")
    corner2.Parent = KeyBox
    
    local Submit = Instance.new("TextButton")
    Submit.Parent = Frame
    Submit.Size = UDim2.new(0.8, 0, 0, 35)
    Submit.Position = UDim2.new(0.1, 0, 0.65, 0)
    Submit.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    Submit.TextColor3 = Color3.fromRGB(25, 25, 25)
    Submit.Font = Enum.Font.GothamBold
    Submit.Text = "VERIFY KEY"
    
    local corner3 = Instance.new("UICorner")
    corner3.Parent = Submit
    
    local Info = Instance.new("TextLabel")
    Info.Parent = Frame
    Info.Text = "Checking online database..."
    Info.Size = UDim2.new(1,0,0,20)
    Info.Position = UDim2.new(0,0,0.85,0)
    Info.BackgroundTransparency = 1
    Info.TextColor3 = Color3.fromRGB(100,100,100)
    Info.Font = Enum.Font.Gotham
    Info.TextSize = 10

    Submit.MouseButton1Click:Connect(function()
        Info.Text = "Verifying..."
        if CheckKey(KeyBox.Text) then
            Submit.Text = "SUCCESS!"
            Info.Text = "Welcome!"
            task.wait(0.5)
            writefile(KeyFile, KeyBox.Text) -- Save key for later
            LoadSniper()
        else
            Submit.Text = "INVALID KEY"
            Info.Text = "Key not found in database."
            Submit.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            task.wait(1)
            Submit.Text = "VERIFY KEY"
            Submit.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        end
    end)
end

-- [6] CHECK SAVED KEY FIRST
if isfile and isfile(KeyFile) then
    local SavedKey = readfile(KeyFile)
    -- Verify the saved key is still valid online
    if CheckKey(SavedKey) then
        LoadSniper()
    else
        CreateKeyUI()
    end
else
    CreateKeyUI()
end
