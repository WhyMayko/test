--[[
    GalaxLib - UI Library for Matcha External
    Made with love by Claude x Galax

    USAGE:
    local Win = GalaxLib:CreateWindow({ Title="Script", Size=Vector2.new(560,420), MenuKey=0x70 })
    local Tab = Win:AddTab("Combat")
    local Sec = Tab:AddSection("Aimbot")

    Sec:AddToggle("Enable", false, function(v) end)
    Sec:AddSlider("FOV", {Min=1, Max=360, Default=90, Suffix="°"}, function(v) end)
    Sec:AddDropdown("Mode", {"A","B","C"}, "A", {MaxVisible=4}, function(v) end)
    Sec:AddMultiDropdown("Flags", {"A","B","C"}, {}, {MaxVisible=4}, function(tbl) end)
    Sec:AddColorPicker("Color", Color3.fromRGB(255,0,0), function(c) end)
    Sec:AddKeybind("Trigger", 0x46, function() end)
    Sec:AddTextbox("Name", "default", function(v) end)
    Sec:AddLabel("v1.0")
    Sec:AddButton("Reset", function() end)

    -- All widgets (except Button) have :Get() and :Set(value)
    -- MultiDropdown:Get() returns table of selected strings
    -- ColorPicker:Get() returns Color3
    -- Dropdown scroll: mouse wheel or UP/DOWN arrow keys when open and hovering

    Win:Notify("msg", "title", 3)
    Win:Unload()

    -- "Settings" tab added automatically at end.
    --   Section "Menu"  : Toggle Key, Kill Script
    --   Section "Theme" : 7 built-in themes
]]

GalaxLib = {}

-- ── Themes ───────────────────────────────────────────────────
local Themes = {
    Galax = {
        Body=Color3.fromRGB(10,10,14), Surface0=Color3.fromRGB(18,18,24), Surface1=Color3.fromRGB(26,26,34),
        Border0=Color3.fromRGB(35,35,46), Border1=Color3.fromRGB(50,50,65),
        Accent=Color3.fromRGB(130,80,220), AccentDark=Color3.fromRGB(70,38,140),
        Text=Color3.fromRGB(240,240,245), SubText=Color3.fromRGB(110,110,130),
        Red=Color3.fromRGB(220,70,70), RedDark=Color3.fromRGB(90,22,22),
    },
    Gamesense = {
        Body=Color3.fromRGB(0,0,0), Surface0=Color3.fromRGB(26,26,26), Surface1=Color3.fromRGB(45,45,45),
        Border0=Color3.fromRGB(48,48,48), Border1=Color3.fromRGB(60,60,60),
        Accent=Color3.fromRGB(114,178,21), AccentDark=Color3.fromRGB(60,100,10),
        Text=Color3.fromRGB(144,144,144), SubText=Color3.fromRGB(59,59,59),
        Red=Color3.fromRGB(220,70,70), RedDark=Color3.fromRGB(90,22,22),
    },
    Dracula = {
        Body=Color3.fromRGB(24,25,38), Surface0=Color3.fromRGB(33,34,50), Surface1=Color3.fromRGB(44,44,60),
        Border0=Color3.fromRGB(68,71,90), Border1=Color3.fromRGB(86,90,112),
        Accent=Color3.fromRGB(189,147,249), AccentDark=Color3.fromRGB(100,70,180),
        Text=Color3.fromRGB(248,248,242), SubText=Color3.fromRGB(98,114,164),
        Red=Color3.fromRGB(255,85,85), RedDark=Color3.fromRGB(120,30,30),
    },
    Nord = {
        Body=Color3.fromRGB(29,33,40), Surface0=Color3.fromRGB(36,41,50), Surface1=Color3.fromRGB(46,52,64),
        Border0=Color3.fromRGB(59,66,82), Border1=Color3.fromRGB(76,86,106),
        Accent=Color3.fromRGB(136,192,208), AccentDark=Color3.fromRGB(67,103,120),
        Text=Color3.fromRGB(236,239,244), SubText=Color3.fromRGB(129,161,193),
        Red=Color3.fromRGB(191,97,106), RedDark=Color3.fromRGB(90,40,44),
    },
    Catppuccin = {
        Body=Color3.fromRGB(24,24,37), Surface0=Color3.fromRGB(30,30,46), Surface1=Color3.fromRGB(49,50,68),
        Border0=Color3.fromRGB(88,91,112), Border1=Color3.fromRGB(108,111,133),
        Accent=Color3.fromRGB(137,180,250), AccentDark=Color3.fromRGB(60,90,160),
        Text=Color3.fromRGB(205,214,244), SubText=Color3.fromRGB(166,173,200),
        Red=Color3.fromRGB(243,139,168), RedDark=Color3.fromRGB(120,50,70),
    },
    Synthwave = {
        Body=Color3.fromRGB(15,5,30), Surface0=Color3.fromRGB(25,10,45), Surface1=Color3.fromRGB(40,15,65),
        Border0=Color3.fromRGB(80,30,100), Border1=Color3.fromRGB(120,50,140),
        Accent=Color3.fromRGB(255,60,180), AccentDark=Color3.fromRGB(130,20,90),
        Text=Color3.fromRGB(255,220,255), SubText=Color3.fromRGB(180,120,200),
        Red=Color3.fromRGB(255,80,80), RedDark=Color3.fromRGB(100,20,20),
    },
    Sunset = {
        Body=Color3.fromRGB(18,8,5), Surface0=Color3.fromRGB(30,14,8), Surface1=Color3.fromRGB(48,22,12),
        Border0=Color3.fromRGB(80,40,20), Border1=Color3.fromRGB(110,60,30),
        Accent=Color3.fromRGB(255,120,40), AccentDark=Color3.fromRGB(140,55,10),
        Text=Color3.fromRGB(255,235,210), SubText=Color3.fromRGB(180,130,90),
        Red=Color3.fromRGB(255,70,50), RedDark=Color3.fromRGB(110,20,10),
    },
}

