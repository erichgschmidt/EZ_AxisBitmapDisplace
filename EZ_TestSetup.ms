/*
    EZ_TestSetup.ms
    Quick test rig for EZ Axis Bitmap Displace.

    Assumes EZ Multi Planar UVW is already in the stack.
    Run on a selected object that already has EZ Axis Bitmap Displace applied.

    - Prompts to pick 4 displacement bitmaps and loads them into the modifier
    - Assigns a Physical Material with procedural maps so blending and
      displacement are immediately readable without external textures
*/

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
    -- Material: plain clay — neutral and bright so displacement silhouette
    -- and surface detail read clearly without any texture distraction
    -- -----------------------------------------------------------------------
    local mat = PhysicalMaterial()
    mat.name       = "EZ_TestMaterial"
    mat.base_color = color 210 200 185
    mat.roughness  = 0.7
    mat.metalness  = 0.0

    obj.material = mat

    messageBox ("Done.\n\nClay material assigned to: " + obj.name + "\n\nPick your displacement bitmaps in the EZ Axis Bitmap Displace modifier panel.") title:"EZ Test Setup"
)

EZ_ApplyTestSetup()
