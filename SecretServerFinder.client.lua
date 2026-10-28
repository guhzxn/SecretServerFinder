-- Secret Server Finder GUI
-- LocalScript em StarterPlayer > StarterPlayerScripts
-- GUI e filtros funcionais; os resultados reais precisam vir de uma fonte autorizada.
-- Não existe API pública universal para descobrir raridades/Money/s dentro de qualquer servidor.

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local COLORS = {
    bg = Color3.fromRGB(13, 13, 15),
    panel = Color3.fromRGB(22, 22, 25),
    panel2 = Color3.fromRGB(30, 30, 34),
    row = Color3.fromRGB(25, 25, 29),
    border = Color3.fromRGB(62, 62, 69),
    white = Color3.fromRGB(245, 245, 247),
    muted = Color3.fromRGB(155, 155, 165),
    green = Color3.fromRGB(135, 225, 160),
    red = Color3.fromRGB(240, 125, 125),
}

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function round(parent, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 8)}, parent)
end

local function stroke(parent, color, thickness)
    make("UIStroke", {
        Color = color or COLORS.border,
        Thickness = thickness or 1,
        Transparency = 0.15,
    }, parent)
end

local function label(parent, text, size, color, font)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Text = text or "",
        TextColor3 = color or COLORS.white,
        Font = font or Enum.Font.Gotham,
        TextSize = size or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        AutomaticSize = Enum.AutomaticSize.None,
    }, parent)
end

local function button(parent, text, width)
    local b = make("TextButton", {
        AutoButtonColor = true,
        BackgroundColor3 = COLORS.panel2,
        BorderSizePixel = 0,
        Size = UDim2.new(0, width or 100, 0, 32),
        Text = text,
        TextColor3 = COLORS.white,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
    }, parent)
    round(b, 7)
    stroke(b)
    return b
end

local function textBox(parent, placeholder, width, defaultText)
    local box = make("TextBox", {
        BackgroundColor3 = COLORS.bg,
        BorderSizePixel = 0,
        Size = UDim2.new(0, width or 120, 0, 32),
        Text = defaultText or "",
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = COLORS.muted,
        TextColor3 = COLORS.white,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        TextSize = 12,
    }, parent)
    round(box, 7)
    stroke(box)
    return box
end

local screen = make("ScreenGui", {
    Name = "SecretServerFinder",
    ResetOnSpawn = false,
    IgnoreGuiInset = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local main = make("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0, 650, 0, 560),
    BackgroundColor3 = COLORS.bg,
    BorderSizePixel = 0,
}, screen)
round(main, 12)
stroke(main, Color3.fromRGB(88, 88, 96), 1.2)

local scale = make("UIScale", {Scale = 1}, main)
local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    scale.Scale = math.clamp(math.min(viewport.X / 720, viewport.Y / 630), 0.65, 1)
end
updateScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local header = make("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 56),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
}, main)
round(header, 12)
local headerCover = make("Frame", {
    Position = UDim2.new(0, 0, 1, -12),
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
}, header)

local title = label(header, "SECRET SERVER FINDER", 18, COLORS.white, Enum.Font.GothamBold)
title.Position = UDim2.new(0, 18, 0, 0)
title.Size = UDim2.new(1, -190, 1, 0)

local statusDot = make("Frame", {
    Size = UDim2.new(0, 7, 0, 7),
    Position = UDim2.new(1, -174, 0.5, -3),
    BackgroundColor3 = COLORS.muted,
    BorderSizePixel = 0,
}, header)
round(statusDot, 10)

local statusLabel = label(header, "PARADO", 10, COLORS.muted, Enum.Font.GothamBold)
statusLabel.Position = UDim2.new(1, -160, 0, 0)
statusLabel.Size = UDim2.new(0, 70, 1, 0)

local minimizeButton = button(header, "—", 34)
minimizeButton.Position = UDim2.new(1, -48, 0.5, -16)

local body = make("Frame", {
    Name = "Body",
    Position = UDim2.new(0, 14, 0, 68),
    Size = UDim2.new(1, -28, 1, -82),
    BackgroundTransparency = 1,
}, main)

local controlPanel = make("Frame", {
    Size = UDim2.new(1, 0, 0, 112),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
}, body)
round(controlPanel, 9)
stroke(controlPanel)

local startButton = button(controlPanel, "INICIAR BUSCA", 126)
startButton.Position = UDim2.new(0, 12, 0, 12)
startButton.BackgroundColor3 = Color3.fromRGB(44, 52, 47)

