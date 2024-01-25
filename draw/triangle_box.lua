if CLIENT then

  function AHUD:CreateTriangle(x, y, width, height, corner, triangleHeight)
    corner = corner or AHUD.BOX_TOP_LEFT

    if corner == AHUD.BOX_TOP_LEFT then
      return {
        {x=x, y=y + triangleHeight},
        {x=x, y=y},
        {x = x + triangleHeight, y = y}
      }
    elseif corner == AHUD.BOX_TOP_RIGHT then
      return {
        {x=x,y=y},
        {x=x, y=y+triangleHeight},
        {x = x - triangleHeight, y = y}
      }
    elseif corner == AHUD.BOX_BOTTOM_LEFT then
      return {
        {x=x, y=y},
        {x=x, y=y - triangleHeight},
        {x=x + triangleHeight, y=y}
      }
    elseif corner == AHUD.BOX_BOTTOM_RIGHT then
      return {
        {x=x, y=y},
        {x=x-triangleHeight, y=y},
        {x=x, y=y-triangleHeight}
      }
    end
  end

  function AHUD:DrawMultiLineTriangleBox(x, y, width, height, corner)
    corner = corner or AHUD.BOX_TOP_LEFT
    local triangleHeight = (3/8) * math.min(width, height)

    local triangleVerts = AHUD:CreateTriangle(x, y, width, height, corner, triangleHeight)
    local squareVerts = {}

    local boxPadding = width * AHUD.Padding

    if corner == AHUD.BOX_TOP_LEFT then
      squareVerts ={
        {x = x + boxPadding + triangleHeight, y = y},
        {x = x + width, y = y},
        {x = x + width, y = y + height},
        {x = x, y = y + height},
        {x = x, y = y + boxPadding + triangleHeight}
      }
    elseif corner == AHUD.BOX_TOP_RIGHT then
      squareVerts = {
        {x=x-width, y=y+height},
        {x=x-width, y=y},
        {x=x-boxPadding-triangleHeight, y=y},
        {x=x, y=y+triangleHeight+boxPadding},
        {x=x, y=y+height}
      }

    elseif corner == AHUD.BOX_BOTTOM_LEFT then
      squareVerts = {
        {x=x, y=y-boxPadding-triangleHeight},
        {x=x, y=y-height},
        {x=x+width, y=y-height},
        {x=x+width, y=y},
        {x=x+boxPadding+triangleHeight, y=y}
      }
    elseif corner == AHUD.BOX_BOTTOM_RIGHT then
      squareVerts = {
        {x=x-width, y=y},
        {x=x-width, y=y-height},
        {x=x, y=y-height},
        {x=x, y=y-triangleHeight-boxPadding},
        {x=x-boxPadding-triangleHeight, y=y}
      }
    end

    AHUD:DrawScrolling(triangleVerts)
    AHUD:DrawScrolling(squareVerts)

    return {
      triangleVerts,
      squareVerts
    }
  end

  //A title box is hard-coded to have a triangle exactly as big as its height
  function AHUD:DrawOneLineTriangleBox(x, y, width, height, corner)
    if (width < height) then
      error("One line triangle boxes should be wider than they are tall!")
    end

    local triangleHeight = height
    local triangleVerts = AHUD:CreateTriangle(x, y, width, height, corner, triangleHeight)

    local boxPadding = width * AHUD.Padding

    if corner == AHUD.BOX_TOP_LEFT then
      squareVerts ={
        {x = x + boxPadding + triangleHeight, y = y},
        {x = x + width, y = y},
        {x = x + width, y = y + height},
        {x = x + boxPadding, y = y + triangleHeight}
      }
    elseif corner == AHUD.BOX_TOP_RIGHT then
      squareVerts = {
        {x=x-width, y=y+height},
        {x=x-width, y=y},
        {x=x-boxPadding-triangleHeight, y=y},
        {x=x, y=y+triangleHeight+boxPadding},
        {x=x, y=y+height}
      }
    elseif corner == AHUD.BOX_BOTTOM_LEFT then
      squareVerts = {
        {x=x, y=y-boxPadding-triangleHeight},
        {x=x, y=y-height},
        {x=x+width, y=y-height},
        {x=x+width, y=y},
        {x=x+boxPadding+triangleHeight, y=y}
      }
    elseif corner == AHUD.BOX_BOTTOM_RIGHT then
      squareVerts = {
        {x=x-width, y=y},
        {x=x-width, y=y-height},
        {x=x, y=y-height},
        {x=x, y=y-triangleHeight-boxPadding},
        {x=x-boxPadding-triangleHeight, y=y}
      }
    end

    AHUD:DrawScrolling(triangleVerts)
    AHUD:DrawScrolling(squareVerts)

  end
end