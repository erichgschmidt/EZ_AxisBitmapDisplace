/*
    EZ_TestSetup.ms
    Quick test rig for EZ Axis Bitmap Displace.

    Assumes EZ Multi Planar UVW is already in the stack.
    Run on a selected object that already has EZ Axis Bitmap Displace applied.

    - Prompts to pick 4 displacement bitmaps and loads them into the modifier
    - Assigns a Physical Material with procedural maps so blending and
      displacement are immediately readable without external textures
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

fn EZ_FindDisplaceMod obj =
(
    local result = undefined
    for i = 1 to obj.modifiers.count do
    (
        if (classof obj.modifiers[i]) == EZ_AxisBitmapDisplace do
        (
            result = obj.modifiers[i]
            exit
        )
    )
    result
)

fn EZ_ApplyTestSetup =
(
    local obj = selection[1]

    if obj == undefined then
    (
        messageBox "Select an object first." title:"EZ Test Setup"
        return undefined
    )

    -- -----------------------------------------------------------------------
    -- Find existing EZ Axis Bitmap Displace modifier on the object
    -- -----------------------------------------------------------------------
    local dispMod = EZ_FindDisplaceMod obj

    if dispMod == undefined then
    (
        messageBox "No EZ Axis Bitmap Displace modifier found on this object.\nApply it first, then run this script." title:"EZ Test Setup"
        return undefined
    )

    -- -----------------------------------------------------------------------
    -- Pick displacement bitmaps and load into modifier
    -- Cancelling any dialog skips that axis (leaves existing path untouched)
    -- -----------------------------------------------------------------------
    local pathX    = EZ_PickBitmap "X Displacement Bitmap  (Channel 1 — skips if cancelled)"
    local pathZ    = EZ_PickBitmap "Z Displacement Bitmap  (Channel 2 — skips if cancelled)"
    local pathYPos = EZ_PickBitmap "Y+ Displacement Bitmap (Channel 3 — skips if cancelled)"
    local pathYNeg = EZ_PickBitmap "Y- Displacement Bitmap (Channel 4 — skips if cancelled)"

    if pathX    != undefined do ( dispMod.xBitmapPath    = pathX;    dispMod.useXBitmap    = true )
    if pathZ    != undefined do ( dispMod.zBitmapPath    = pathZ;    dispMod.useZBitmap    = true )
    if pathYPos != undefined do ( dispMod.yPosBitmapPath = pathYPos; dispMod.useYPosBitmap = true )
    if pathYNeg != undefined do ( dispMod.yNegBitmapPath = pathYNeg; dispMod.useYNegBitmap = true )

    -- -----------------------------------------------------------------------
    -- Material
    -- Base color: Checker so UV projection and blending seams are readable
    -- Roughness: Noise so surface micro-variation reads in renders
    -- Displacement is driven by the modifier, not the material
    -- -----------------------------------------------------------------------
    local mat = PhysicalMaterial()
    mat.name      = "EZ_TestMaterial"
    mat.roughness = 0.65
    mat.metalness = 0.0

    -- Checker on base color — makes UV alignment and blend zones obvious
    local checker = Checker()
    checker.color1 = color 220 210 195
    checker.color2 = color 80 70 60
    checker.coords.mapChannel = 1
    checker.coords.U_Tiling   = 4.0
    checker.coords.V_Tiling   = 4.0
    mat.base_color_map    = checker
    mat.base_color_map_on = true

    -- Noise on roughness — helps read surface curvature from displacement
    local roughNoise = Noise()
    roughNoise.color1   = color 100 100 100
    roughNoise.color2   = color 200 200 200
    roughNoise.size     = 15.0
    roughNoise.coords.mapChannel = 1
    mat.roughness_map    = roughNoise
    mat.roughness_map_on = true

    obj.material = mat

    messageBox ("Done.\n\nBitmaps loaded into EZ Axis Bitmap Displace.\nMaterial assigned with Checker diffuse + Noise roughness.\n\nTweak amounts and tiling directly in the modifier panel.") title:"EZ Test Setup"
)

EZ_ApplyTestSetup()