local rarityLabel = label(controlPanel, "RARIDADE", 10, COLORS.muted, Enum.Font.GothamBold)
rarityLabel.Position = UDim2.new(0, 152, 0, 4)
rarityLabel.Size = UDim2.new(0, 100, 0, 18)

local rarityButton = button(controlPanel, "TODAS  ▾", 110)
rarityButton.Position = UDim2.new(0, 152, 0, 24)

local moneyLabel = label(controlPanel, "MÍNIMO MONEY/S", 10, COLORS.muted, Enum.Font.GothamBold)
moneyLabel.Position = UDim2.new(0, 274, 0, 4)
moneyLabel.Size = UDim2.new(0, 125, 0, 18)

local moneyBox = textBox(controlPanel, "Ex.: 50000000", 125, "0")
moneyBox.Position = UDim2.new(0, 274, 0, 24)

local slotsLabel = label(controlPanel, "VAGAS MÍNIMAS", 10, COLORS.muted, Enum.Font.GothamBold)
slotsLabel.Position = UDim2.new(0, 411, 0, 4)
slotsLabel.Size = UDim2.new(0, 110, 0, 18)

local slotsButton = button(controlPanel, "1 VAGA  ▾", 110)
slotsButton.Position = UDim2.new(0, 411, 0, 24)

local refreshButton = button(controlPanel, "ATUALIZAR", 100)
refreshButton.Position = UDim2.new(1, -112, 0, 12)

local hint = label(controlPanel, "Resultados demonstrativos até conectar uma fonte autorizada.", 10, COLORS.muted)
hint.Position = UDim2.new(0, 12, 0, 69)
hint.Size = UDim2.new(1, -24, 0, 25)
hint.TextWrapped = true

local listTitle = label(body, "SERVIDORES ENCONTRADOS", 11, COLORS.muted, Enum.Font.GothamBold)
listTitle.Position = UDim2.new(0, 2, 0, 122)
listTitle.Size = UDim2.new(0.7, 0, 0, 20)

local countLabel = label(body, "0 RESULTADOS", 10, COLORS.muted, Enum.Font.GothamBold)
countLabel.Position = UDim2.new(1, -120, 0, 122)
countLabel.Size = UDim2.new(0, 118, 0, 20)
countLabel.TextXAlignment = Enum.TextXAlignment.Right

local list = make("ScrollingFrame", {
    Name = "ServerList",
    Position = UDim2.new(0, 0, 0, 146),
    Size = UDim2.new(1, 0, 1, -222),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    ScrollBarThickness = 5,
    ScrollBarImageColor3 = COLORS.muted,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, body)
round(list, 9)
stroke(list)
make("UIPadding", {
    PaddingTop = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
}, list)
local listLayout = make("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, list)

local emptyText = label(list, "Nenhum servidor carregado.\nConecte uma fonte de dados autorizada para exibir resultados reais.", 12, COLORS.muted)
emptyText.Name = "EmptyText"
emptyText.Size = UDim2.new(1, -16, 0, 58)
emptyText.TextWrapped = true
emptyText.TextXAlignment = Enum.TextXAlignment.Center
emptyText.LayoutOrder = 0

local jobPanel = make("Frame", {
    Name = "JobIdPanel",
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 64),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
}, body)
round(jobPanel, 9)
stroke(jobPanel)

local jobLabel = label(jobPanel, "JOB ID MANAGER", 10, COLORS.muted, Enum.Font.GothamBold)
jobLabel.Position = UDim2.new(0, 10, 0, 3)
jobLabel.Size = UDim2.new(0, 115, 0, 16)

local jobBox = textBox(jobPanel, "Cole o Job ID aqui...", 270, "")
jobBox.Position = UDim2.new(0, 10, 0, 23)
jobBox.Size = UDim2.new(1, -270, 0, 30)

local joinButton = button(jobPanel, "ENTRAR", 92)
joinButton.Position = UDim2.new(1, -248, 0, 22)

local copyCurrentButton = button(jobPanel, "COPIAR ID ATUAL", 140)
copyCurrentButton.Position = UDim2.new(1, -148, 0, 22)

local rarityOptions = {"TODAS", "SECRET", "ETERNAL", "DIVINE"}
local rarityIndex = 1
local slotOptions = {1, 2, 3, 4, 5, 6, 7}
local slotIndex = 1
local isSearching = false
local minimized = false
local selectedJobId = nil
local serverData = {}

local function notify(titleText, messageText)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = titleText,
            Text = messageText,
            Duration = 4,
        })
    end)
