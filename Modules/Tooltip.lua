local DF = LibStub('AceAddon-3.0'):GetAddon('DragonflightUI')
local mName = 'Tooltip'
local Module = DF:NewModule(mName, 'AceConsole-3.0')

local db, getOptions

local defaults = {profile = {scale = 1, dX = 42, dY = 35, sizeX = 460, sizeY = 207, cursorAnchor = true}}

local function getDefaultStr(key)
    return ' (Default: ' .. tostring(defaults.profile[key]) .. ')'
end

local function setDefaultValues()
    for k, v in pairs(defaults.profile) do Module.db.profile[k] = v end
    Module.ApplySettings()
end

-- db[info[#info] = VALUE
local function getOption(info)
    return db[info[#info]]
end

local function setOption(info, value)
    local key = info[1]
    Module.db.profile[key] = value
    Module.ApplySettings()
end

local options = {
    type = 'group',
    name = 'DragonflightUI - ' .. mName,
    get = getOption,
    set = setOption,
    args = {
        toggle = {
            type = 'toggle',
            name = 'Enable',
            get = function()
                return DF:GetModuleEnabled(mName)
            end,
            set = function(info, v)
                DF:SetModuleEnabled(mName, v)
            end,
            order = 1
        },
        reload = {
            type = 'execute',
            name = '/reload',
            desc = 'reloads UI',
            func = function()
                ReloadUI()
            end,
            order = 1.1
        },
        defaults = {
            type = 'execute',
            name = 'Defaults',
            desc = 'Sets Config to default values',
            func = setDefaultValues,
            order = 1.1
        },
        config = {type = 'header', name = 'Config - Tooltip', order = 100},
        scale = {
            type = 'range',
            name = 'Scale',
            desc = '' .. getDefaultStr('scale'),
            min = 0.2,
            max = 1.5,
            bigStep = 0.025,
            order = 101,
            disabled = true
        },
        x = {
            type = 'range',
            name = 'X',
            desc = 'X relative to BOTTOM CENTER' .. getDefaultStr('x'),
            min = -2500,
            max = 2500,
            bigStep = 0.50,
            order = 102,
            disabled = true
        },
        y = {
            type = 'range',
            name = 'Y',
            desc = 'Y relative to BOTTOM CENTER' .. getDefaultStr('y'),
            min = -2500,
            max = 2500,
            bigStep = 0.50,
            order = 102,
            disabled = true
        },
        cursorAnchor = {
            type = 'toggle',
            name = 'Anchor @Cursor',
            desc = 'Anchors the Tooltip at the Cursor' .. getDefaultStr('cursorAnchor'),
            order = 105.1
        }
    }
}

function Module:OnInitialize()
    DF:Debug(self, 'Module ' .. mName .. ' OnInitialize()')
    self.db = DF.db:RegisterNamespace(mName, defaults)
    db = self.db.profile

    self:SetEnabledState(DF:GetModuleEnabled(mName))
    DF:RegisterModuleOptions(mName, options)
end

function Module:OnEnable()
    DF:Debug(self, 'Module ' .. mName .. ' OnEnable()')
    if DF.Wrath then
        Module.Wrath()
    else
        Module.Era()
    end
end

function Module:OnDisable()
end

function Module:ApplySettings()
    db = Module.db.profile
end

function Module:HookAnchor()
    hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip, parent)
        print(tooltip:GetName(), parent:GetName())
        -- print('GameTooltip_SetDefaultAnchor')
        -- print("The mouse is over " .. GetMouseFocus():GetName())

        local db = Module.db.profile
        tooltip:ClearAllPoints()

        if db.cursorAnchor then
            if GetMouseFocus() == WorldFrame then
                print('Worldframe')
                tooltip:SetOwner(parent, 'ANCHOR_CURSOR_RIGHT', 24, 5)
            else
                print('else')
                tooltip:SetOwner(parent, "ANCHOR_NONE")
                tooltip:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -95, 110)
            end

        else
            tooltip:SetOwner(parent, "ANCHOR_NONE")
            tooltip:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -95, 110)

        end
    end)
end

local frame = CreateFrame('FRAME', 'DragonflightUITooltipFrame', UIParent)

function frame:OnEvent(event, arg1)
    -- print('event', event)
    if event == 'PLAYER_ENTERING_WORLD' then end
    if event == 'PLAYER_LOGIN' then end
end
frame:SetScript('OnEvent', frame.OnEvent)

function Module.Wrath()
    frame:RegisterEvent('PLAYER_ENTERING_WORLD')
    frame:RegisterEvent('PLAYER_LOGIN')

    Module.HookAnchor()
end

function Module.Era()
    Module.Wrath()
end
