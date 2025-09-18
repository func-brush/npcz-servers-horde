if not ArcCWInstalled then return end
if CLIENT then
    SWEP.WepSelectIcon = surface.GetTextureID("arccw/weaponicons/arccw_go_mp9")
    killicon.Add("arccw_horde_mp9m", "arccw/weaponicons/arccw_go_mp9", Color(0, 0, 0, 255))
end

SWEP.Base = "arccw_go_mp9"

SWEP.Spawnable = true
SWEP.Category = "ArcCW - Horde"
SWEP.AdminOnly = false

SWEP.PrintName = "Medic MP9N"

SWEP.ViewModel = "models/weapons/arccw_go/v_smg_mp9.mdl"
SWEP.WorldModel = "models/weapons/arccw_go/v_smg_mp9.mdl"

SWEP.RecoilPunch = 0

SWEP.Firemodes = {
    {
        Mode = 2,
    }
}

SWEP.Delay = 60 / 900

SWEP.FirstShootSound = "ArcCW_Horde.GSO.MP9_Fire"
SWEP.ShootSound = "ArcCW_Horde.GSO.MP9_Fire"
SWEP.ShootSoundSilenced = "ArcCW_Horde.GSO.MP9_Fire_Sil"
SWEP.DistantShootSound = ""

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

sound.Add( {
    name = "ArcCW_Horde.GSO.MP9_Fire",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 90,
    pitch = 100,
    sound = {")arccw_go/mp9/mp9_01.wav",")arccw_go/mp9/mp9_02.wav",")arccw_go/mp9/mp9_03.wav",")arccw_go/mp9/mp9_04.wav"}
} )
sound.Add( {
    name = "ArcCW_Horde.GSO.MP9_Fire_Sil",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 75,
    pitch = 100,
    sound = ")arccw_go/mp5/mp5_01.wav"
} )

function SWEP:ChangeFiremode(pred)
    if self:GetNextSecondaryFire() > CurTime() then return end
    if not self.CanBash and not self:GetBuff_Override("Override_CanBash") then return end
    if CLIENT then return end
    local ply = self:GetOwner()
    local filter = {self:GetOwner()}
    local tr = util.TraceHull({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 5000,
        filter = filter,
        mins = Vector(-16, -16, -8),
        maxs = Vector(16, 16, 8),
        mask = MASK_SHOT_HULL
    })
    if tr.Hit then
        local effectdata = EffectData()
        effectdata:SetOrigin(tr.HitPos)
        effectdata:SetRadius(50)
        util.Effect("horde_heal_mist", effectdata)

        for _, ent in pairs(ents.FindInSphere(tr.HitPos, 100)) do
            if ent:IsPlayer() then
                local healinfo = HealInfo:New({amount = 10, healer = ply})
                HORDE:OnPlayerHeal(ent, healinfo)
            elseif ent:GetClass() == "npc_vj_horde_antlion" then
                local healinfo = HealInfo:New({amount = 10, healer = ply})
                HORDE:OnAntlionHeal(ent, healinfo)
            elseif ent:IsNPC() then
                local dmg = DamageInfo()
                dmg:SetDamage(25)
                dmg:SetDamageType(DMG_NERVEGAS)
                dmg:SetAttacker(ply)
                dmg:SetInflictor(self)
                dmg:SetDamagePosition(tr.HitPos)
                ent:TakeDamageInfo(dmg)
            end
        end
    end

    ply:EmitSound("horde/weapons/mp7m/heal.ogg", 75, 100, 1, CHAN_WEAPON)

    self:SetNextSecondaryFire(CurTime() + 1)
    self:SetNextPrimaryFire(CurTime() + 0.25)
    return true
end

function SWEP:Hook_Think()
    if SERVER then return end
    local tr = util.TraceHull({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 5000,
        filter = filter,
        mins = Vector(-20, -20, -8),
        maxs = Vector(20, 20, 8),
        mask = MASK_SHOT_HULL
    })

    if tr.Hit and tr.Entity and tr.Entity:IsPlayer() then
        self.Horde_HealTarget = tr.Entity
    else
        self.Horde_HealTarget = nil
    end
end

local function nv_center(ent)
    return ent:LocalToWorld(ent:OBBCenter())
end

function SWEP:Hook_DrawHUD()
    if self.Horde_HealTarget then
        local pos = nv_center(self.Horde_HealTarget):ToScreen()
        surface.SetDrawColor(Color(50, 200, 50))
        surface.DrawCircle(pos.x, pos.y, 30)
        draw.DrawText(self.Horde_HealTarget:Health(), "Trebuchet24",
        pos.x - 15, pos.y - 15, Color(50, 200, 50), TEXT_ALIGN_LEFT)
    end
end
