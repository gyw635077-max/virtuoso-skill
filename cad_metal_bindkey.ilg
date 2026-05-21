; ============================================================
; Kevin CAD Toolkit - Metal Bindkey
; File:
;   bindkey/cad_metal_bindkey.il
;
; Purpose:
;   Register metal display/change bindkeys automatically
;   according to KevinMetalStack.
;
; Dependency:
;   core/cad_utils.il
;   tools/metal_change.il
;   config/metal_stack_<process>.il
;
; KevinMetalStack data format:
;
;   list(
;     index
;     metal_lpp
;     pin_lpp
;     via_lpp
;     voltage_low_block_lpp
;     voltage_high_block_lpp
;     voltage_low_top_lpp
;     voltage_high_top_lpp
;     normal_key
;     shift_key
;     ctrl_key
;     alt_key
;   )
;
; Key usage:
;   normal_key : show this metal only
;   shift_key  : add this metal visible
;   ctrl_key   : hide this metal
;   alt_key    : change selected object to this metal
; ============================================================


; ------------------------------------------------------------
; Check metal stack
; ------------------------------------------------------------

procedure(kvHasMetalStack()
  boundp('KevinMetalStack) && KevinMetalStack
)


; ------------------------------------------------------------
; Get metal data by index
; ------------------------------------------------------------

procedure(kvGetMetalDataByIndex(idx)
  let((result)
    result = nil

    when(kvHasMetalStack()
      foreach(metalData KevinMetalStack
        when(nth(0 metalData) == idx
          result = metalData
        )
      )
    )

    result
  )
)


; ------------------------------------------------------------
; Metal data accessors
; ------------------------------------------------------------

procedure(kvMetalIndex(metalData)
  nth(0 metalData)
)

procedure(kvMetalLpp(metalData)
  nth(1 metalData)
)

procedure(kvMetalPinLpp(metalData)
  nth(2 metalData)
)

procedure(kvMetalViaLpp(metalData)
  nth(3 metalData)
)

procedure(kvMetalLowBlockLpp(metalData)
  nth(4 metalData)
)

procedure(kvMetalHighBlockLpp(metalData)
  nth(5 metalData)
)

procedure(kvMetalLowTopLpp(metalData)
  nth(6 metalData)
)

procedure(kvMetalHighTopLpp(metalData)
  nth(7 metalData)
)

procedure(kvMetalNormalKey(metalData)
  nth(8 metalData)
)

procedure(kvMetalShiftKey(metalData)
  nth(9 metalData)
)

procedure(kvMetalCtrlKey(metalData)
  nth(10 metalData)
)

procedure(kvMetalAltKey(metalData)
  nth(11 metalData)
)


; ------------------------------------------------------------
; Safe layer operation wrappers
; ------------------------------------------------------------

procedure(kvMetalShowLayer(layer)
  when(kvValidLayer(layer)
    leSetEntryLayer(layer)
  )
)


procedure(kvMetalHideLayer(layer)
  when(kvValidLayer(layer)
    leSetLayerVisible(layer nil)
  )
)


; ------------------------------------------------------------
; Set entry layer to safe layer before hiding all layers
;
; This follows your original working logic:
;   leSetEntryLayer(txt_layer)
;   leSetAllLayerVisible(nil)
;
; Reason:
;   In some Virtuoso environments, if current entry layer is M1,
;   calling leSetAllLayerVisible(nil) may still leave M1 visible.
; ------------------------------------------------------------

procedure(kvSetSafeEntryLayer()
  cond(
    ((boundp('KevinTextLayer) && kvValidLayer(KevinTextLayer))
      leSetEntryLayer(KevinTextLayer)
    )

    (t
      printf("[KV_CAD][METAL][WARN] KevinTextLayer is not defined or invalid.\n")
    )
  )
)


; ------------------------------------------------------------
; Hide all layers safely
; ------------------------------------------------------------

procedure(kvHideAllLayersSafely()
  kvSetSafeEntryLayer()
  leSetAllLayerVisible(nil)
)


; ------------------------------------------------------------
; Hide one metal group
; ------------------------------------------------------------

procedure(kvHideMetalGroup(metalData)
  let((metal pin via vlb vhb vlt vht)

    metal = kvMetalLpp(metalData)
    pin   = kvMetalPinLpp(metalData)
    via   = kvMetalViaLpp(metalData)
    vlb   = kvMetalLowBlockLpp(metalData)
    vhb   = kvMetalHighBlockLpp(metalData)
    vlt   = kvMetalLowTopLpp(metalData)
    vht   = kvMetalHighTopLpp(metalData)

    kvMetalHideLayer(metal)
    kvMetalHideLayer(pin)
    kvMetalHideLayer(via)
    kvMetalHideLayer(vlb)
    kvMetalHideLayer(vhb)
    kvMetalHideLayer(vlt)
    kvMetalHideLayer(vht)
  )
)


; ------------------------------------------------------------
; Show one metal group
; ------------------------------------------------------------

procedure(kvShowMetalGroup(metalData)
  let((metal pin via vlb vhb vlt vht)

    metal = kvMetalLpp(metalData)
    pin   = kvMetalPinLpp(metalData)
    via   = kvMetalViaLpp(metalData)
    vlb   = kvMetalLowBlockLpp(metalData)
    vhb   = kvMetalHighBlockLpp(metalData)
    vlt   = kvMetalLowTopLpp(metalData)
    vht   = kvMetalHighTopLpp(metalData)

    kvMetalShowLayer(vlb)
    kvMetalShowLayer(vhb)
    kvMetalShowLayer(vlt)
    kvMetalShowLayer(vht)

    kvMetalShowLayer(pin)
    kvMetalShowLayer(via)
    kvMetalShowLayer(metal)
  )
)


; ------------------------------------------------------------
; Hide all metal-stack-related layers
; ------------------------------------------------------------

procedure(kvHideAllMetalStackLayers()
  when(kvHasMetalStack()
    foreach(metalData KevinMetalStack
      kvHideMetalGroup(metalData)
    )
  )
)


; ------------------------------------------------------------
; Show all metal-stack-related layers
; Optional debug function.
; ------------------------------------------------------------

procedure(kvShowAllMetalStackLayers()
  when(kvHasMetalStack()
    foreach(metalData KevinMetalStack
      kvShowMetalGroup(metalData)
    )
  )

  hiZoomRelativeScale()
  printf("[KV_CAD][METAL] Show all metal stack layers.\n")
)


; ------------------------------------------------------------
; Show one metal only
;
; Important flow:
;   1. Set entry layer to KevinTextLayer
;   2. Hide all layers
;   3. Explicitly hide all metal stack layers again
;   4. Show KevinTextLayer
;   5. Show target metal group
; ------------------------------------------------------------

procedure(kvShowMetalOnly(metalData)
  let((metal)

    metal = kvMetalLpp(metalData)

    ; Step 1 + Step 2
    kvHideAllLayersSafely()

    ; Step 3
    kvHideAllMetalStackLayers()

    ; Step 4
    when(boundp('KevinTextLayer) && kvValidLayer(KevinTextLayer)
      leSetEntryLayer(KevinTextLayer)
    )

    ; Step 5
    kvShowMetalGroup(metalData)

    hiZoomRelativeScale()

    printf("[KV_CAD][METAL] Show only: %L\n" metal)
  )
)


procedure(kvShowMetalOnlyByIndex(idx)
  let((metalData)
    metalData = kvGetMetalDataByIndex(idx)

    if(metalData then
      kvShowMetalOnly(metalData)
    else
      printf("[KV_CAD][METAL][WARN] Metal index not found: %d\n" idx)
    )
  )
)


; ------------------------------------------------------------
; Add one metal visible without hiding existing layers
; ------------------------------------------------------------

procedure(kvAddMetalVisible(metalData)
  let((metal)

    metal = kvMetalLpp(metalData)

    when(boundp('KevinTextLayer) && kvValidLayer(KevinTextLayer)
      leSetEntryLayer(KevinTextLayer)
    )

    kvShowMetalGroup(metalData)

    hiZoomRelativeScale()

    printf("[KV_CAD][METAL] Add visible: %L\n" metal)
  )
)


procedure(kvAddMetalVisibleByIndex(idx)
  let((metalData)
    metalData = kvGetMetalDataByIndex(idx)

    if(metalData then
      kvAddMetalVisible(metalData)
    else
      printf("[KV_CAD][METAL][WARN] Metal index not found: %d\n" idx)
    )
  )
)


; ------------------------------------------------------------
; Hide one metal group
; ------------------------------------------------------------

procedure(kvHideMetal(metalData)
  let((metal)

    metal = kvMetalLpp(metalData)

    kvSetSafeEntryLayer()
    kvHideMetalGroup(metalData)

    hiZoomRelativeScale()

    printf("[KV_CAD][METAL] Hide: %L\n" metal)
  )
)


procedure(kvHideMetalByIndex(idx)
  let((metalData)
    metalData = kvGetMetalDataByIndex(idx)

    if(metalData then
      kvHideMetal(metalData)
    else
      printf("[KV_CAD][METAL][WARN] Metal index not found: %d\n" idx)
    )
  )
)


; ------------------------------------------------------------
; Change selected objects to one metal
; ------------------------------------------------------------

procedure(kvChangeSelectedToMetal(metalData)
  let((metal)

    metal = kvMetalLpp(metalData)

    if(isCallable('metal_change) then
      metal_change(metal)
    else
      printf("[KV_CAD][METAL][ERROR] metal_change is not callable.\n")
    )
  )
)


procedure(kvChangeSelectedToMetalByIndex(idx)
  let((metalData)
    metalData = kvGetMetalDataByIndex(idx)

    if(metalData then
      kvChangeSelectedToMetal(metalData)
    else
      printf("[KV_CAD][METAL][WARN] Metal index not found: %d\n" idx)
    )
  )
)


; ------------------------------------------------------------
; Show FEOL layers only
; ------------------------------------------------------------

procedure(kvShowFeolOnly()
  kvHideAllLayersSafely()
  kvHideAllMetalStackLayers()

  when(boundp('KevinFeolLayerList) && KevinFeolLayerList
    foreach(layer KevinFeolLayerList
      kvMetalShowLayer(layer)
    )
  )

  hiZoomRelativeScale()

  printf("[KV_CAD][METAL] Show FEOL only.\n")
)


; ------------------------------------------------------------
; Show special signal / pad / power group only
; ------------------------------------------------------------

procedure(kvShowSpecialOnly()
  kvHideAllLayersSafely()
  kvHideAllMetalStackLayers()

  when(boundp('KevinTextLayer) && kvValidLayer(KevinTextLayer)
    kvMetalShowLayer(KevinTextLayer)
  )

  when(boundp('KevinPowerLayer) && kvValidLayer(KevinPowerLayer)
    kvMetalShowLayer(KevinPowerLayer)
  )

  when(boundp('KevinGroundLayer) && kvValidLayer(KevinGroundLayer)
    kvMetalShowLayer(KevinGroundLayer)
  )

  when(boundp('KevinSignalLayer) && kvValidLayer(KevinSignalLayer)
    kvMetalShowLayer(KevinSignalLayer)
  )

  when(boundp('KevinPadLayerList) && KevinPadLayerList
    foreach(layer KevinPadLayerList
      kvMetalShowLayer(layer)
    )
  )

  hiZoomRelativeScale()

  printf("[KV_CAD][METAL] Show special layers only.\n")
)


; ------------------------------------------------------------
; Show all layers
; ------------------------------------------------------------

procedure(kvShowAllLayers()
  leSetAllLayerVisible(t)
  hiZoomRelativeScale()
  printf("[KV_CAD][METAL] Show all layers.\n")
)


; ------------------------------------------------------------
; Register one bindkey safely
; ------------------------------------------------------------

procedure(kvSetMetalBindkey(key cmd)
  when(key && cmd
    hiSetBindKey("Layout" key cmd)
    printf("[KV_CAD][METAL] Bind %-14s -> %s\n" key cmd)
  )
)


; ------------------------------------------------------------
; Register metal bindkeys
; ------------------------------------------------------------

procedure(kvSetupMetalBindkeys()
  let((idx normalKey shiftKey ctrlKey altKey cmd)

    unless(kvHasMetalStack()
      printf("[KV_CAD][METAL][ERROR] KevinMetalStack is not defined.\n")
      return(nil)
    )

    printf("[KV_CAD][METAL] Registering metal bindkeys for %s\n" KevinCurrentProcess)

    foreach(metalData KevinMetalStack

      idx       = kvMetalIndex(metalData)
      normalKey = kvMetalNormalKey(metalData)
      shiftKey  = kvMetalShiftKey(metalData)
      ctrlKey   = kvMetalCtrlKey(metalData)
      altKey    = kvMetalAltKey(metalData)

      when(normalKey
        cmd = sprintf(nil "kvShowMetalOnlyByIndex(%d)" idx)
        kvSetMetalBindkey(normalKey cmd)
      )

      when(shiftKey
        cmd = sprintf(nil "kvAddMetalVisibleByIndex(%d)" idx)
        kvSetMetalBindkey(shiftKey cmd)
      )

      when(ctrlKey
        cmd = sprintf(nil "kvHideMetalByIndex(%d)" idx)
        kvSetMetalBindkey(ctrlKey cmd)
      )

      when(altKey
        cmd = sprintf(nil "kvChangeSelectedToMetalByIndex(%d)" idx)
        kvSetMetalBindkey(altKey cmd)
      )
    )

    ; --------------------------------------------------------
    ; Global display shortcuts
    ; Keep <key> lower-case for current Virtuoso environment.
    ; --------------------------------------------------------

    kvSetMetalBindkey("<key>`"      "kvShowAllLayers()")
    kvSetMetalBindkey("Shift<key>`" "kvShowFeolOnly()")
    kvSetMetalBindkey("<key>="      "kvShowSpecialOnly()")

    printf("[KV_CAD][METAL] Metal bindkeys registered.\n")

    t
  )
)


; ------------------------------------------------------------
; Print current metal bindkey table
; ------------------------------------------------------------

procedure(kvPrintMetalBindkeyTable()
  let((idx metal normalKey shiftKey ctrlKey altKey)

    unless(kvHasMetalStack()
      printf("[KV_CAD][METAL][ERROR] KevinMetalStack is not defined.\n")
      return(nil)
    )

    printf("\n")
    printf("============================================================\n")
    printf("[KV_CAD] Metal Bindkey Table: %s\n" KevinCurrentProcess)
    printf("============================================================\n")

    foreach(metalData KevinMetalStack
      idx       = kvMetalIndex(metalData)
      metal     = kvMetalLpp(metalData)
      normalKey = kvMetalNormalKey(metalData)
      shiftKey  = kvMetalShiftKey(metalData)
      ctrlKey   = kvMetalCtrlKey(metalData)
      altKey    = kvMetalAltKey(metalData)

      printf(
        "M%-2d %-18L  show=%-14s add=%-14s hide=%-14s change=%-14s\n"
        idx metal normalKey shiftKey ctrlKey altKey
      )
    )

    printf("============================================================\n\n")

    t
  )
)


; ------------------------------------------------------------
; Print one metal layer group
; ------------------------------------------------------------

procedure(kvPrintMetalLayerGroup(idx)
  let((metalData)

    metalData = kvGetMetalDataByIndex(idx)

    if(metalData then
      progn(
        printf("\n")
        printf("============================================================\n")
        printf("[KV_CAD] Metal Layer Group: %d\n" idx)
        printf("============================================================\n")
        printf("Metal          : %L\n" kvMetalLpp(metalData))
        printf("Pin            : %L\n" kvMetalPinLpp(metalData))
        printf("Via            : %L\n" kvMetalViaLpp(metalData))
        printf("Low Block      : %L\n" kvMetalLowBlockLpp(metalData))
        printf("High Block     : %L\n" kvMetalHighBlockLpp(metalData))
        printf("Low Top        : %L\n" kvMetalLowTopLpp(metalData))
        printf("High Top       : %L\n" kvMetalHighTopLpp(metalData))
        printf("============================================================\n\n")
      )
    else
      printf("[KV_CAD][METAL][WARN] Metal index not found: %d\n" idx)
    )
  )
)


; ------------------------------------------------------------
; Debug test bindkey
; Example:
;   kvTestBindkey("Ctrl<key>8")
;   kvTestBindkey("<key>#")
; ------------------------------------------------------------

procedure(kvTestBindkey(key)
  let((cmd)
    cmd = sprintf(nil "printf(\"[KV_CAD][TEST] Bindkey works: %s\\n\")" key)
    hiSetBindKey("Layout" key cmd)
    printf("[KV_CAD][TEST] Test bindkey registered: %s\n" key)
  )
)


printf("[KV_CAD] cad_metal_bindkey loaded\n")
