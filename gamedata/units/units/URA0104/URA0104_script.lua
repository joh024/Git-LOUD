local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local CreateDefaultHitExplosionAtBone = import('/lua/defaultexplosions.lua').CreateDefaultHitExplosionAtBone

local util = import('/lua/utilities.lua')

local cWeapons = import('/lua/cybranweapons.lua')
local CAAAutocannon = cWeapons.CAAAutocannon
local CEMPAutoCannon = cWeapons.CEMPAutoCannon

URA0104 = Class(CAirUnit) {

    Weapons = {
        AAAutocannon = Class(CAAAutocannon) {},
        EMPCannon = Class(CEMPAutoCannon) {},
    },

    AirDestructionEffectBones = { 'Left_Exhaust', 'Right_Exhaust', 'Char04', 'Char03', 'Char02', 'Char01',
                                  'Front_Left_Leg03_B02', 'Front_Right_Leg03_B02',
                                  'Right_AttachPoint01', 'Right_AttachPoint02',
                                  'Left_AttachPoint01', 'Left_AttachPoint02', },

    BeamExhaustIdle = '/effects/emitters/missile_exhaust_fire_beam_05_emit.bp',
    BeamExhaustCruise = '/effects/emitters/missile_exhaust_fire_beam_04_emit.bp',
    
    OnCreate = function( self )
	
        CAirUnit.OnCreate(self)
		
        if not self.OpenAnim then
		
            self.OpenAnim = CreateAnimator(self)
            self.OpenAnim:PlayAnim(self:GetBlueprint().Display.AnimationOpen, false):SetRate(0)
            self.Trash:Add(self.OpenAnim)
			
        end
		
    end,

    OnStopBeingBuilt = function(self,builder,layer)
	
        CAirUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.AnimManip = CreateAnimator(self)
		
        self.Trash:Add(self.AnimManip)
		
        self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationTakeOff, false):SetRate(1)
		
        if not self.OpenAnim then
		
            self.OpenAnim = CreateAnimator(self)
            self.Trash:Add(self.OpenAnim)
			
        end
		
        self.OpenAnim:PlayAnim(self:GetBlueprint().Display.AnimationOpen, false):SetRate(1)
		
    end,

    -- When one of our attached units gets killed, detach it
    OnAttachedKilled = function(self, attached)
	
        attached:DetachFrom()
		
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
	
        CAirUnit.OnKilled(self, instigator, type, overkillRatio)
		
        -- TransportDetachAllUnits takes 1 bool parameter. If true, randomly destroys some of the transported
        -- units, otherwise successfully detaches all.
        self:TransportDetachAllUnits(true)
		
    end,

    OnMotionVertEventChange = function(self, new, old)
	
        CAirUnit.OnMotionVertEventChange(self, new, old)
		
        --Aborting a landing
        if ((new == 'Top' or new == 'Up') and old == 'Down') then
		
            self.AnimManip:SetRate(-1)
			
        elseif (new == 'Down') then
		
            self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationLand, false):SetRate(1.5)
			
        elseif (new == 'Up') then
		
            self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationTakeOff, false):SetRate(1)
			
        end
		
    end,

    -- Override air destruction effects so we can do something custom here
    CreateUnitAirDestructionEffects = function( self, scale )
	
        self:ForkThread(self.AirDestructionEffectsThread, self )
		
    end,

    AirDestructionEffectsThread = function( self )
	
        local numExplosions = math.floor( table.getn( self.AirDestructionEffectBones ) * 0.5 )
		
        for i = 0, numExplosions do
		
            CreateDefaultHitExplosionAtBone( self, self.AirDestructionEffectBones[util.GetRandomInt( 1, numExplosions )], 0.5 )
            WaitSeconds( util.GetRandomFloat( 0.2, 0.9 ))
			
        end
		
    end,
	
}

TypeClass = URA0104