end

local function setStatus(searching)
    isSearching = searching
    if searching then
        statusLabel.Text = "BUSCANDO"
        statusLabel.TextColor3 = COLORS.green
        statusDot.BackgroundColor3 = COLORS.green
        startButton.Text = "PAUSAR BUSCA"
    else
        statusLabel.Text = "PARADO"
        statusLabel.TextColor3 = COLORS.muted
        statusDot.BackgroundColor3 = COLORS.muted
        startButton.Text = "INICIAR BUSCA"
    end
end

local function copyText(value)
    -- Roblox não oferece uma API universal de clipboard para LocalScripts.
    -- O texto é selecionado no campo para permitir Ctrl+C manualmente.
    if type(value) ~= "string" or value == "" then
        notify("Secret Server Finder", "Não há Job ID para copiar.")
        return
    end
    jobBox.Text = value
    jobBox:CaptureFocus()
    jobBox.CursorPosition = #jobBox.Text + 1
    notify("Job ID selecionado", "Use Ctrl+A e Ctrl+C para copiar.")
end

local function clearRows()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") and child.Name == "ServerRow" then
            child:Destroy()
        end
    end
end

local function formatNumber(n)
    n = tonumber(n) or 0
    if n >= 1e9 then return string.format("%.2fB", n / 1e9) end
    if n >= 1e6 then return string.format("%.2fM", n / 1e6) end
    if n >= 1e3 then return string.format("%.2fK", n / 1e3) end
    return tostring(math.floor(n))
end

local function renderServers()
    clearRows()
    local filtered = {}
    local minMoney = tonumber(moneyBox.Text) or 0
    local minSlots = slotOptions[slotIndex]
    local selectedRarity = rarityOptions[rarityIndex]

    for _, data in ipairs(serverData) do
        local slots = math.max(0, (tonumber(data.maxPlayers) or 7) - (tonumber(data.playing) or 0))
        local rarityOk = selectedRarity == "TODAS" or string.upper(tostring(data.rarity or "")) == selectedRarity
        local moneyOk = (tonumber(data.moneyPerSecond) or 0) >= minMoney
        local slotsOk = slots >= minSlots
        if rarityOk and moneyOk and slotsOk then
            table.insert(filtered, data)
        end
    end

    table.sort(filtered, function(a, b)
        return (tonumber(a.moneyPerSecond) or 0) > (tonumber(b.moneyPerSecond) or 0)
    end)

    emptyText.Visible = #filtered == 0
    countLabel.Text = tostring(#filtered) .. " RESULTADOS"

    for i, data in ipairs(filtered) do
        local playing = tonumber(data.playing) or 0
        local maxPlayers = tonumber(data.maxPlayers) or 7
        local slots = math.max(0, maxPlayers - playing)
        local row = make("Frame", {
            Name = "ServerRow",
            Size = UDim2.new(1, -2, 0, 76),
            BackgroundColor3 = COLORS.row,
            BorderSizePixel = 0,
            LayoutOrder = i,
        }, list)
        round(row, 8)
        stroke(row)

        local name = label(row, tostring(data.name or "Servidor encontrado"), 14, COLORS.white, Enum.Font.GothamBold)
        name.Position = UDim2.new(0, 12, 0, 7)
        name.Size = UDim2.new(1, -160, 0, 20)
        name.TextTruncate = Enum.TextTruncate.AtEnd

        local details = label(row,
            string.format("%s  •  %s/s  •  %d/%d players  •  %d vagas",
                tostring(data.rarity or "Raridade desconhecida"),
                formatNumber(data.moneyPerSecond),
                playing, maxPlayers, slots),
            11, COLORS.muted)
        details.Position = UDim2.new(0, 12, 0, 30)
        details.Size = UDim2.new(1, -160, 0, 18)
        details.TextTruncate = Enum.TextTruncate.AtEnd

        local job = label(row, "Job: " .. tostring(data.jobId or "indisponível"), 10, COLORS.muted)
        job.Position = UDim2.new(0, 12, 0, 51)
        job.Size = UDim2.new(1, -160, 0, 16)
        job.TextTruncate = Enum.TextTruncate.AtEnd

        local join = button(row, slots > 0 and "ENTRAR" or "CHEIO", 76)
        join.Position = UDim2.new(1, -88, 0, 8)
        join.Size = UDim2.new(0, 76, 0, 28)
        join.Active = slots > 0 and type(data.jobId) == "string" and data.jobId ~= ""
        join.AutoButtonColor = join.Active
        join.TextColor3 = join.Active and COLORS.white or COLORS.muted
        join.MouseButton1Click:Connect(function()
            if not join.Active then
                notify("Servidor indisponível", "Sem vagas ou Job ID não informado.")
                return
            end
            if slots <= 0 then
                notify("Servidor cheio", "Este servidor está cheio.")
                return
            end
            selectedJobId = data.jobId
            jobBox.Text = data.jobId
            local placeId = tonumber(data.placeId) or game.PlaceId
            local ok, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, data.jobId, player)
            end)
            if not ok then
                notify("Falha no teleporte", tostring(err))
            else
                notify("Teleporte solicitado", "A disponibilidade pode mudar antes da conexão.")
            end
        end)

        local copy = button(row, "COPIAR ID", 76)
        copy.Position = UDim2.new(1, -88, 0, 42)
        copy.Size = UDim2.new(0, 76, 0, 25)
        copy.MouseButton1Click:Connect(function()
            selectedJobId = data.jobId
            copyText(data.jobId)
        end)
    end
