/*
    EZ_TestSetup.ms
    Quick test rig for EZ Axis Bitmap Displace.

    Run on a selected mesh. Applies:
        - 4x UVW Map modifiers (planar per axis, channels 1-4)
        - EZ Axis Bitmap Displace with bitmaps picked during setup
        - Physical Material with the same bitmaps on diffuse so you
          can see texture alignment alongside displacement

    The modifier expects enough geometry to show displacement.
    Add a TurboSmooth or Subdivide below this stack if needed.
*/

fn EZ_PickBitmap prompt =
(
    local result = undefined
    try
    (
        result = getOpenFileName \
            caption:prompt \
            types:"Images (*.png;*.jpg;*.jpeg;*.tif;*.tiff;*.bmp;*.tga)|*.png;*.jpg;*.jpeg;*.tif;*.tiff;*.bmp;*.tga|All Files (*.*)|*.*|"
    )
    catch ( result = undefined )
    result
)

fn EZ_MakeBitmapTex path =
(
    local tex = Bitmaptexture()
    tex.filename = path
    tex
)

fn EZ_ApplyTestSetup =
(
    local obj = selection[1]

    if obj == undefined then
    (
        messageBox "Select a mesh object first." title:"EZ Test Setup"
        return undefined
    )

    -- -----------------------------------------------------------------------
    -- Pick the 4 displacement bitmaps upfront
    -- -----------------------------------------------------------------------
    local pathX    = EZ_PickBitmap "Pick X Displacement Bitmap (Channel 1)"
    local pathZ    = EZ_PickBitmap "Pick Z Displacement Bitmap (Channel 2)"
    local pathYPos = EZ_PickBitmap "Pick Y+ Displacement Bitmap (Channel 3)"
    local pathYNeg = EZ_PickBitmap "Pick Y- Displacement Bitmap (Channel 4)"

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
    -- EZ Axis Bitmap Displace with paths assigned
    -- -----------------------------------------------------------------------
    local dispMod = EZ_AxisBitmapDisplace()
    addModifier obj dispMod
    dispMod.name = "EZ Axis Bitmap Displace"

    if pathX    != undefined do dispMod.xBitmapPath    = pathX
    if pathZ    != undefined do dispMod.zBitmapPath    = pathZ
    if pathYPos != undefined do dispMod.yPosBitmapPath = pathYPos
    if pathYNeg != undefined do dispMod.yNegBitmapPath = pathYNeg

    -- skipped bitmaps disable that axis
    if pathX    == undefined do dispMod.useXBitmap    = false
    if pathZ    == undefined do dispMod.useZBitmap    = false
    if pathYPos == undefined do dispMod.useYPosBitmap = false
    if pathYNeg == undefined do dispMod.useYNegBitmap = false

    -- -----------------------------------------------------------------------
    -- Physical Material with displacement bitmaps on diffuse
    -- so texture alignment is visible alongside the displacement
    -- -----------------------------------------------------------------------
    local mat = PhysicalMaterial()
    mat.name      = "EZ_TestMaterial"
    mat.roughness = 0.7
    mat.metalness = 0.0

    -- Use X bitmap as primary diffuse if available, else plain clay
    if pathX != undefined then
    (
        local diffTex = EZ_MakeBitmapTex pathX
        diffTex.coords.mapChannel = 1
        mat.base_color_map = diffTex
        mat.base_color_map_on = true
    )
    else
    (
        mat.base_color = color 210 200 185
    )

    obj.material = mat

    messageBox ("Done.\n\nStack applied to: " + obj.name + "\n\nAdjust tiling on the UVW Map modifiers to match your bitmap scale.\nTweak amounts in EZ Axis Bitmap Displace.") title:"EZ Test Setup"
)

EZ_ApplyTestSetup()
