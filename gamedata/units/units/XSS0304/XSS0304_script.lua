local SSubUnit =  import('/lua/defaultunits.lua').SubUnit

local SANUallCavitationTorpedo = import('/lua/seraphimweapons.lua').SANUallCavitationTorpedo
local SDFAjelluAntiTorpedoDefense = import('/lua/seraphimweapons.lua').SDFAjelluAntiTorpedoDefense
local SAALosaareAutoCannonWeapon = import('/lua/seraphimweapons.lua').SAALosaareAutoCannonWeaponSeaUnit

XSS0304 = Class(SSubUnit) {

    Weapons = {
	
        Torpedo = Class(SANUallCavitationTorpedo) {},
		
        AntiTorpedo = Class(SDFAjelluAntiTorpedoDefense) {},

        AutoCannon = Class(SAALosaareAutoCannonWeapon) {},
		
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        SSubUnit.OnStopBeingBuilt(self,builder,layer)
		
        if layer == 'Water' then
		
            ChangeState( self, self.OpenState )
			
        else
		
            ChangeState( self, self.ClosedState )
			
        end
		
    end,

    OnLayerChange = function( self, new, old )
	
        SSubUnit.OnLayerChange(self, new, old)
		
        if new == 'Water' then
		
            ChangeState( self, self.OpenState )
			
        elseif new == 'Sub' then
		
            ChangeState( self, self.ClosedState )
			
        end
		
    end,
    
    OpenState = State() {
	
        Main = function(self)
		
            if not self.CannonAnim then
                self.CannonAnim = CreateAnimator(self)
                self.Trash:Add(self.CannonAnim)
            end
			
            local bp = self:GetBlueprint()
			
            self.CannonAnim:PlayAnim(bp.Display.CannonOpenAnimation)
            self.CannonAnim:SetRate(bp.Display.CannonOpenRate or 1)
			
            WaitFor(self.CannonAnim)
			
        end,
    },
    
    ClosedState = State() {
	
        Main = function(self)
			
            if self.CannonAnim then
			
                local bp = self:GetBlueprint()
				
                self.CannonAnim:SetRate( -1 * ( bp.Display.CannonOpenRate or 1 ) )
				
                WaitFor(self.CannonAnim)
				
            end
			
        end,
		
    },
	
}
TypeClass = XSS0304