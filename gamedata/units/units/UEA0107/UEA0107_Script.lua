local explosion = import('/lua/defaultexplosions.lua')
local util = import('/lua/utilities.lua')

local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local LOUDFLOOR = math.floor
local LOUDGETN = table.getn
local LOUDINSERT = table.insert

UEA0107 = Class(TAirUnit) 
{
    AirDestructionEffectBones = { 'Front_Right_Exhaust','Front_Left_Exhaust','Back_Right_Exhaust','Back_Left_Exhaust',
                                'Left_Front_Leg','Right_Front_Leg','Left_Back_Leg','Right_Back_Leg'},

    BeamExhaustCruise = '/effects/emitters/transport_thruster_beam_01_emit.bp',
    BeamExhaustIdle = '/effects/emitters/transport_thruster_beam_02_emit.bp',

    DestructionTicks = 250,
    EngineRotateBones = {'Front_Right_Engine', 'Front_Left_Engine', 'Back_Left_Engine', 'Back_Right_Engine', },

    PlayDestructionEffects = true,
    DamageEffectPullback = 0.25,
    DestroySeconds = 7.5,

    OnStopBeingBuilt = function(self,builder,layer)
	
        TAirUnit.OnStopBeingBuilt(self,builder,layer)
        self.EngineManipulators = {}

        -- create the engine thrust manipulators
        for _, v in self.EngineRotateBones do
		
            LOUDINSERT(self.EngineManipulators, CreateThrustController(self, "thruster", v))
			
        end

        -- set up the thursting arcs for the engines
        for _,values in self.EngineManipulators do
		
            #                      XMAX,XMIN,YMAX,YMIN,ZMAX,ZMIN, TURNMULT, TURNSPEED
            values:SetThrustingParam( -0.25, 0.25, -0.75, 0.75, -0.0, 0.0, 1.0, 0.25 )
			
        end

        self.LandingAnimManip = CreateAnimator(self)
        self.LandingAnimManip:SetPrecedence(0)
		
        self.Trash:Add(self.LandingAnimManip)
		
        self.LandingAnimManip:PlayAnim(self:GetBlueprint().Display.AnimationLand):SetRate(1)
		
        self:ForkThread(self.ExpandThread)
		
    end,


    -- When one of our attached units gets killed, detach it
    OnAttachedKilled = function(self, attached)
	
        attached:DetachFrom()
		
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
	
        TAirUnit.OnKilled(self, instigator, type, overkillRatio)

        self:TransportDetachAllUnits(true)
		
    end,

    OnMotionVertEventChange = function(self, new, old)
	
        TAirUnit.OnMotionVertEventChange(self, new, old)
		
        if (new == 'Down') then
		
            self.LandingAnimManip:SetRate(-1)
			
        elseif (new == 'Up') then
		
            self.LandingAnimManip:SetRate(1)
			
        end
		
    end,

    -- Override air destruction effects so we can do something custom here
    CreateUnitAirDestructionEffects = function( self, scale )
	
        self:ForkThread(self.AirDestructionEffectsThread, self )
		
    end,

    AirDestructionEffectsThread = function( self )
	
        local numExplosions = LOUDFLOOR( LOUDGETN( self.AirDestructionEffectBones ) * 0.5 )
		
        for i = 0, numExplosions do
		
            explosion.CreateDefaultHitExplosionAtBone( self, self.AirDestructionEffectBones[util.GetRandomInt( 1, numExplosions )], 0.5 )
            WaitSeconds( util.GetRandomFloat( 0.2, 0.9 ))
			
        end
		
    end,

    OnCreate = function(self)
	
        TAirUnit.OnCreate(self)
		
        self.Sliders = {}
        self.Sliders[1] = CreateSlider(self, 'Tail')
        self.Sliders[1]:SetGoal(0, 0, 15)
        self.Sliders[2] = CreateSlider(self, 'Head')
        self.Sliders[2]:SetGoal(0, 0, -15)
		
        for k, v in self.Sliders do
		
            v:SetSpeed(-1)
			
            self.Trash:Add(v)
			
        end
		
    end,
    
    ExpandThread = function(self)
	
        if self.Sliders then
		
            for _, v in self.Sliders do
                v:SetGoal(0, 0, 0)
                v:SetSpeed(10)
            end
			
            WaitFor(self.Sliders[2])
			
            for _, v in self.Sliders do
                v:Destroy()
            end
			
        end
		
    end,
    
    GetUnitSizes = function(self)
	
        local bp = self:GetBlueprint()
		
        if self:GetFractionComplete() < 1.0 then
		
            return bp.SizeX, bp.SizeY, bp.SizeZ * 0.5
			
        else
		
            return bp.SizeX, bp.SizeY, bp.SizeZ
			
        end
		
    end,     

}

TypeClass = UEA0107