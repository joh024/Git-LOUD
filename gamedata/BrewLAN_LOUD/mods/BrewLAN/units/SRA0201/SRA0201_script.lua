--------------------------------------------------------------------------------
--  Summary  :  Cybran Spy Plane Script
--------------------------------------------------------------------------------
local CAirUnit = import('/lua/cybranunits.lua').CAirUnit

SRA0201 = Class(CAirUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
	
        CAirUnit.OnStopBeingBuilt(self,builder,layer)

    end,
}

TypeClass = SRA0201
