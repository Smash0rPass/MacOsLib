local GuiLibrary = {}

-- Services
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function GuiLibrary.new(config)
    local lib = {}
    
    -- Default config
    config = config or {}
    config.title = config.title or "GUI Window"
    config.width = config.width or 300
    config.height = config.height or 150
    
    -- GUI Creation
    lib.ScreenGui = Instance.new("ScreenGui")
    lib.ScreenGui.Parent = CoreGui
    
    lib.MainFrame = Instance.new("Frame")
    lib.MainFrame.Name = "MainFrame"
    lib.MainFrame.Size = UDim2.new(0, config.width, 0, config.height)
    lib.MainFrame.Position = UDim2.new(0.5, -config.width/2, 0.5, -config.height/2)
    lib.MainFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    lib.MainFrame.BorderSizePixel = 0
    lib.MainFrame.ClipsDescendants = true
    lib.MainFrame.Parent = lib.ScreenGui
    
    -- Create TopBar
    local function createTopBar()
        local topBar = Instance.new("Frame")
        topBar.Size = UDim2.new(1, 0, 0, 30)
        topBar.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        topBar.BorderSizePixel = 0
        topBar.Parent = lib.MainFrame
        
        -- Window Title
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -120, 1, 0)
        title.Position = UDim2.new(0, 70, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = config.title
        title.TextColor3 = Color3.fromRGB(80, 80, 80)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 14
        title.Parent = topBar
        
        return topBar
    end
    
    -- Create window controls
    local function createWindowControls(topBar)
        local function createCircleButton(color, position)
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0, 12, 0, 12)
            button.Position = position
            button.BackgroundColor3 = color
            button.Text = ""
            button.Parent = topBar
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = button
            
            return button
        end
        
        local closeButton = createCircleButton(Color3.fromRGB(255, 95, 87), UDim2.new(0, 10, 0.5, -6))
        local minimizeButton = createCircleButton(Color3.fromRGB(255, 189, 46), UDim2.new(0, 30, 0.5, -6))
        
        return closeButton, minimizeButton
    end
    
    -- Initialize GUI elements
    lib.TopBar = createTopBar()
    lib.CloseButton, lib.MinimizeButton = createWindowControls(lib.TopBar)
    
    -- Add shadow and corners
    local function addStyling()
        local shadow = Instance.new("ImageLabel")
        shadow.Size = UDim2.new(1, 20, 1, 20)
        shadow.Position = UDim2.new(0, -10, 0, -10)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://297774371"
        shadow.ImageColor3 = Color3.fromRGB(20,20,20)
        shadow.ImageTransparency = 0.8
        shadow.Parent = lib.MainFrame
        shadow.ZIndex = 0
        
        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 8)
        mainCorner.Parent = lib.MainFrame
    end
    
    addStyling()
    
    -- Dragging functionality
    local dragging, dragInput, dragStart, startPos
    
    lib.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = lib.MainFrame.Position
        end
    end)
    
    lib.TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            lib.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Add methods
    function lib:AddButton(text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 120, 0, 35)
        button.Position = UDim2.new(0.5, -60, 0.5, -10)
        button.BackgroundColor3 = Color3.fromRGB(39, 201, 63)
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 14
        button.Parent = self.MainFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button
        
        button.MouseButton1Click:Connect(callback)
        return button
    end
    
    function lib:AddLabel(text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 1, -30)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(100, 100, 100)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = self.MainFrame
        return label
    end
    
    -- Close functionality
    lib.CloseButton.MouseButton1Click:Connect(function()
        lib.ScreenGui:Destroy()
    end)
    
    -- Minimize functionality
    local minimized = false
    lib.MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetSize = minimized and UDim2.new(0, config.width, 0, 30) or UDim2.new(0, config.width, 0, config.height)
        
        TweenService:Create(lib.MainFrame, 
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {Size = targetSize}
        ):Play()
    end)
    
    return lib
end

return GuiLibrary
