if CLIENT then

  function AHUD:DrawScrolling(verts)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(AHUD.MatFade)
    surface.DrawPoly(verts)
    surface.SetMaterial(AHUD.MatScan)
    surface.DrawPoly(verts)
    draw.NoTexture()
  end

  function AHUD:DrawTexturedRect(x, y, width, height)
    AHUD:DrawScrolling(
      {
        {x=x, y=y},
        {x=x+width, y=y},
        {x=x+width, y=y+height},
        {x=x,y=y+height}
      }
    )
  end

  -- Draws a textured rect with an outline and returns the new vertices not affected by the boundary
  function AHUD:DrawOutlinedTexturedRect(x, y, width, height)

    --Use math.ceil to avoid any float issues, it's better to draw slightly larger than smaller
    local outline_size = math.ceil(1.5 * AHUD.Padding * math.max(width, height))

    AHUD:DrawScrolling(
      {
        {x=x, y=y},
        {x=x+width, y=y},
        {x=x+width, y=y+height},
        {x=x,y=y+height}
      }
    )

    //Then draw the outline inside the shape
    surface.SetDrawColor(color_white)
    surface.DrawRect(x, y, outline_size, height)
    surface.DrawRect(x, y, width, outline_size)
    surface.DrawRect(x-outline_size + width, y, outline_size, height)
    surface.DrawRect(x, y-outline_size+height, width, outline_size)

    return {
      {x=x+outline_size, y=y+outline_size},
      {x=x+width-outline_size, y=y+outline_size},
      {x=x+outline_size, y=y+height-outline_size},
      {x=x+width-outline_size, y=y+height-outline_size}
    }
  end
end