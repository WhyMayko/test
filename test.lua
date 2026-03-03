--[[
    ============================================================
    GALAX LIB - UI FRAMEWORK (Matcha External)
    ============================================================
    Autor: Galax & Gemini
    Versão: 2.0 (Integrated User System)
    
    COMO USAR:
    local Galax = loadstring(game:HttpGet("..."))()
    local Win = Galax:CreateWindow({ 
        Title = "Bizarre Hub", 
        Size = Vector2.new(550, 400),
        MenuKey = 0x70 -- F1
    })
    
    MÉTODOS:
    - Win:AddTab(name) -> Cria uma nova aba lateral
    - Tab:AddSection(name) -> Cria um grupo de widgets
    - Sec:AddToggle(label, default, callback)
    - Sec:AddSlider(label, {Min, Max, Default, Suffix}, callback)
    - Sec:AddDropdown(label, {options}, default, callback)
    - Sec:AddButton(label, callback)
    - Sec:AddKeybind(label, default, callback)
    - Sec:AddLabel(text)
    ============================================================
]]

local GalaxLib = {}

-- ── TEMAS ────────────────────────────────────────────────────
local Themes = {
    Galax = {
        Body=Color3.fromRGB(10,10,14), Surface0=Color3.fromRGB(18,18,24), Surface1=Color3.fromRGB(26,26,34),
        Border0=Color3.fromRGB(35,35,46), Border1=Color3.fromRGB(50,50,65),
        Accent=Color3.fromRGB(130,80,220), AccentDark=Color3.fromRGB(70,38,140),
        Text=Color3.fromRGB(240,240,245), SubText=Color3.fromRGB(110,110,130),
        Red=Color3.fromRGB(220,70,70), RedDark=Color3.fromRGB(90,22,22),
    },
    Gamesense = { Body=Color3.fromRGB(0,0,0), Surface0=Color3.fromRGB(26,26,26), Surface1=Color3.fromRGB(45,45,45), Border0=Color3.fromRGB(48,48,48), Border1=Color3.fromRGB(60,60,60), Accent=Color3.fromRGB(114,178,21), AccentDark=Color3.fromRGB(60,100,10), Text=Color3.fromRGB(144,144,144), SubText=Color3.fromRGB(59,59,59), Red=Color3.fromRGB(220,70,70), RedDark=Color3.fromRGB(90,22,22) },
    Dracula = { Body=Color3.fromRGB(24,25,38), Surface0=Color3.fromRGB(33,34,50), Surface1=Color3.fromRGB(44,44,60), Border0=Color3.fromRGB(68,71,90), Border1=Color3.fromRGB(86,90,112), Accent=Color3.fromRGB(189,147,249), AccentDark=Color3.fromRGB(100,70,180), Text=Color3.fromRGB(248,248,242), SubText=Color3.fromRGB(98,114,164), Red=Color3.fromRGB(255,85,85), RedDark=Color3.fromRGB(120,30,30) }
}

local T = {}
for k,v in pairs(Themes.Galax) do T[k]=v end
local ThemeNames = {"Galax","Gamesense","Dracula"}

local function applyTheme(name)
    local src = Themes[name]; if not src then return end
    for k,v in pairs(src) do T[k]=v end
end

-- ── UTILITÁRIOS ──────────────────────────────────────────────
local KeyNames = {}
do
    local raw = { [0x08]="BACK",[0x09]="TAB",[0x0D]="ENTER",[0x10]="SHIFT",[0x11]="CTRL",[0x12]="ALT",[0x20]="SPACE" }
    for k,v in pairs(raw) do KeyNames[k]=v end
    for i=65,90 do KeyNames[i]=string.char(i) end
end

local function mpos()
    local lp = game:GetService("Players").LocalPlayer
    local m = lp:GetMouse()
    return Vector2.new(m.X, m.Y)
end

local function over(pos,size)
    local m = mpos()
    return m.X>=pos.X and m.X<=pos.X+size.X and m.Y>=pos.Y and m.Y<=pos.Y+size.Y
end

-- ── INPUT & POOL ─────────────────────────────────────────────
local Input = {_prev={}, click=false, held=false}
function Input:update()
    local m1 = ismouse1pressed()
    self.click = m1 and not self._prev.m1; self.held = m1
    self._prev.m1 = m1
