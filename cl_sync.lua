--[[---------------------------------------------------------------------------------------

	Wraith ARS 2X
	Created by WolfKnight
	
	For discussions, information on future updates, and more, join 
	my Discord: https://discord.gg/fD4e6WD 
	
	MIT License

	Copyright (c) 2020-2021 WolfKnight

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

---------------------------------------------------------------------------------------]]--

SYNC = {}


--[[----------------------------------------------------------------------------------
	Sync functions 
----------------------------------------------------------------------------------]]--
function SYNC:SyncData( cb )
	local otherPed = PLY:GetOtherPed()

	if ( otherPed ~= nil and otherPed ~= 0 ) then 
		local otherPly = GetPlayerServerId( NetworkGetPlayerIndexFromPed( otherPed ) )

		cb( otherPly )
	end 
end 

function SYNC:SendPowerState( state )
	self:SyncData( function( ply )
		TriggerServerEvent( "wk_wars2x_sync:sendPowerState", ply, state )
	end )
end 

function SYNC:SendAntennaPowerState( state, ant )
	self:SyncData( function( ply )
		TriggerServerEvent( "wk_wars2x_sync:sendAntennaPowerState", ply, state, ant )
	end )
end 

function SYNC:SendAntennaMode( ant, mode )
	self:SyncData( function( ply )
		TriggerServerEvent( "wk_wars2x_sync:sendAntennaMode", ply, ant, mode )
	end )
end 


--[[----------------------------------------------------------------------------------
	Sync client events
----------------------------------------------------------------------------------]]--
RegisterNetEvent( "wk_wars2x_sync:receivePowerState" )
AddEventHandler( "wk_wars2x_sync:receivePowerState", function( state )
	local power = RADAR:IsPowerOn()

	if ( power ~= state ) then 
		Citizen.SetTimeout( 100, function()
			RADAR:TogglePower()
		end )
	end 
end )

RegisterNetEvent( "wk_wars2x_sync:receiveAntennaPowerState" )
AddEventHandler( "wk_wars2x_sync:receiveAntennaPowerState", function( state, antenna )
	local power = RADAR:IsAntennaTransmitting( antenna )

	if ( power ~= state ) then 
		RADAR:ToggleAntenna( antenna, function()
			-- Update the interface with the new antenna transmit state
			SendNUIMessage( { _type = "antennaXmit", ant = antenna, on = state } )
			
			-- Play some audio specific to the transmit state
			SendNUIMessage( { _type = "audio", name = state and "xmit_on" or "xmit_off", vol = RADAR:GetSettingValue( "beep" ) } )
		end )
	end 
end )

RegisterNetEvent( "wk_wars2x_sync:receiveAntennaMode" )
AddEventHandler( "wk_wars2x_sync:receiveAntennaMode", function( antenna, mode )
	RADAR:SetAntennaMode( antenna, mode, function()
		-- Update the interface with the new mode 
		SendNUIMessage( { _type = "antennaMode", ant = antenna, mode = mode } )
		
		-- Play a beep 
		SendNUIMessage( { _type = "audio", name = "beep", vol = RADAR:GetSettingValue( "beep" ) } )
	end )
end )