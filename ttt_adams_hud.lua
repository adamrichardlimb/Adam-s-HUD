--[[
	Adams HUD

	A HUD for TTT which seeks to make relevant information clear to the player and bring an aesthetic to TTT.
	This HUD is HEAVILY inspired by CGNick's Payday 2 HUD, which he has stated he considers freeware and only asks you credit him.
	Here's a list of things I stole:

	- Colours
	- Role names
	- Round states
	- Bordered Circle Code
	- The timer trick to get the game to not complain about GAMEMODE not being defined
	- HUDPaint Function

]]--

--Faded black bg
--Had to make a whole vtf for this just cause I couldn't get opacity working lol
resource.AddFile("materials/AHUD_MATFADE.vmt")

if CLIENT then
	timer.Simple( 0, function()
		-- Here we go...
		AHUD = {}

		AHUD.BOX_TOP_LEFT = 0
		AHUD.BOX_TOP_RIGHT = 1
		AHUD.BOX_BOTTOM_LEFT = 2
		AHUD.BOX_BOTTOM_RIGHT = 3

		-- Define static stuff we likely will not change
		AHUD.ScrW = ScrW()
		AHUD.ScrH = ScrH()
		AHUD.MatWhite = Material("vgui/white")
		AHUD.MatScan = Material("effects/tvscreen_noise002a")

		AHUD.MatFade = Material("AHUD_MATFADE")

		AHUD.Padding = 0.025
		AHUD.Margin = 0.0125
		AHUD.LastDisplayedHealth = -1
		surface.CreateFont( "PD2_24", { font = "Tenby Five", antialias = false, scanlines = 2, blur = 15, size = 36})
		surface.CreateFont( "PD2_12", { font = "Tenby Five", antialias = true, size = 17 } )
		surface.CreateFont( "PD2_14", { font = "Tenby Five", antialias = true, size = 18 } )
		surface.CreateFont( "PD2_16", { font = "Tenby Five", antialias = true, size = 23 } )
		surface.CreateFont( "PD2_20", { font = "Tenby Five", antialias = true, size = 32.5 } )
		-- surface.CreateFont( "PD2_24", { font = "Tenby Five", antialias = true, size = 39 } )

		--How long should the health drain animation last
		AHUD.HealthAnimFadeInterval = 0.35
		AHUD.HealthAnimTickLength = 0.05
		AHUD.HealthAnimTickInterval = -1
		AHUD.HealthAnimTickCount = -1
		AHUD.HealthAnimTickNumber = -1
		AHUD.HealthAnimNextTick = -1
		AHUD.HealthAnimValue = -1

		-- From the PD2 HUD
		AHUD.ColBlack = Color( 0, 0, 0, 175 )
		AHUD.ColOvertime = Color( 255, 255, 0, 200 )
		AHUD.ColTextBlack = Color( 0, 0, 0, 255 )
		AHUD.ColTextWhite = Color( 255, 255, 255, 200 )
		AHUD.ColTextRed = Color( 255, 100, 100, 200 )
		AHUD.ColTextFade = Color( 255, 255, 255, 50 )

		AHUD.ColRoles = {
			[0] = Color( 200, 255, 150, 220 ),
			[1] = Color( 255, 100, 100, 220 ),
			[2] = Color( 100, 200, 255, 220 ),
		}

		AHUD.Roles = {
			[0] = "INNOCENT",
			[1] = "TRAITOR",
			[2] = "DETECTIVE",
		}

		AHUD.RoundStates = {
			[ROUND_WAIT]   = "round_wait",
			[ROUND_PREP]   = "round_prep",
			[ROUND_ACTIVE] = "round_active",
			[ROUND_POST]   = "round_post"
		}

		include("autorun/draw/arc.lua")
		include("autorun/draw/textured_rect.lua")
		include("autorun/draw/triangle_box.lua")
		include("autorun/draw/outlined_poly.lua")
		include("autorun/components/ahud_mainsection.lua")
		include("autorun/components/ahud_weapon_switch.lua")

		-- Stolen from CGNicks Payday 2 HUD, he's said it's freeware now but got to give credit to the OG
		function GAMEMODE:HUDPaint()
			local client = LocalPlayer()
			ROLE = LocalPlayer():GetRole()

			hook.Call( "HUDDrawTargetID", GAMEMODE )

			MSTACK:Draw(client)

			--if (not client:Alive()) or client:Team() == TEAM_SPEC then
			--SpecHUDPaint(client)

			--return
			--end

			RADAR:Draw(client)
			TBHUD:Draw(client)
			WSWITCH:Draw(client)

			VOICE.Draw(client)
			--DISGUISE.Draw(client)

			hook.Call( "HUDDrawPickupHistory", GAMEMODE )
		end

		hook.Add("HUDPaint", "ADAMS_HUD", function()

			AHUD:DrawHealthArea()
			--AHUD:DrawOneLineTriangleBox(AHUD.ScrW/2, AHUD.ScrH/2, 200, 100, AHUD.BOX_TOP_LEFT)
			local tri = {
				{x=0, y=ScrH()},
				{x=ScrW(), y=0},
				{x=ScrW(), y=ScrH()}
			}
			DrawOutlinedPoly(tri, 10)

		end)
	end)
end