end

local function loadServers(data)
    -- Integração: chame esta função com dados vindos de uma fonte autorizada.
    -- Formato de cada item:
    -- {name="Nome", rarity="SECRET", moneyPerSecond=12345, playing=5,
    --  maxPlayers=7, jobId="...", placeId=game.PlaceId}
    serverData = type(data) == "table" and data or {}
    renderServers()
end

startButton.MouseButton1Click:Connect(function()
    setStatus(not isSearching)
    if isSearching then
        hint.Text = "Busca ativada. A descoberta real precisa de uma fonte autorizada."
    else
        hint.Text = "Busca pausada. Nenhuma consulta de servidor está sendo executada."
    end
end)

rarityButton.MouseButton1Click:Connect(function()
    rarityIndex = (rarityIndex % #rarityOptions) + 1
    rarityButton.Text = rarityOptions[rarityIndex] .. "  ▾"
    renderServers()
end)

slotsButton.MouseButton1Click:Connect(function()
    slotIndex = (slotIndex % #slotOptions) + 1
    slotsButton.Text = tostring(slotOptions[slotIndex]) .. (slotOptions[slotIndex] == 1 and " VAGA  ▾" or " VAGAS  ▾")
    renderServers()
end)

moneyBox.FocusLost:Connect(renderServers)
refreshButton.MouseButton1Click:Connect(function()
    renderServers()
    notify("Lista atualizada", "Os filtros foram reaplicados aos dados carregados.")
end)

joinButton.MouseButton1Click:Connect(function()
    local jobId = string.gsub(jobBox.Text, "^%s*(.-)%s*$", "%1")
    if jobId == "" then
        notify("Job ID vazio", "Cole o Job ID de uma instância.")
        return
    end
    if #jobId > 100 or string.find(jobId, "%s") then
        notify("Job ID inválido", "Verifique o identificador informado.")
        return
    end
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, player)
    end)
    if not ok then
        notify("Falha no teleporte", tostring(err))
    else
        notify("Teleporte solicitado", "O Roblox tentará entrar nessa instância.")
    end
end)

copyCurrentButton.MouseButton1Click:Connect(function()
    copyText(game.JobId)
end)

minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    main.Size = minimized and UDim2.new(0, 650, 0, 56) or UDim2.new(0, 650, 0, 560)
    minimizeButton.Text = minimized and "+" or "—"
end)

-- Permite arrastar a janela pelo cabeçalho.
do
    local dragging = false
    local dragStart
    local startPos

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Função disponível para integrar dados autorizados posteriormente.
-- Exemplo de teste local (dados fictícios): descomente as linhas abaixo.
-- loadServers({
--     {name="Nightflame", rarity="SECRET", moneyPerSecond=163550000, playing=5, maxPlayers=7, jobId="JOB_ID_DE_TESTE", placeId=game.PlaceId},
--     {name="Nightflame Golden", rarity="ETERNAL", moneyPerSecond=105870000, playing=7, maxPlayers=7, jobId="OUTRO_JOB_ID", placeId=game.PlaceId},
-- })

_G.SecretServerFinderLoadServers = loadServers
setStatus(false)
renderServers()