end

local function poolNew() return {d={}, seen={}} end
local function poolAdd(pool, id, dtype, props)
    pool.seen[id] = true
    local e = pool.d[id]
    if e then 
        for k,v in pairs(props) do e[k]=v end
        return e 
    end
    local obj = Drawing.new(dtype)
    for k,v in pairs(props) do obj[k]=v end
    pool.d[id] = obj
    return obj
end

-- ── WINDOW ENGINE ────────────────────────────────────────────
function GalaxLib:CreateWindow(opts)
    local WIN = {
        Title = opts.Title or "Galax",
        Size = opts.Size or Vector2.new(550, 420),
        MenuKey = opts.MenuKey or 0x70,
        _pos = Vector2.new(100, 100),
        _open = true,
        _running = true,
        _pool = poolNew(),
        _tabs = {},
        _openTab = nil
    }

    function WIN:AddTab(name)
        local TAB = { _name = name, _sections = {}, _win = self }
        function TAB:AddSection(sname)
            local SEC = { _name = sname, _widgets = {}, _win = self._win }
            function SEC:AddToggle(l, d, cb) table.insert(self._widgets, {type="toggle", label=l, value=d, cb=cb}); return self._widgets[#self._widgets] end
            function SEC:AddButton(l, cb) table.insert(self._widgets, {type="button", label=l, cb=cb}) end
            function SEC:AddLabel(l) table.insert(self._widgets, {type="label", label=l}) end
            function SEC:AddSlider(l, o, cb) table.insert(self._widgets, {type="slider", label=l, min=o.Min, max=o.Max, value=o.Default, suffix=o.Suffix or "", cb=cb}) end
            function SEC:AddDropdown(l, opt, d, cb) table.insert(self._widgets, {type="dropdown", label=l, options=opt, value=d, cb=cb}) end
            function SEC:AddKeybind(l, d, cb) table.insert(self._widgets, {type="keybind", label=l, value=d, cb=cb}) end
            table.insert(TAB._sections, SEC); return SEC
        end
        table.insert(self._tabs, TAB)
        if not self._openTab then self._openTab = TAB end
        return TAB
    end

    -- ── INTERFACE USER (Aba Settings Automática) ────────────────
    function WIN:_buildSettings()
        local STAB = self:AddTab("Settings")
        local lp = game:GetService("Players").LocalPlayer
        
        local SUSER = STAB:AddSection("USER")
        SUSER:AddLabel("Player: " .. (lp and lp.Name or "Guest"))
        SUSER:AddLabel("Update Notes: v2.0 Live")
        
        local SMENU = STAB:AddSection("Menu")
        SMENU:AddKeybind("Toggle Key", self.MenuKey, function(v) self.MenuKey = v end)
        SMENU:AddButton("Kill Script", function() self._running = false end)
        
        local STHEME = STAB:AddSection("Theme")
        STHEME:AddDropdown("Theme Select", ThemeNames, "Galax", function(v) applyTheme(v) end)
    end

    -- ── RENDERIZAÇÃO DOS WIDGETS ─────────────────────────────────
    function WIN:_renderWidget(item, pool, id, x, y, w)
        if item.type == "label" then
            poolAdd(pool, id, "Text", {Position=Vector2.new(x,y), Text=item.label, Size=13, Color=T.SubText, Visible=true, ZIndex=10})
            return 18
        elseif item.type == "toggle" then
            local isHov = over(Vector2.new(x,y), Vector2.new(w, 16))
            if Input.click and isHov then item.value = not item.value; item.cb(item.value) end
            poolAdd(pool, id.."_t", "Text", {Position=Vector2.new(x,y), Text=item.label, Size=13, Color=item.value and T.Text or T.SubText, Visible=true, ZIndex=10})
            poolAdd(pool, id.."_bg", "Square", {Position=Vector2.new(x+w-15, y), Size=Vector2.new(14,14), Filled=true, Color=item.value and T.Accent or T.Surface1, Visible=true, ZIndex=10})
            return 20
        elseif item.type == "button" then
            local isHov = over(Vector2.new(x,y), Vector2.new(w, 22))
            if Input.click and isHov then item.cb() end
            poolAdd(pool, id.."_bg", "Square", {Position=Vector2.new(x,y), Size=Vector2.new(w,22), Filled=true, Color=isHov and T.AccentDark or T.Surface1, Visible=true, ZIndex=10})
            poolAdd(pool, id.."_txt", "Text", {Position=Vector2.new(x+(w/2), y+4), Text=item.label, Center=true, Size=13, Color=T.Text, Visible=true, ZIndex=11})
            return 26
        end
        return 0
    end

    -- ── LOOP PRINCIPAL ───────────────────────────────────────────
    task.spawn(function()
        WIN:_buildSettings()
        while WIN._running do
            Input:update()
            poolBeginFrame(WIN._pool)

            if WIN._open then
                -- Fundo e Título
                poolAdd(WIN._pool, "Bg", "Square", {Position=WIN._pos, Size=WIN.Size, Color=T.Body, Filled=true, Visible=true, ZIndex=1})
                poolAdd(WIN._pool, "Title", "Text", {Position=WIN._pos+Vector2.new(15,12), Text=WIN.Title, Size=16, Color=T.Text, Visible=true, ZIndex=2})
                
                -- O Círculo com o "+" no Header
                local btnPos = WIN._pos + Vector2.new(WIN.Size.X - 35, 18)
                local hovPlus = over(btnPos - Vector2.new(10,10), Vector2.new(20,20))
                poolAdd(WIN._pool, "BtnPlusC", "Circle", {Position=btnPos, Radius=10, Color=hovPlus and T.Text or T.Accent, Thickness=1.5, Visible=true, ZIndex=50})
                poolAdd(WIN._pool, "BtnPlusT", "Text", {Position=btnPos-Vector2.new(4,7), Text="+", Size=16, Color=T.Text, Visible=true, ZIndex=51})
                
                if Input.click and hovPlus then
                    for _,t in pairs(WIN._tabs) do if t._name == "Settings" then WIN._openTab = t end end
                end

                -- Sidebar
                local ty = WIN._pos.Y + 50
                for _, tab in ipairs(WIN._tabs) do
                    local isSel = (WIN._openTab == tab)
                    if Input.click and over(Vector2.new(WIN._pos.X+10, ty), Vector2.new(100, 20)) then WIN._openTab = tab end
                    poolAdd(WIN._pool, "Tab"..tab._name, "Text", {Position=Vector2.new(WIN._pos.X+15, ty), Text=tab._name:upper(), Size=14, Color=isSel and T.Accent or T.SubText, Visible=true, ZIndex=5})
                    ty = ty + 25
                end

                -- Conteúdo
                if WIN._openTab then
                    local sx, sy = WIN._pos.X + 130, WIN._pos.Y + 50
                    for _, sec in ipairs(WIN._openTab._sections) do
                        poolAdd(WIN._pool, "Sec"..sec._name, "Text", {Position=Vector2.new(sx, sy), Text=sec._name, Size=14, Color=T.Accent, Visible=true, ZIndex=5})
                        sy = sy + 22
                        for i, w in ipairs(sec._widgets) do
                            sy = sy + WIN:_renderWidget(w, WIN._pool, "Wid"..sec._name..i, sx+10, sy, WIN.Size.X-160)
                        end
                        sy = sy + 15
                    end
                end
            end

            for id, obj in pairs(WIN._pool.d) do if not WIN._pool.seen[id] then obj.Visible = false end end
            task.wait()
        end
        for _,v in pairs(WIN._pool.d) do v:Remove() end
    end)

    return WIN
end

-- ── EXEMPLO DE USO FINAL ─────────────────────────────────────
-- local UI = GalaxLib:CreateWindow({ Title = "Bizarre Hub", Size = Vector2.new(500, 400) })
-- local Tab1 = UI:AddTab("Main")
-- local Sec1 = Tab1:AddSection("Combat")
-- Sec1:AddToggle("Auto Farm", false, function(v) print("Farm:", v) end)
-- Sec1:AddButton("Reset Character", function() print("Resetting...") end)

return GalaxLib
