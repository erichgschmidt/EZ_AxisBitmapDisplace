/*
    EZ_TestSetup.ms
    Quick test rig for EZ Axis Bitmap Displace.

    Run on a selected mesh. Applies:
        - 4x UVW Map modifiers (planar per axis, channels 1-4)
        - EZ Axis Bitmap Displace on top
        - A neutral Physical Material so displacement reads clearly

    The modifier expects enough geometry to show displacement.
    Add a TurboSmooth or Subdivide below this stack if needed.
*/

fn EZ_ApplyTestSetup =
(
    local obj = selection[1]

    if obj == undefined then
    (
        messageBox "Select a mesh object first." title:"EZ Test Setup"
        return undefined
    )

    -- -----------------------------------------------------------------------
    -- UVW Map: X axis planar -> channel 1
    -- -----------------------------------------------------------------------
    local uvwX = UVWMap()
    uvwX.maptype = 0
    uvwX.axis    = 0
    uvwX.channel = 1
    uvwX.utile   = 1.0
    uvwX.vtile   = 1.0
    addModifier obj uvwX
    uvwX.name = "UVW X (Ch1)"

    -- -----------------------------------------------------------------------
    -- UVW Map: Z axis planar -> channel 2
    -- -----------------------------------------------------------------------
    local uvwZ = UVWMap()
    uvwZ.maptype = 0
    uvwZ.axis    = 2
    uvwZ.channel = 2
    uvwZ.utile   = 1.0
    uvwZ.vtile   = 1.0
    addModifier obj uvwZ
    uvwZ.name = "UVW Z (Ch2)"

    -- -----------------------------------------------------------------------
    -- UVW Map: Y top planar -> channel 3
    -- -----------------------------------------------------------------------
    local uvwYPos = UVWMap()
    uvwYPos.maptype = 0
    uvwYPos.axis    = 1
    uvwYPos.channel = 3
    uvwYPos.utile   = 1.0
    uvwYPos.vtile   = 1.0
    addModifier obj uvwYPos
    uvwYPos.name = "UVW Y+ (Ch3)"

    -- -----------------------------------------------------------------------
    -- UVW Map: Y bottom planar -> channel 4
    -- -----------------------------------------------------------------------
    local uvwYNeg = UVWMap()
    uvwYNeg.maptype = 0
    uvwYNeg.axis    = 1
    uvwYNeg.channel = 4
    uvwYNeg.utile   = 1.0
    uvwYNeg.vtile   = 1.0
    addModifier obj uvwYNeg
    uvwYNeg.name = "UVW Y- (Ch4)"

    -- -----------------------------------------------------------------------
    -- EZ Axis Bitmap Displace on top
    -- -----------------------------------------------------------------------
    local dispMod = EZ_AxisBitmapDisplace()
    addModifier obj dispMod
    dispMod.name = "EZ Axis Bitmap Displace"

    -- -----------------------------------------------------------------------
    -- Simple Physical Material so displacement reads clearly
    -- -----------------------------------------------------------------------
    local mat = PhysicalMaterial()
    mat.name          = "EZ_TestMaterial"
    mat.base_color    = color 200 190 175
    mat.roughness     = 0.6
    mat.metalness     = 0.0
    obj.material      = mat

    print ("EZ Test Setup applied to: " + obj.name)
    messageBox ("Done.\n\nStack applied to: " + obj.name + "\n\nNext: open EZ Axis Bitmap Displace in the modifier panel and pick your displacement bitmaps.") title:"EZ Test Setup"
)

EZ_ApplyTestSetup()