local T = {}
for k,v in pairs(Themes.Galax) do T[k]=v end
local ThemeNames = {"Galax","Gamesense","Dracula","Nord","Catppuccin","Synthwave","Sunset"}

local function applyTheme(name)
    local src = Themes[name]; if not src then return end
    for k,v in pairs(src) do T[k]=v end
end

-- ── Key names ────────────────────────────────────────────────
local KeyNames = {}
do
    local raw = {
        [0x08]="BACK",[0x09]="TAB",[0x0D]="ENTER",[0x10]="SHIFT",[0x11]="CTRL",
        [0x12]="ALT",[0x14]="CAPS",[0x1B]="ESC",[0x20]="SPACE",[0x21]="PGUP",
        [0x22]="PGDN",[0x23]="END",[0x24]="HOME",[0x25]="LEFT",[0x26]="UP",
        [0x27]="RIGHT",[0x28]="DOWN",[0x2D]="INS",[0x2E]="DEL",
        [0x30]="0",[0x31]="1",[0x32]="2",[0x33]="3",[0x34]="4",
        [0x35]="5",[0x36]="6",[0x37]="7",[0x38]="8",[0x39]="9",
        [0xBA]=";",[0xBB]="=",[0xBC]=",",[0xBD]="-",[0xBE]=".",
        [0xBF]="/",[0xC0]="`",[0xDB]="[",[0xDC]="\\",[0xDD]="]",[0xDE]="'",
    }
    for k,v in pairs(raw) do KeyNames[k]=v end
    for i=65,90 do KeyNames[i]=string.char(i) end
    for i=1,12  do KeyNames[0x6F+i]="F"..i end
end
local function keyName(kc) return KeyNames[kc] or ("0x"..string.format("%X",kc or 0)) end

-- ── Utilities ────────────────────────────────────────────────
local function clamp(x,a,b) return x<a and a or (x>b and b or x) end
local function textW(str,sz) return #(str or "")*(sz or 13)*0.54 end
local function mpos()
    local lp=game:GetService("Players").LocalPlayer
    if lp then local m=lp:GetMouse(); if m then return Vector2.new(m.X,m.Y) end end
    return Vector2.new(0,0)
end
local function over(pos,size)
    local m=mpos()
    return m.X>=pos.X and m.X<=pos.X+size.X and m.Y>=pos.Y and m.Y<=pos.Y+size.Y
end
local function newDraw(dtype,props)
    local d=Drawing.new(dtype); for k,v in pairs(props) do d[k]=v end; return d
end
local function pointOnRect(t,pos,sz)
    local p=(t%1)*(sz.X*2+sz.Y*2)
    if p<sz.X then return pos+Vector2.new(p,0)
    elseif p<sz.X+sz.Y then return pos+Vector2.new(sz.X,p-sz.X)
    elseif p<sz.X*2+sz.Y then return pos+Vector2.new(sz.X-(p-(sz.X+sz.Y)),sz.Y)
    else return pos+Vector2.new(0,sz.Y-(p-(sz.X*2+sz.Y))) end
end

-- ── HSV helpers ──────────────────────────────────────────────
local function hsvToRgb(h,s,v)
    if s==0 then return Color3.new(v,v,v) end
    local i=math.floor(h*6); local f=h*6-i
    local p,q,r2=v*(1-s),v*(1-f*s),v*(1-(1-f)*s); i=i%6
    if i==0 then return Color3.new(v,r2,p) elseif i==1 then return Color3.new(q,v,p)
    elseif i==2 then return Color3.new(p,v,r2) elseif i==3 then return Color3.new(p,q,v)
    elseif i==4 then return Color3.new(r2,p,v) else return Color3.new(v,p,q) end
end
local function rgbToHsv(c)
    local r,g,b=c.R,c.G,c.B; local mx=math.max(r,g,b); local mn=math.min(r,g,b); local d=mx-mn
    local h=0
    if d~=0 then
        if mx==r then h=((g-b)/d)%6 elseif mx==g then h=(b-r)/d+2 else h=(r-g)/d+4 end; h=h/6
    end
    return h, mx==0 and 0 or d/mx, mx
end

-- ── Drawing Pool ─────────────────────────────────────────────
local function poolNew() return {d={},seen={}} end
local function poolBeginFrame(pool) pool.seen={} end
local function poolAdd(pool,id,dtype,props)
    pool.seen[id]=true
    local e=pool.d[id]
    if e then for k,v in pairs(props) do e[k]=v end; e.Visible=true; return e end
    local obj=newDraw(dtype,props); pool.d[id]=obj; return obj
end
local function poolFlush(pool)
    for id,obj in pairs(pool.d) do if not pool.seen[id] then obj.Visible=false end end
end
local function poolHide(pool,id) local o=pool.d[id]; if o then o.Visible=false end end
local function poolGet(pool,id) return pool.d[id] end
local function poolDestroy(pool)
    for _,o in pairs(pool.d) do o:Remove() end; pool.d={}; pool.seen={}
end

-- ── Input tracker ────────────────────────────────────────────
local Input={_prev={},click=false,held=false,rclick=false}
function Input:update()
    local m1=ismouse1pressed(); local m2=ismouse2pressed()
    self.click=m1 and not(self._prev.m1 or false); self.held=m1
    self.rclick=m2 and not(self._prev.m2 or false)
    self._prev.m1=m1; self._prev.m2=m2
end
function Input:keyClick(kc)
    local cur=iskeypressed(kc); local prv=self._prev[kc] or false
    self._prev[kc]=cur; return cur and not prv
end
function Input:keyHeld(kc) return iskeypressed(kc) end

