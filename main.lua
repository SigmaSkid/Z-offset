function GetNaiveOverlappingAxis(VecA, VecB)
    local axis = {}
    axis[1] = VecA[1] == VecB[1]
    axis[2] = VecA[2] == VecB[2]
    axis[3] = VecA[3] == VecB[3]
    return axis
end

function GetShapeOverlappingAxis(ShapeA, ShapeB)
    local minA, maxA = GetShapeBounds(ShapeA)
    local minB, maxB = GetShapeBounds(ShapeB)

    local axis = {}
    axis[1] = GetNaiveOverlappingAxis(minA, minB)
    axis[2] = GetNaiveOverlappingAxis(minA, maxB)
    axis[3] = GetNaiveOverlappingAxis(maxA, minB)
    axis[4] = GetNaiveOverlappingAxis(maxA, maxB)

    local out = {}
    
    for i=1, 3 do 
        out[i] = axis[1][i] or axis[2][i] or axis[3][i] or axis[4][i]
    end

    return out
end

function init() 

    local bodies = FindBodies(nil, true)
    --DebugPrint("Bodies: " .. #bodies)

    local shapes = {}

    -- get all shapes in scene
    for i=1, #bodies do 
        local cur_body_shapes = GetBodyShapes(bodies[i])
        
        for x=1,#cur_body_shapes do
            local this_shape = cur_body_shapes[x]

            shapes[#shapes + 1] = this_shape
        end
    end
    --DebugPrint("Shapes: " .. #shapes)

    local dp = 0 -- displacement counter
    local dd = 0.00001 -- displacement_distance

    -- find shape overlaps
    for i=1, #shapes do 
        for x=i+1, #shapes do 
            local shapeI = shapes[i]
            local shapeX = shapes[x]
        
            local touch = IsShapeTouching(shapeI, shapeX)
            if touch then
                local axis = GetShapeOverlappingAxis(shapeI, shapeX)

                if axis[1] or axis[2] or axis[3] then 
                    dp = dp + 1 

                    local transformI = GetShapeLocalTransform(shapeI)
                    local transformX = GetShapeLocalTransform(shapeX)
                    local positionI = transformI.pos
                    local positionX = transformX.pos
                    
                    for z=1, 3 do
                        if axis[z] then 
                            positionI[z] = positionI[z] + dd
                            positionX[z] = positionX[z] - dd
                        end
                    end

                    transformI = Transform(Vec(positionI[1], positionI[2], positionI[3]), transformI.rot)
                    transformX = Transform(Vec(positionX[1], positionX[2], positionX[3]), transformX.rot)
                    SetShapeLocalTransform(shapeI, transformI)
                    SetShapeLocalTransform(shapeX, transformX)
                end
            end
                
        end
    end
    --DebugPrint("Displaced shapes: " .. dp)

end