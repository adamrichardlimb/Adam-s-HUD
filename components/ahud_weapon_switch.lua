if CLIENT then
		--Upon weapon switch
		function WSWITCH:Draw(client)
			if not self.Show then return end

			local weps = self.WeaponCache

			local x = AHUD.ScrW * (1 - AHUD.Padding)
			local y = AHUD.ScrH * (1 - AHUD.Padding)

			local sel = false

			for k, v in pairs(weps) do

				local wep = weps[#weps-(k-1)]

				if self.Selected == (#weps-(k-1)) then
					sel = true
				end

				draw.RoundedBox( 10, x - 184, y - 20, 20, 20, AHUD.ColBlack )
				if sel then
					draw.RoundedBox( 8, x - 182, y - 18, 16, 16, AHUD.ColRoles[ROLE] or AHUD.ColTextWhite )
				end

				surface.SetDrawColor( AHUD.ColBlack )
				surface.DrawRect( x - 160, y - 20, 160, 20 )

				draw.SimpleText( wep.Slot+1, "PD2_12", x - 175, y - 11, sel and AHUD.ColTextBlack or AHUD.ColTextFade, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( wep.Slot+1, "PD2_12", x - 174, y - 11, sel and AHUD.ColTextBlack or AHUD.ColTextFade, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( string.upper(LANG.TryTranslation(wep:GetPrintName() or wep.PrintName or "...")), "PD2_16", x - 158, y - 11, sel and AHUD.ColTextWhite or AHUD.ColTextFade, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

				sel = false

				y = y - 24
			end
		end
end