local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")

local WHITE = "|cffFFFFFF"

function SPM:GetPresetName(index)
    return MysticEnchantManagerUtil.GetPresetName(index)
end

function SPM:GetPresetIcon(index)
    return MysticEnchantManagerUtil.GetPresetIcon(index)
end

--returns current active spec
function SPM:GetSpecId()
    return SpecializationUtil.GetActiveSpecialization()
end

--returns current active enchant preset 
function SPM:GetPresetId()
    return MysticEnchantManagerUtil.GetActivePreset()
end

function SPM:GetSpecInfo(i)
    return SpecializationUtil.GetSpecializationInfo(i)
end

function SPM:SpellCheck(num,type)
    if num == self:GetSpecId() and type == "spec" or num == self:GetPresetId() and type == "enchant" then return true end
end

--loads the table of specs by checking if you know the spell for the spec that is associated with it
function SPM:PopulateSpecDB()
    for i,v in ipairs(self.SpecInfo) do
        if CA_IsSpellKnown(v) and not self.db.Specs[i] then
            self.db.Specs[i] = { 1, 1}
        end
    end
end

--for a adding a divider to dew drop menus 
function SPM:AddDividerLine(maxLenght)
    local text = WHITE.."----------------------------------------------------------------------------------------------------"
    self.dewdrop:AddLine(
        'text' , text:sub(1, maxLenght),
        'textHeight', self.db.txtSize,
        'textWidth', self.db.txtSize,
        'isTitle', true,
        "notCheckable", true
    )
    return true
end