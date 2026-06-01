/*
    EZ_AxisBitmapDisplace.ms
    3ds Max 2023+

    Axis-aware bitmap displacement using:
        - Existing planar UV channels
        - Existing Channel 10 XYZ blend/mask data
        - Specific displacement bitmap files per projection

    Expected stack:
        EZ Axis Bitmap Displace
        EZ Data Channel Corner Blend
        EZ Multi Planar UVW
        XForm
        Base mesh
*/

plugin simpleMeshMod EZ_AxisBitmapDisplace
name:"EZ Axis Bitmap Displace"
classID:#(0x4f6a2b18, 0x6d9c1e33)
category:"EZ Tools"
(
    parameters main rollout:roll_params
    (
        active type:#boolean default:true ui:chk_active

        maskChannel type:#integer default:10 ui:spn_maskChannel

        xUVChannel    type:#integer default:1 ui:spn_xUVChannel
        zUVChannel    type:#integer default:2 ui:spn_zUVChannel
        yPosUVChannel type:#integer default:3 ui:spn_yPosUVChannel
        yNegUVChannel type:#integer default:4 ui:spn_yNegUVChannel

        xBitmapPath    type:#string default:""
        zBitmapPath    type:#string default:""
        yPosBitmapPath type:#string default:""
        yNegBitmapPath type:#string default:""

        useXBitmap    type:#boolean default:true ui:chk_useXBitmap
        useZBitmap    type:#boolean default:true ui:chk_useZBitmap
        useYPosBitmap type:#boolean default:true ui:chk_useYPosBitmap
        useYNegBitmap type:#boolean default:true ui:chk_useYNegBitmap

        directionMode type:#integer default:1 ui:ddl_directionMode

        globalMultiplier type:#float default:1.0 ui:spn_globalMultiplier

        xAmount    type:#float default:10.0 ui:spn_xAmount
        zAmount    type:#float default:10.0 ui:spn_zAmount
        yPosAmount type:#float default:10.0 ui:spn_yPosAmount
        yNegAmount type:#float default:10.0 ui:spn_yNegAmount

        xBase    type:#float default:0.0 ui:spn_xBase
        zBase    type:#float default:0.0 ui:spn_zBase
        yPosBase type:#float default:0.0 ui:spn_yPosBase
        yNegBase type:#float default:0.0 ui:spn_yNegBase

        centeredHeight    type:#boolean default:false ui:chk_centeredHeight
        flipBitmapV       type:#boolean default:true  ui:chk_flipBitmapV

        heightLowClamp  type:#float default:0.0 ui:spn_heightLowClamp
        heightHighClamp type:#float default:1.0 ui:spn_heightHighClamp
        heightPower     type:#float default:1.0 ui:spn_heightPower

        maskLowClamp  type:#float default:0.0 ui:spn_maskLowClamp
        maskHighClamp type:#float default:1.0 ui:spn_maskHighClamp
        maskPower     type:#float default:1.0 ui:spn_maskPower

        invertXMask type:#boolean default:false ui:chk_invertXMask
        invertZMask type:#boolean default:false ui:chk_invertZMask
        invertYMask type:#boolean default:false ui:chk_invertYMask

        invertFinalDirection type:#boolean default:false ui:chk_invertFinalDirection
    )

    rollout roll_params "Axis Bitmap Displace"
    (
        checkbox chk_active "Enable" checked:true

        group "Input Channels"
        (
            spinner spn_maskChannel    "Mask Channel:"  range:[1,99,10] type:#integer fieldwidth:55

            spinner spn_xUVChannel    "X UV Channel:"  range:[1,99,1] type:#integer fieldwidth:55
            spinner spn_zUVChannel    "Z UV Channel:"  range:[1,99,2] type:#integer fieldwidth:55
            spinner spn_yPosUVChannel "Y+ UV Channel:" range:[1,99,3] type:#integer fieldwidth:55
            spinner spn_yNegUVChannel "Y- UV Channel:" range:[1,99,4] type:#integer fieldwidth:55
        )

        group "X Projection Bitmap"
        (
            checkbox chk_useXBitmap "Use X Bitmap" checked:true
            edittext edt_xBitmap "Path:" text:"" fieldwidth:260
            button btn_pickX "Pick X Displacement Bitmap"
            button btn_clearX "Clear X Bitmap"
        )

        group "Z Projection Bitmap"
        (
            checkbox chk_useZBitmap "Use Z Bitmap" checked:true
            edittext edt_zBitmap "Path:" text:"" fieldwidth:260
            button btn_pickZ "Pick Z Displacement Bitmap"
            button btn_clearZ "Clear Z Bitmap"
        )

        group "Y Positive Projection Bitmap"
        (
            checkbox chk_useYPosBitmap "Use Y+ Bitmap" checked:true
            edittext edt_yPosBitmap "Path:" text:"" fieldwidth:260
            button btn_pickYPos "Pick Y+ Displacement Bitmap"
            button btn_clearYPos "Clear Y+ Bitmap"
        )

        group "Y Negative Projection Bitmap"
        (
            checkbox chk_useYNegBitmap "Use Y- Bitmap" checked:true
            edittext edt_yNegBitmap "Path:" text:"" fieldwidth:260
            button btn_pickYNeg "Pick Y- Displacement Bitmap"
            button btn_clearYNeg "Clear Y- Bitmap"
        )

        group "Direction"
        (
            dropdownlist ddl_directionMode "Mode:" items:#("Signed Local Axis", "Positive Local Axis", "Vertex Normal") selection:1
            checkbox chk_invertFinalDirection "Invert Final Direction" checked:false
        )

        group "Specific Displacement Amounts"
        (
            spinner spn_globalMultiplier "Global Multiplier:" range:[-100000.0,100000.0,1.0] type:#float fieldwidth:70 scale:0.1

            spinner spn_xAmount    "X Amount:"  range:[-100000.0,100000.0,10.0] type:#float fieldwidth:70 scale:0.1
            spinner spn_zAmount    "Z Amount:"  range:[-100000.0,100000.0,10.0] type:#float fieldwidth:70 scale:0.1
            spinner spn_yPosAmount "Y+ Amount:" range:[-100000.0,100000.0,10.0] type:#float fieldwidth:70 scale:0.1
            spinner spn_yNegAmount "Y- Amount:" range:[-100000.0,100000.0,10.0] type:#float fieldwidth:70 scale:0.1
        )

        group "Base Offsets"
        (
            spinner spn_xBase    "X Base:"  range:[-100000.0,100000.0,0.0] type:#float fieldwidth:70 scale:0.1
            spinner spn_zBase    "Z Base:"  range:[-100000.0,100000.0,0.0] type:#float fieldwidth:70 scale:0.1
            spinner spn_yPosBase "Y+ Base:" range:[-100000.0,100000.0,0.0] type:#float fieldwidth:70 scale:0.1
            spinner spn_yNegBase "Y- Base:" range:[-100000.0,100000.0,0.0] type:#float fieldwidth:70 scale:0.1
        )

        group "Height Bitmap Shaping"
        (
            checkbox chk_centeredHeight "Centered Height: 0.5 = Zero" checked:false
            checkbox chk_flipBitmapV    "Flip Bitmap V"               checked:true

            spinner spn_heightLowClamp  "Height Low:"   range:[0.0,1.0,0.0]  type:#float fieldwidth:55 scale:0.01
            spinner spn_heightHighClamp "Height High:"  range:[0.0,1.0,1.0]  type:#float fieldwidth:55 scale:0.01
            spinner spn_heightPower     "Height Power:" range:[0.01,20.0,1.0] type:#float fieldwidth:55 scale:0.05
        )

        group "Channel 10 Mask Shaping"
        (
            spinner spn_maskLowClamp  "Mask Low:"   range:[0.0,1.0,0.0]  type:#float fieldwidth:55 scale:0.01
            spinner spn_maskHighClamp "Mask High:"  range:[0.0,1.0,1.0]  type:#float fieldwidth:55 scale:0.01
            spinner spn_maskPower     "Mask Power:" range:[0.01,20.0,1.0] type:#float fieldwidth:55 scale:0.05

            checkbox chk_invertXMask "Invert X Mask" checked:false
            checkbox chk_invertZMask "Invert Z Mask" checked:false
            checkbox chk_invertYMask "Invert Y Mask" checked:false
        )

        label lbl_note01 "Reads UV channels 1-4 and Channel 10 XYZ masks." align:#left
        label lbl_note02 "Prototype for pseudo-triplanar displacement."     align:#left

        fn refreshPaths =
        (
            edt_xBitmap.text    = xBitmapPath
            edt_zBitmap.text    = zBitmapPath
            edt_yPosBitmap.text = yPosBitmapPath
            edt_yNegBitmap.text = yNegBitmapPath
        )

        fn pickBitmapFile currentPath =
        (
            local result = undefined

            try
            (
                result = getOpenFileName caption:"Pick Displacement Bitmap" \
                    filename:currentPath \
                    types:"Images (*.png;*.jpg;*.jpeg;*.tif;*.tiff;*.bmp;*.tga)|*.png;*.jpg;*.jpeg;*.tif;*.tiff;*.bmp;*.tga|All Files (*.*)|*.*|"
            )
            catch
            (
                result = undefined
            )

            result
        )

        on roll_params open do refreshPaths()

        on btn_pickX pressed do
        (
            local f = pickBitmapFile xBitmapPath
            if f != undefined do ( xBitmapPath = f; refreshPaths() )
        )

        on btn_clearX pressed do ( xBitmapPath = ""; refreshPaths() )

        on btn_pickZ pressed do
        (
            local f = pickBitmapFile zBitmapPath
            if f != undefined do ( zBitmapPath = f; refreshPaths() )
        )

        on btn_clearZ pressed do ( zBitmapPath = ""; refreshPaths() )

        on btn_pickYPos pressed do
        (
            local f = pickBitmapFile yPosBitmapPath
            if f != undefined do ( yPosBitmapPath = f; refreshPaths() )
        )

        on btn_clearYPos pressed do ( yPosBitmapPath = ""; refreshPaths() )

        on btn_pickYNeg pressed do
        (
            local f = pickBitmapFile yNegBitmapPath
            if f != undefined do ( yNegBitmapPath = f; refreshPaths() )
        )

        on btn_clearYNeg pressed do ( yNegBitmapPath = ""; refreshPaths() )

        on edt_xBitmap    entered t do ( xBitmapPath    = t; refreshPaths() )
        on edt_zBitmap    entered t do ( zBitmapPath    = t; refreshPaths() )
        on edt_yPosBitmap entered t do ( yPosBitmapPath = t; refreshPaths() )
        on edt_yNegBitmap entered t do ( yNegBitmapPath = t; refreshPaths() )
    )

    -- -----------------------------------------------------------------------
    -- Math helpers
    -- -----------------------------------------------------------------------

    fn clampChannel ch =
    (
        if ch < 1 then 1 else if ch > 99 then 99 else ch
    )

    fn clamp01 v =
    (
        if v < 0.0 then 0.0 else if v > 1.0 then 1.0 else v
    )

    fn wrap01 v =
    (
        local r = v - (floor v)
        if r < 0.0 then r + 1.0 else r
    )

    fn safeNormalizePoint3 v =
    (
        local len = length v
        if len >= 0.000001 then v / len else [0, 0, 1]
    )

    fn remapClamp v lo hi =
    (
        local a = lo
        local b = hi

        if b < a do
        (
            local tmp = a
            a = b
            b = tmp
        )

        local range = b - a

        if range < 0.000001 then
        (
            if v >= b then 1.0 else 0.0
        )
        else
        (
            clamp01 ((v - a) / range)
        )
    )

    fn applyPower01 v p =
    (
        local pSafe = if p < 0.01 then 0.01 else p
        pow (clamp01 v) pSafe
    )

    -- -----------------------------------------------------------------------
    -- Bitmap pre-loading
    -- Reads the entire bitmap into a flat MAXScript array once per evaluation.
    -- Pixel at (px, py) is pixelData[py * w + px + 1].
    -- -----------------------------------------------------------------------

    fn openBitmapSafe bitmapPath =
    (
        local result = undefined

        if bitmapPath != undefined and bitmapPath != "" and (doesFileExist bitmapPath) then
        (
            try ( result = openBitmap bitmapPath ) catch ( result = undefined )
        )

        result
    )

    fn closeBitmapSafe bmp =
    (
        if bmp != undefined do
        (
            try ( close bmp ) catch ()
        )

        true
    )

    -- Returns #(pixelArray, width, height) or undefined if bitmap is missing/invalid.
    fn preloadBitmapData bmp =
    (
        local result = undefined

        if bmp != undefined then
        (
            local w = bmp.width
            local h = bmp.height

            if w > 0 and h > 0 then
            (
                try
                (
                    local pixels = getPixels bmp [0, 0] (w * h)
                    result = #(pixels, w, h)
                )
                catch
                (
                    result = undefined
                )
            )
        )

        result
    )

    -- Sample a pre-loaded pixel array. uv is a Point3 with U in .x, V in .y.
    fn samplePreloaded bmpData uv =
    (
        local pixels = bmpData[1]
        local w      = bmpData[2]
        local h      = bmpData[3]

        local u = wrap01 uv.x
        local v = wrap01 uv.y

        if flipBitmapV == true do ( v = 1.0 - v )

        local px = ((u * (w - 1)) as integer)
        local py = ((v * (h - 1)) as integer)

        if px < 0 then px = 0 else if px > (w - 1) then px = w - 1
        if py < 0 then py = 0 else if py > (h - 1) then py = h - 1

        local c = pixels[py * w + px + 1]
        ((c.r + c.g + c.b) / 3.0) / 255.0
    )

    -- -----------------------------------------------------------------------
    -- UV / mask channel pre-caching
    -- Reads all map verts for a channel into a flat array indexed by vertex.
    -- Assumes 1:1 vertex-to-mapvert layout (as produced by EZ Multi Planar UVW).
    -- Returns an array of nv Point3 values, or all-zero if channel is absent.
    -- -----------------------------------------------------------------------

    fn cacheMapChannel m ch nv =
    (
        local zero  = [0.0, 0.0, 0.0]
        local cache = for i = 1 to nv collect zero

        local supported = false

        if ch == 1 then
        (
            supported = (m.numtverts >= 1)
        )
        else
        (
            try ( supported = meshop.getMapSupport m ch ) catch ( supported = false )
        )

        if supported == true then
        (
            local mapCount = 0

            if ch == 1 then
            (
                mapCount = m.numtverts
            )
            else
            (
                try ( mapCount = meshop.getNumMapVerts m ch ) catch ( mapCount = 0 )
            )

            local limit = if mapCount < nv then mapCount else nv

            if ch == 1 then
            (
                for i = 1 to limit do
                (
                    try ( cache[i] = getTVert m i ) catch ()
                )
            )
            else
            (
                for i = 1 to limit do
                (
                    try ( cache[i] = meshop.getMapVert m ch i ) catch ()
                )
            )
        )

        cache
    )

    -- -----------------------------------------------------------------------
    -- Normal computation
    -- -----------------------------------------------------------------------

    fn computeAverageNormals m =
    (
        local nv     = m.numverts
        local normals = for i = 1 to nv collect [0.0, 0.0, 0.0]

        for f = 1 to m.numfaces do
        (
            local fv = getFace m f
            local a  = fv.x as integer
            local b  = fv.y as integer
            local c  = fv.z as integer

            local pA = getVert m a
            local pB = getVert m b
            local pC = getVert m c

            local faceNrm = safeNormalizePoint3 (cross (pB - pA) (pC - pA))

            normals[a] = normals[a] + faceNrm
            normals[b] = normals[b] + faceNrm
            normals[c] = normals[c] + faceNrm
        )

        for i = 1 to nv do
        (
            normals[i] = safeNormalizePoint3 normals[i]
        )

        normals
    )

    -- -----------------------------------------------------------------------
    -- Per-vertex displacement (pure math, no Max API calls)
    -- All inputs are pre-cached arrays or pre-loaded bitmap data structs.
    -- -----------------------------------------------------------------------

    fn processHeight rawValue =
    (
        local v = remapClamp rawValue heightLowClamp heightHighClamp
        v = applyPower01 v heightPower

        if centeredHeight == true do ( v = (v - 0.5) * 2.0 )

        v
    )

    fn processMask rawValue invertMask =
    (
        local v = remapClamp rawValue maskLowClamp maskHighClamp
        v = applyPower01 v maskPower

        if invertMask == true do ( v = 1.0 - v )

        clamp01 v
    )

    fn getHeight useBitmap bmpData uv =
    (
        local raw = 1.0

        if useBitmap == true then
        (
            if bmpData != undefined then
                raw = samplePreloaded bmpData uv
            else
                raw = 0.0
        )

        processHeight raw
    )

    fn computeDelta normalVal maskVal \
                    uvX uvZ uvYPos uvYNeg \
                    bmpDataX bmpDataZ bmpDataYPos bmpDataYNeg =
    (
        local xMask = processMask maskVal.x invertXMask
        local zMask = processMask maskVal.z invertZMask
        local yMask = processMask maskVal.y invertYMask

        local xH = getHeight useXBitmap bmpDataX uvX
        local zH = getHeight useZBitmap bmpDataZ uvZ

        local yH      = 0.0
        local yAmt    = 0.0
        local yBaseV  = 0.0

        if normalVal.y >= 0.0 then
        (
            yH     = getHeight useYPosBitmap bmpDataYPos uvYPos
            yAmt   = yPosAmount
            yBaseV = yPosBase
        )
        else
        (
            yH     = getHeight useYNegBitmap bmpDataYNeg uvYNeg
            yAmt   = yNegAmount
            yBaseV = yNegBase
        )

        local xC = (xBase + xH * xAmount) * xMask * globalMultiplier
        local zC = (zBase + zH * zAmount) * zMask * globalMultiplier
        local yC = (yBaseV + yH * yAmt)   * yMask * globalMultiplier

        local delta = [0.0, 0.0, 0.0]

        if directionMode == 1 then
        (
            local sx = if normalVal.x < 0.0 then -1.0 else 1.0
            local sy = if normalVal.y < 0.0 then -1.0 else 1.0
            local sz = if normalVal.z < 0.0 then -1.0 else 1.0

            delta = [xC * sx, yC * sy, zC * sz]
        )
        else if directionMode == 2 then
        (
            delta = [xC, yC, zC]
        )
        else if directionMode == 3 then
        (
            delta = normalVal * (xC + yC + zC)
        )

        if invertFinalDirection == true do ( delta = delta * -1.0 )

        delta
    )

    -- -----------------------------------------------------------------------
    -- Modifier evaluation
    -- -----------------------------------------------------------------------

    on modifyMesh do
    (
        if active != true then return undefined
        if mesh == undefined then return undefined

        local nv = mesh.numverts
        local nf = mesh.numfaces

        if nv < 1 or nf < 1 then return undefined

        -- Open bitmaps
        local bmpX    = if useXBitmap    then openBitmapSafe xBitmapPath    else undefined
        local bmpZ    = if useZBitmap    then openBitmapSafe zBitmapPath    else undefined
        local bmpYPos = if useYPosBitmap then openBitmapSafe yPosBitmapPath else undefined
        local bmpYNeg = if useYNegBitmap then openBitmapSafe yNegBitmapPath else undefined

        -- Pre-load all pixel data into flat arrays (one API call per bitmap)
        local bmpDataX    = preloadBitmapData bmpX
        local bmpDataZ    = preloadBitmapData bmpZ
        local bmpDataYPos = preloadBitmapData bmpYPos
        local bmpDataYNeg = preloadBitmapData bmpYNeg

        closeBitmapSafe bmpX
        closeBitmapSafe bmpZ
        closeBitmapSafe bmpYPos
        closeBitmapSafe bmpYNeg

        -- Pre-cache all UV and mask channels (one pass per channel)
        local uvCacheX    = cacheMapChannel mesh (clampChannel xUVChannel)    nv
        local uvCacheZ    = cacheMapChannel mesh (clampChannel zUVChannel)    nv
        local uvCacheYPos = cacheMapChannel mesh (clampChannel yPosUVChannel) nv
        local uvCacheYNeg = cacheMapChannel mesh (clampChannel yNegUVChannel) nv
        local maskCache   = cacheMapChannel mesh (clampChannel maskChannel)   nv

        -- Compute smooth normals (one pass over faces, one pass over verts)
        local normals = computeAverageNormals mesh

        -- Main displacement loop: pure array lookups and math, no Max API calls
        for i = 1 to nv do
        (
            local p = getVert mesh i

            local delta = computeDelta \
                normals[i] maskCache[i] \
                uvCacheX[i] uvCacheZ[i] uvCacheYPos[i] uvCacheYNeg[i] \
                bmpDataX bmpDataZ bmpDataYPos bmpDataYNeg

            setVert mesh i (p + delta)
        )

        update mesh
    )
)