-- ============================================================
--  CREATE WINDOW
-- ============================================================
function GalaxLib:CreateWindow(opts)
    opts=opts or {}
    local WIN={
        Title=opts.Title or "Galax", Size=opts.Size or Vector2.new(560,420),
        MenuKey=opts.MenuKey or 0x70,
        _pos=Vector2.new(opts.X or 120,opts.Y or 100),
        _open=true, _running=true, _pool=poolNew(), _tabs={}, _openTab=nil,
        _drag=nil, _sliderDrag=nil, _keybindTarget=nil, _textboxTarget=nil,
        _openDropId=nil, -- unique table ref of the open dropdown (Arcane pattern)
        _cpTarget=nil, _settingsListen=false,
        _snakeLines={}, _snakeCount=18,
    }
    for i=1,WIN._snakeCount do
        WIN._snakeLines[i]=newDraw("Line",{Thickness=1.5,Color=T.Accent,Visible=false,ZIndex=50})
    end

    -- ── AddTab ───────────────────────────────────────────────
    function WIN:AddTab(name)
        local TAB={_name=name,_sections={},_win=self}
        function TAB:AddSection(sname)
            local SEC={_name=sname,_widgets={},_win=self._win}
            local function reg(item) table.insert(SEC._widgets,item) end

            function SEC:AddToggle(label,default,cb)
                local item={type="toggle",label=label,value=default or false,cb=cb or function()end}
                reg(item); item.cb(item.value)
                return{Get=function()return item.value end,Set=function(_,v)item.value=v;item.cb(v)end}
            end
            function SEC:AddSlider(label,o,cb)
                o=o or {}
                local item={type="slider",label=label,min=o.Min or 0,max=o.Max or 100,
                    value=o.Default or o.Min or 0,suffix=o.Suffix or "",cb=cb or function()end}
                reg(item); item.cb(item.value)
                return{Get=function()return item.value end,
                    Set=function(_,v)item.value=clamp(v,item.min,item.max);item.cb(item.value)end}
            end
            function SEC:AddButton(label,cb)
                reg({type="button",label=label,cb=cb or function()end}); return{}
            end
            function SEC:AddDropdown(label,options,default,opts2,cb)
                if type(opts2)=="function" then cb=opts2; opts2={} end; opts2=opts2 or {}
                local item={type="dropdown",label=label,options=options or {},
                    value=default or (options and options[1]) or "",
                    maxVisible=opts2.MaxVisible or 5, scroll=0, cb=cb or function()end}
                reg(item); item.cb(item.value)
                return{Get=function()return item.value end,Set=function(_,v)item.value=v;item.cb(v)end}
            end
            function SEC:AddMultiDropdown(label,options,default,opts2,cb)
                if type(opts2)=="function" then cb=opts2; opts2={} end; opts2=opts2 or {}
                local sel={}; if default then for _,v in ipairs(default) do sel[v]=true end end
                local item={type="multidropdown",label=label,options=options or {},
                    selected=sel, maxVisible=opts2.MaxVisible or 5, scroll=0, cb=cb or function()end}
                reg(item)
                local function getList()
                    local out={}
                    for _,o in ipairs(item.options) do if item.selected[o] then out[#out+1]=o end end
                    return out
                end
                item.cb(getList())
                return{
                    Get=function()return getList()end,
                    Set=function(_,tbl)
                        item.selected={}
                        if tbl then for _,v in ipairs(tbl) do item.selected[v]=true end end
                        item.cb(getList())
                    end,
                }
            end
            function SEC:AddColorPicker(label,default,cb)
                local h,s,v=0,1,1; if default then h,s,v=rgbToHsv(default) end
                local item={type="colorpicker",label=label,h=h,s=s,v=v,
                    value=default or Color3.new(1,0,0),cb=cb or function()end,
                    dragSV=false,dragH=false}
                reg(item); item.cb(item.value)
                return{Get=function()return item.value end,
                    Set=function(_,c)item.value=c;local hh,ss,vv=rgbToHsv(c);item.h=hh;item.s=ss;item.v=vv;item.cb(c)end}
            end
            function SEC:AddKeybind(label,default,cb)
                local item={type="keybind",label=label,value=default or 0,cb=cb or function()end,listening=false}
                reg(item)
                return{Get=function()return item.value end,Set=function(_,v)item.value=v;item.cb(v)end}
            end
            function SEC:AddTextbox(label,default,cb)
                local item={type="textbox",label=label,value=default or "",cb=cb or function()end}
                reg(item)
                return{Get=function()return item.value end,Set=function(_,v)item.value=v;item.cb(v)end}
            end
            function SEC:AddLabel(text)
                local item={type="label",label=text or ""}; reg(item)
                return{Get=function()return item.label end,Set=function(_,v)item.label=v end}
            end
            table.insert(TAB._sections,SEC); return SEC
        end
        table.insert(self._tabs,TAB)
        if not self._openTab then self._openTab=TAB end
        return TAB
    end

    -- ── Settings Tab ─────────────────────────────────────────
    function WIN:_buildSettings()
        local STAB={_name="Settings",_sections={},_win=self,_isSettings=true}
        local SMENU={_name="Menu",_widgets={},_win=self}
        table.insert(SMENU._widgets,{type="settings_keybind",label="Toggle Key",listening=false})
        table.insert(SMENU._widgets,{type="settings_kill",label="Kill Script"})
        table.insert(STAB._sections,SMENU)
        local STHEME={_name="Theme",_widgets={},_win=self}
        table.insert(STHEME._widgets,{type="dropdown",label="Change your theme",options=ThemeNames,
            value="Galax",maxVisible=5,scroll=0,cb=function(v)applyTheme(v)end})
        table.insert(STAB._sections,STHEME)
        table.insert(self._tabs,STAB)
    end

    function WIN:Notify(msg,title,dur) notify(msg,title or self.Title,dur or 3) end
    function WIN:Unload() self._running=false end

    -- ── Shared dropdown list renderer ────────────────────────
    -- Returns extra height consumed by the open list.
    -- Scrollbar is draggable (vertical slider).
    -- Options area stops at the scrollbar left edge — no overlap.
    function WIN:_renderDDList(pool,wid,item,ddPos,ddSz,innerW,FONT,isMulti)
        local optH=20; local maxV=item.maxVisible; local total=#item.options
        item.scroll=clamp(item.scroll,0,math.max(0,total-maxV))

        local visCount=math.min(maxV,total)
        local listPos=ddPos+Vector2.new(0,ddSz.Y+2)
        local listH=visCount*optH+4

        local scrW=6; local scrPad=3  -- scrollbar width + gap
        local hasScroll=(total>maxV)
        -- optW: options area stops before scrollbar when scrollbar is visible
        local optW=hasScroll and (innerW-scrW-scrPad*2) or innerW

        poolAdd(pool,wid.."_ddlist", "Square",{Position=listPos,Size=Vector2.new(innerW,listH),Filled=true, Color=T.Surface0,Visible=true,ZIndex=9})
        poolAdd(pool,wid.."_ddlistb","Square",{Position=listPos,Size=Vector2.new(innerW,listH),Filled=false,Color=T.Border1,Thickness=1,Visible=true,ZIndex=10})
        if hasScroll then
            -- ── Draggable scrollbar (vertical slider logic) ───────────
            -- Drag up → scroll up, drag down → scroll down.
            local barH=math.max(16, listH*(maxV/total))
            local trackH=listH-barH
            local maxScroll=math.max(1,total-maxV)
            local barY=listPos.Y + trackH*(item.scroll/maxScroll)
            local barX=listPos.X+innerW-scrW-scrPad
            local barPos=Vector2.new(barX, barY)
            local barSz=Vector2.new(scrW, barH)

            -- Track background (shows full travel area)
            poolAdd(pool,wid.."_ddscrtrk","Square",{
                Position=Vector2.new(barX, listPos.Y),
                Size=Vector2.new(scrW, listH),
                Filled=true, Color=T.Surface1, Visible=true, ZIndex=10})
            -- The draggable bar itself (highlights on hover or drag)
            local scrHov=over(barPos, barSz)
            poolAdd(pool,wid.."_ddscr","Square",{
                Position=barPos, Size=barSz, Filled=true,
                Color=(scrHov or (item._scrDrag or false)) and T.Text or T.Accent,
                Visible=true, ZIndex=11})

            -- Begin drag when clicking the bar
            if item._clicked and scrHov then
                item._scrDrag=true
                item._scrDragStartY=mpos().Y
                item._scrDragStartScroll=item.scroll
            end
            -- Release drag on mouse-up
            if not Input.held then item._scrDrag=false end
            -- While dragging: convert pixel delta → scroll steps (proportional)
            if item._scrDrag and trackH>0 then
                local dy=mpos().Y-(item._scrDragStartY or 0)
                local delta=math.floor(dy*(maxScroll/trackH)+0.5)
                item.scroll=clamp((item._scrDragStartScroll or 0)+delta,0,maxScroll)
            end
        end
        for vi=1,visCount do
            local oi=vi+item.scroll; local opt=item.options[oi]; if not opt then break end
            local opPos=listPos+Vector2.new(0,(vi-1)*optH+2)
            -- opSz uses optW so hit area stops before the scrollbar
            local opSz=Vector2.new(optW,optH); local opHov=over(opPos,opSz)
            if isMulti then
                local opSel=item.selected[opt]==true
                if opHov then poolAdd(pool,wid.."_ddhi_"..vi,"Square",{Position=opPos,Size=opSz,Filled=true,Color=T.Surface1,Visible=true,ZIndex=10})
                else poolHide(pool,wid.."_ddhi_"..vi) end
                local cbPos=opPos+Vector2.new(6,5); local cbSz=Vector2.new(10,10)
                poolAdd(pool,wid.."_mdcb_"..vi,  "Square",{Position=cbPos,Size=cbSz,Filled=true, Color=opSel and T.Accent or T.Surface0,Visible=true,ZIndex=11})
                poolAdd(pool,wid.."_mdcbb_"..vi, "Square",{Position=cbPos,Size=cbSz,Filled=false,Color=T.Border1,Thickness=1,Visible=true,ZIndex=12})
                poolAdd(pool,wid.."_mdot_"..vi,  "Text",  {Position=opPos+Vector2.new(22,3),Text=opt,Size=13,Font=FONT,Color=opSel and T.Accent or T.Text,Outline=false,Visible=true,ZIndex=11})
                -- use item._clicked (per-widget edge detection, set below)
                if item._clicked and opHov then
                    item.selected[opt]=not opSel
                    local out={}; for _,o in ipairs(item.options) do if item.selected[o] then out[#out+1]=o end end
                    item.cb(out)
                end
            else
                local opSel=(opt==item.value)
                if opHov or opSel then
                    poolAdd(pool,wid.."_ddhi_"..vi,"Square",{Position=opPos,Size=opSz,Filled=true,Color=opSel and T.AccentDark or T.Surface1,Visible=true,ZIndex=10})
                else poolHide(pool,wid.."_ddhi_"..vi) end
                poolAdd(pool,wid.."_ddot_"..vi,"Text",{Position=opPos+Vector2.new(8,3),Text=opt,Size=13,Font=FONT,Color=opSel and T.Accent or T.Text,Outline=false,Visible=true,ZIndex=11})
                if item._clicked and opHov then
                    item.value=opt; item.cb(opt); self._openDropId=nil
                end
            end
        end
        for vi=visCount+1,maxV+4 do
            poolHide(pool,wid.."_ddhi_"..vi); poolHide(pool,wid.."_ddot_"..vi)
            poolHide(pool,wid.."_mdcb_"..vi); poolHide(pool,wid.."_mdcbb_"..vi); poolHide(pool,wid.."_mdot_"..vi)
        end
        return listH+4
    end

    -- ── _renderWidget ────────────────────────────────────────
    function WIN:_renderWidget(item,pool,wid,wx,wy,innerW,FONT)
        local wY=0

        if item.type=="label" then
            poolAdd(pool,wid.."_lbl","Text",{Position=Vector2.new(wx,wy+2),Text=item.label,Size=13,Font=FONT,Color=T.SubText,Outline=false,Visible=true,ZIndex=6})
            wY=20

        elseif item.type=="toggle" then
            local bsz=Vector2.new(14,14); local bpos=Vector2.new(wx+innerW-14,wy)
            poolAdd(pool,wid.."_box", "Square",{Position=bpos,Size=bsz,Filled=true, Color=item.value and T.Accent or T.Surface1,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_boxb","Square",{Position=bpos,Size=bsz,Filled=false,Color=T.Border1,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_lbl", "Text",  {Position=Vector2.new(wx,wy+1),Text=item.label,Size=13,Font=FONT,Color=item.value and T.Text or T.SubText,Outline=false,Visible=true,ZIndex=6})
            if Input.click and over(Vector2.new(wx,wy),Vector2.new(innerW,16)) then item.value=not item.value; item.cb(item.value) end
            wY=22

        elseif item.type=="button" then
            local bpos=Vector2.new(wx,wy); local bsz=Vector2.new(innerW,22); local hov=over(bpos,bsz)
            poolAdd(pool,wid.."_btn", "Square",{Position=bpos,Size=bsz,Filled=true, Color=hov and T.AccentDark or T.Surface1,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_btnb","Square",{Position=bpos,Size=bsz,Filled=false,Color=hov and T.Accent or T.Border0,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_btnt","Text",  {Position=bpos+Vector2.new(innerW/2,4),Text=item.label,Size=13,Font=FONT,Color=T.Text,Center=true,Outline=false,Visible=true,ZIndex=7})
            if Input.click and hov then item.cb() end
            wY=28

        elseif item.type=="slider" then
            local valStr=tostring(item.value)..item.suffix
            poolAdd(pool,wid.."_lbl", "Text",  {Position=Vector2.new(wx,wy),Text=item.label,Size=13,Font=FONT,Color=T.Text,Outline=false,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_val", "Text",  {Position=Vector2.new(wx+innerW-textW(valStr,12),wy),Text=valStr,Size=12,Font=FONT,Color=T.Accent,Outline=false,Visible=true,ZIndex=6})
            local trkPos=Vector2.new(wx,wy+17); local trkSz=Vector2.new(innerW,5)
            poolAdd(pool,wid.."_trk", "Square",{Position=trkPos,Size=trkSz,Filled=true,Color=T.Surface1,Visible=true,ZIndex=6})
            local pct=clamp((item.value-item.min)/(item.max-item.min),0,1)
            local fillW=math.max(4,trkSz.X*pct)
            poolAdd(pool,wid.."_fill","Square",{Position=trkPos,Size=Vector2.new(fillW,trkSz.Y),Filled=true,Color=T.Accent,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_knob","Square",{Position=Vector2.new(trkPos.X+fillW-4,trkPos.Y-3),Size=Vector2.new(8,11),Filled=true,Color=T.Text,Visible=true,ZIndex=8})
            if Input.click and over(trkPos-Vector2.new(0,5),trkSz+Vector2.new(0,12)) then self._sliderDrag=item end
            if self._sliderDrag==item then
                if Input.held then
                    local p=clamp((mpos().X-trkPos.X)/trkSz.X,0,1)
                    item.value=clamp(math.floor(item.min+(item.max-item.min)*p+0.5),item.min,item.max); item.cb(item.value)
                else self._sliderDrag=nil end
            end
            wY=34

        elseif item.type=="dropdown" then
            -- ── Arcane-style per-widget click tracking ──────────────
            -- Each dropdown has its own selfId (unique table) and wasM1
            -- so click edge-detection is independent per widget.
            if not item._selfId then item._selfId={}; item._wasM1=false end
            local m1=Input.held
            item._clicked = m1 and not item._wasM1  -- edge: first frame button is down

            local ddPos=Vector2.new(wx,wy+14); local ddSz=Vector2.new(innerW,22)
            local isOpen=(self._openDropId==item._selfId)
            -- List area needed for "clicked outside" detection
            local listH=(math.min(item.maxVisible,#item.options)*20+4)
            local listPos=ddPos+Vector2.new(0,ddSz.Y+2)
            local listSz=Vector2.new(innerW,listH)

            poolAdd(pool,wid.."_ddlbl","Text",   {Position=Vector2.new(wx,wy),Text=item.label,Size=12,Font=FONT,Color=T.SubText,Outline=false,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_ddbg", "Square", {Position=ddPos,Size=ddSz,Filled=true, Color=T.Surface1,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_ddb",  "Square", {Position=ddPos,Size=ddSz,Filled=false,Color=isOpen and T.Accent or T.Border0,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_ddval","Text",   {Position=ddPos+Vector2.new(6,4),Text=item.value,Size=13,Font=FONT,Color=T.Text,Outline=false,Visible=true,ZIndex=7})
            local ax,ay=ddPos.X+ddSz.X-14,ddPos.Y+11
            poolAdd(pool,wid.."_ddarr","Triangle",{PointA=Vector2.new(ax,ay-4),PointB=Vector2.new(ax+7,ay-4),PointC=Vector2.new(ax+3.5,ay+3),Filled=true,Color=isOpen and T.Accent or T.SubText,Visible=true,ZIndex=7})

            if item._clicked then
                if over(ddPos,ddSz) then
                    -- Clicking the header: toggle open/closed (Arcane pattern)
                    if self._openDropId==item._selfId then
                        self._openDropId=nil          -- already open → close
                    elseif self._openDropId==nil then
                        self._openDropId=item._selfId -- nothing open → open
                    end
                elseif isOpen and not over(listPos,listSz) then
                    -- Clicked outside both header and list → close
                    self._openDropId=nil
                end
            end

            -- Re-read isOpen after potential state change this frame
            local isOpenNow=(self._openDropId==item._selfId)
            if isOpenNow then wY=wY+self:_renderDDList(pool,wid,item,ddPos,ddSz,innerW,FONT,false) end
            item._wasM1=m1  -- store for next frame
            wY=wY+42

        elseif item.type=="multidropdown" then
            -- ── Same Arcane-style per-widget click tracking ──────────
            if not item._selfId then item._selfId={}; item._wasM1=false end
            local m1=Input.held
            item._clicked = m1 and not item._wasM1

            local ddPos=Vector2.new(wx,wy+14); local ddSz=Vector2.new(innerW,22)
            local isOpen=(self._openDropId==item._selfId)
            local listH=(math.min(item.maxVisible,#item.options)*20+4)
            local listPos=ddPos+Vector2.new(0,ddSz.Y+2)
            local listSz=Vector2.new(innerW,listH)

            local selList={}
            for _,o in ipairs(item.options) do if item.selected[o] then selList[#selList+1]=o end end
            local dispStr=#selList==0 and "None" or (#selList.."/"..(#item.options).." selected")
            poolAdd(pool,wid.."_ddlbl","Text",   {Position=Vector2.new(wx,wy),Text=item.label,Size=12,Font=FONT,Color=T.SubText,Outline=false,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_ddbg", "Square", {Position=ddPos,Size=ddSz,Filled=true, Color=T.Surface1,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_ddb",  "Square", {Position=ddPos,Size=ddSz,Filled=false,Color=isOpen and T.Accent or T.Border0,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_ddval","Text",   {Position=ddPos+Vector2.new(6,4),Text=dispStr,Size=13,Font=FONT,Color=T.Text,Outline=false,Visible=true,ZIndex=7})
            local ax,ay=ddPos.X+ddSz.X-14,ddPos.Y+11
            poolAdd(pool,wid.."_ddarr","Triangle",{PointA=Vector2.new(ax,ay-4),PointB=Vector2.new(ax+7,ay-4),PointC=Vector2.new(ax+3.5,ay+3),Filled=true,Color=isOpen and T.Accent or T.SubText,Visible=true,ZIndex=7})

            if item._clicked then
                if over(ddPos,ddSz) then
                    -- MultiDropdown: clicking header always toggles (selections persist)
                    if self._openDropId==item._selfId then
                        self._openDropId=nil
                    elseif self._openDropId==nil then
                        self._openDropId=item._selfId
                    end
                elseif isOpen and not over(listPos,listSz) then
                    self._openDropId=nil
                end
            end

            local isOpenNow=(self._openDropId==item._selfId)
            if isOpenNow then wY=wY+self:_renderDDList(pool,wid,item,ddPos,ddSz,innerW,FONT,true) end
            item._wasM1=m1
            wY=wY+42

        elseif item.type=="colorpicker" then
            local swPos=Vector2.new(wx,wy); local swColW=18
            poolAdd(pool,wid.."_sw",  "Square",{Position=swPos,Size=Vector2.new(swColW,18),Filled=true, Color=item.value,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_swb", "Square",{Position=swPos,Size=Vector2.new(swColW,18),Filled=false,Color=T.Border1,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_lbl", "Text",  {Position=swPos+Vector2.new(swColW+6,2),Text=item.label,Size=13,Font=FONT,Color=T.Text,Outline=false,Visible=true,ZIndex=6})
            if Input.click and over(swPos,Vector2.new(innerW,18)) then
                self._cpTarget=self._cpTarget==item and nil or item
            end
            wY=24
            if self._cpTarget==item then
                local palW,palH=innerW,80; local palPos=Vector2.new(wx,wy+24)
                local strips=14
                for si=1,strips do
                    local vv=1-(si-1)/(strips-1)
                    poolAdd(pool,wid.."_sv_"..si,"Square",{
                        Position=palPos+Vector2.new(0,(si-1)*(palH/strips)),
                        Size=Vector2.new(palW,palH/strips+1),
                        Filled=true,Color=hsvToRgb(item.h,item.s,vv),Visible=true,ZIndex=7})
                end
                local cX=palPos.X+item.s*palW; local cY=palPos.Y+(1-item.v)*palH
                poolAdd(pool,wid.."_svch_h","Line",{From=Vector2.new(palPos.X,cY),To=Vector2.new(palPos.X+palW,cY),Thickness=1,Color=T.Text,Visible=true,ZIndex=9})
                poolAdd(pool,wid.."_svch_v","Line",{From=Vector2.new(cX,palPos.Y),To=Vector2.new(cX,palPos.Y+palH),Thickness=1,Color=T.Text,Visible=true,ZIndex=9})
                local hueH=10; local huePos=Vector2.new(wx,wy+24+palH+4); local hSegs=20
                for hi=1,hSegs do
                    poolAdd(pool,wid.."_h_"..hi,"Square",{
                        Position=huePos+Vector2.new((hi-1)*(innerW/hSegs),0),
                        Size=Vector2.new(innerW/hSegs+1,hueH),
                        Filled=true,Color=hsvToRgb((hi-1)/hSegs,1,1),Visible=true,ZIndex=7})
                end
                local hcX=huePos.X+item.h*innerW
                poolAdd(pool,wid.."_hcur","Square",{Position=Vector2.new(hcX-2,huePos.Y-1),Size=Vector2.new(4,hueH+2),Filled=false,Color=T.Text,Thickness=1,Visible=true,ZIndex=9})
                poolAdd(pool,wid.."_palb","Square",{Position=palPos,Size=Vector2.new(palW,palH),Filled=false,Color=T.Border1,Thickness=1,Visible=true,ZIndex=10})
                if Input.click and over(palPos,Vector2.new(palW,palH)) then item.dragSV=true end
                if Input.click and over(huePos,Vector2.new(innerW,hueH)) then item.dragH=true end
                if not Input.held then item.dragSV=false; item.dragH=false end
                if item.dragSV then
                    local m=mpos(); item.s=clamp((m.X-palPos.X)/palW,0,1); item.v=1-clamp((m.Y-palPos.Y)/palH,0,1)
                    item.value=hsvToRgb(item.h,item.s,item.v); item.cb(item.value)
                end
                if item.dragH then
                    item.h=clamp((mpos().X-huePos.X)/innerW,0,1)
                    item.value=hsvToRgb(item.h,item.s,item.v); item.cb(item.value)
                end
                wY=wY+palH+hueH+10
            end

        elseif item.type=="keybind" then
            local kbStr=item.listening and "[ ... ]" or ("[ "..keyName(item.value).." ]")
            local kbW=textW(kbStr,12)+10; local kbPos=Vector2.new(wx+innerW-kbW,wy); local kbSz=Vector2.new(kbW,18)
            poolAdd(pool,wid.."_lbl",  "Text",  {Position=Vector2.new(wx,wy+2),Text=item.label,Size=13,Font=FONT,Color=T.Text,Outline=false,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_kbbg", "Square",{Position=kbPos,Size=kbSz,Filled=true, Color=item.listening and T.AccentDark or T.Surface1,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_kbb",  "Square",{Position=kbPos,Size=kbSz,Filled=false,Color=item.listening and T.Accent or T.Border0,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_kbtxt","Text",  {Position=kbPos+Vector2.new(4,2),Text=kbStr,Size=12,Font=FONT,Color=item.listening and T.Accent or T.SubText,Outline=false,Visible=true,ZIndex=7})
            if Input.click and over(kbPos,kbSz) then item.listening=true; self._keybindTarget=item end
            if item.listening and self._keybindTarget==item then
                for kc=1,255 do
                    if kc~=0x01 and kc~=0x02 and Input:keyClick(kc) then
                        if kc~=0x1B then item.value=kc; item.cb(kc) end
                        item.listening=false; self._keybindTarget=nil; break
                    end
                end
            end
            wY=24

        elseif item.type=="textbox" then
            local tbPos=Vector2.new(wx,wy+15); local tbSz=Vector2.new(innerW,22)
            local focused=(self._textboxTarget==item)
            local cursor=(focused and(math.floor(tick()*2)%2==0)) and "|" or ""
            local display=item.value..cursor
            if display=="" then display=focused and cursor or item.label end
            poolAdd(pool,wid.."_lbl",  "Text",  {Position=Vector2.new(wx,wy),Text=item.label,Size=12,Font=FONT,Color=T.SubText,Outline=false,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_tbbg", "Square",{Position=tbPos,Size=tbSz,Filled=true, Color=T.Surface1,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_tbb",  "Square",{Position=tbPos,Size=tbSz,Filled=false,Color=focused and T.Accent or T.Border0,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_tbtxt","Text",  {Position=tbPos+Vector2.new(6,4),Text=display,Size=13,Font=FONT,Color=(item.value~="" or focused) and T.Text or T.SubText,Outline=false,Visible=true,ZIndex=7})
            if Input.click then
                if over(tbPos,tbSz) then self._textboxTarget=item
                elseif self._textboxTarget==item then self._textboxTarget=nil end
            end
            if focused then
                for kc=8,122 do
                    if Input:keyClick(kc) then
                        if kc==0x08 then item.value=item.value:sub(1,-2); item.cb(item.value)
                        elseif kc==0x0D then self._textboxTarget=nil
                        elseif kc==0x20 then item.value=item.value.." "; item.cb(item.value)
                        elseif kc>=0x30 and kc<=0x5A then
                            local ch=KeyNames[kc]; if ch and #ch==1 then
                                local sh=Input:keyHeld(0x10) or Input:keyHeld(0xA0) or Input:keyHeld(0xA1)
                                item.value=item.value..(sh and ch:upper() or ch:lower()); item.cb(item.value)
                            end
                        end
                    end
                end
            end
            wY=44

        elseif item.type=="settings_keybind" then
            local kbStr=item.listening and "[ ... ]" or ("[ "..keyName(self.MenuKey).." ]")
            local kbW=textW(kbStr,12)+10; local kbPos=Vector2.new(wx+innerW-kbW,wy); local kbSz=Vector2.new(kbW,18)
            poolAdd(pool,wid.."_lbl",  "Text",  {Position=Vector2.new(wx,wy+2),Text=item.label,Size=13,Font=FONT,Color=T.Text,Outline=false,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_kbbg", "Square",{Position=kbPos,Size=kbSz,Filled=true, Color=item.listening and T.AccentDark or T.Surface1,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_kbb",  "Square",{Position=kbPos,Size=kbSz,Filled=false,Color=item.listening and T.Accent or T.Border0,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_kbtxt","Text",  {Position=kbPos+Vector2.new(4,2),Text=kbStr,Size=12,Font=FONT,Color=item.listening and T.Accent or T.SubText,Outline=false,Visible=true,ZIndex=7})
            if Input.click and over(kbPos,kbSz) then item.listening=true; self._settingsListen=true end
            if item.listening and self._settingsListen then
                for kc=1,255 do
                    if kc~=0x01 and kc~=0x02 and Input:keyClick(kc) then
                        if kc~=0x1B then self.MenuKey=kc; self:Notify("Key: "..keyName(kc),self.Title,3) end
                        item.listening=false; self._settingsListen=false; break
                    end
                end
            end
            wY=24

        elseif item.type=="settings_kill" then
            local bpos=Vector2.new(wx,wy); local bsz=Vector2.new(innerW,22); local hov=over(bpos,bsz)
            poolAdd(pool,wid.."_btn", "Square",{Position=bpos,Size=bsz,Filled=true, Color=hov and T.RedDark or T.Surface1,Visible=true,ZIndex=6})
            poolAdd(pool,wid.."_btnb","Square",{Position=bpos,Size=bsz,Filled=false,Color=hov and T.Red or T.Border0,Thickness=1,Visible=true,ZIndex=7})
            poolAdd(pool,wid.."_btnt","Text",  {Position=bpos+Vector2.new(innerW/2,4),Text=item.label,Size=13,Font=FONT,Color=T.Red,Center=true,Outline=false,Visible=true,ZIndex=7})
            if Input.click and hov then self:Notify("Script killed.",self.Title,2); self._running=false end
            wY=28
        end
        return wY
    end

    -- ── _render ──────────────────────────────────────────────
    function WIN:_render()
        local pool=self._pool; local pos=self._pos; local sz=self.Size
        local t=tick(); local FONT=Drawing.Fonts.UI
        if not self._open then
            poolDestroy(pool)
            for i=1,self._snakeCount do self._snakeLines[i].Visible=false end; return
        end
        poolBeginFrame(pool)
        if Input.click and over(pos,Vector2.new(sz.X,38)) and not self._drag then self._drag=mpos()-pos end
        if not Input.held then self._drag=nil end
        if self._drag then self._pos=mpos()-self._drag; pos=self._pos end
        poolAdd(pool,"win_bg","Square",{Position=pos,Size=sz,Filled=true, Color=T.Body,   Visible=true,ZIndex=1})
        poolAdd(pool,"win_b", "Square",{Position=pos,Size=sz,Filled=false,Color=T.Border0,Thickness=1,Visible=true,ZIndex=2})
        local topH=38
        poolAdd(pool,"top_bg",   "Square",{Position=pos,Size=Vector2.new(sz.X,topH),Filled=true,Color=T.Surface0,Visible=true,ZIndex=2})
        poolAdd(pool,"top_line", "Square",{Position=pos+Vector2.new(0,topH),Size=Vector2.new(sz.X,2),Filled=true,Color=T.Accent,Visible=true,ZIndex=3})
        poolAdd(pool,"top_title","Text",  {Position=pos+Vector2.new(12,11),Text=self.Title,Size=16,Font=FONT,Color=T.Accent,Outline=true,Visible=true,ZIndex=3})
        local wmStr=self.Title.."  |  "..keyName(self.MenuKey).." to toggle"
        poolAdd(pool,"wm_bg", "Square",{Position=pos-Vector2.new(0,21),Size=Vector2.new(textW(wmStr,12)+14,18),Filled=true,Color=T.Surface0,Visible=true,ZIndex=1})
        poolAdd(pool,"wm_txt","Text",  {Position=pos-Vector2.new(-5,17),Text=wmStr,Size=12,Font=FONT,Color=T.SubText,Outline=false,Visible=true,ZIndex=2})
        local snkPos=pos+Vector2.new(0,topH+2); local snkSz=sz-Vector2.new(0,topH+2)
        for i=1,self._snakeCount do
            local ti=t*0.175-i*0.004; local sl=self._snakeLines[i]
            sl.From=pointOnRect(ti,snkPos,snkSz); sl.To=pointOnRect(ti+0.004,snkPos,snkSz)
            sl.Color=Color3.fromHSV((t*0.12+i*0.05)%1,0.75,1); sl.Transparency=(1-i/self._snakeCount)*0.78
            sl.Visible=true; sl.ZIndex=50
        end
        local tabY=topH+4; local tabH=26; local tabX=10
        for i,tab in ipairs(self._tabs) do
            local tw=textW(tab._name,13)+24; local tpos=pos+Vector2.new(tabX,tabY); local tsz=Vector2.new(tw,tabH)
            local open=(self._openTab==tab)
            poolAdd(pool,"tab_bg_"..i, "Square",{Position=tpos,Size=tsz,Filled=true,Color=open and T.Surface1 or T.Surface0,Visible=true,ZIndex=3})
            poolAdd(pool,"tab_txt_"..i,"Text",  {Position=tpos+Vector2.new(tw/2,tabH/2-6),Text=tab._name,Size=13,Font=FONT,Color=open and T.Text or T.SubText,Center=true,Outline=false,Visible=true,ZIndex=4})
            if open then poolAdd(pool,"tab_ul_"..i,"Square",{Position=tpos+Vector2.new(0,tabH-2),Size=Vector2.new(tw,2),Filled=true,Color=T.Accent,Visible=true,ZIndex=4})
            else poolHide(pool,"tab_ul_"..i) end
            if Input.click and over(tpos,tsz) then
                self._openTab=tab; self._openDropId=nil; self._textboxTarget=nil; self._cpTarget=nil
            end
            tabX=tabX+tw+5
        end
        if not self._openTab then poolFlush(pool); return end
        local contTop=topH+tabH+10; local padX=10
        local colW=(sz.X-padX*3)/2; local colYL=contTop; local colYR=contTop
        for si,sec in ipairs(self._openTab._sections) do
            local isLeft=(si%2==1)
            local sx=isLeft and padX or (padX*2+colW)
            local sy=isLeft and colYL or colYR; local sid="s"..si
            poolAdd(pool,sid.."_hdr","Text",{Position=pos+Vector2.new(sx+6,sy+4),Text=sec._name,Size=11,Font=FONT,Color=T.SubText,Outline=false,Visible=true,ZIndex=6})
            local wY=sy+20; local innerX=pos.X+sx+8; local innerW=colW-16
            for wi,item in ipairs(sec._widgets) do
                local consumed=self:_renderWidget(item,pool,sid.."_w"..wi,innerX,pos.Y+wY,innerW,FONT)
                wY=wY+consumed+6
            end
            local secH=wY-sy+8
            poolAdd(pool,sid.."_bg", "Square",{Position=pos+Vector2.new(sx,sy),Size=Vector2.new(colW,secH),Filled=true, Color=T.Surface0,Visible=true,ZIndex=4})
            poolAdd(pool,sid.."_bgb","Square",{Position=pos+Vector2.new(sx,sy),Size=Vector2.new(colW,secH),Filled=false,Color=T.Border0,Thickness=1,Visible=true,ZIndex=5})
            local hdr=poolGet(pool,sid.."_hdr"); if hdr then hdr.ZIndex=6 end
            if isLeft then colYL=colYL+secH+12 else colYR=colYR+secH+12 end
        end
        poolFlush(pool)
    end

    -- ── Main loop ────────────────────────────────────────────
    task.spawn(function()
        WIN:_buildSettings()
        while WIN._running do
            task.wait()
            if not isrbxactive() then continue end
            Input:update()
            if Input:keyClick(WIN.MenuKey) then
                WIN._open=not WIN._open; setrobloxinput(not WIN._open)
                if not WIN._open then
                    WIN._openDropId=nil; WIN._textboxTarget=nil
                    WIN._keybindTarget=nil; WIN._settingsListen=false; WIN._cpTarget=nil
                end
            end
            WIN:_render()
        end
        setrobloxinput(true); poolDestroy(WIN._pool)
        for i=1,WIN._snakeCount do WIN._snakeLines[i]:Remove() end
    end)

    return WIN
end

return GalaxLib
