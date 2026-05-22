; ============================================================
; Kevin CAD Toolkit - Bindkey Profiles
; File:
;   bindkey/profile/cad_bindkey_profiles.il
;
; Purpose:
;   Manage optional bindkey profiles.
;
; Profiles:
;   1. kvApplyCustomBindkeyProfile()
;      - Based on your old cusBindKeys()
;      - Lightweight custom profile
;
;   2. kvApplyDefaultBindkeyProfile()
;      - Reserved for large default profile
;      - Not recommended to auto apply because it may override
;        metal bindkeys like <key>1 / <key>2 / <key>3.
;
; Important:
;   This file should be loaded by bootstrap.il,
;   but profile functions should NOT be auto-executed unless needed.
; ============================================================


; ------------------------------------------------------------
; Safe profile bindkey setter
; ------------------------------------------------------------

procedure(kvSetProfileBindkey(app key cmd)
  when(app && key && cmd
    hiSetBindKey(app key cmd)
    printf("[KV_CAD][BINDKEY_PROFILE] Bind %-10s %-16s -> %s\n" app key cmd)
  )
)


; ------------------------------------------------------------
; Apply a list of bindkeys safely
;
; bindkeyList format:
;   list(
;     list("<key>a" "leHiMove()")
;     list("Ctrl<key>q" "QUICK_MOVE()")
;   )
; ------------------------------------------------------------

procedure(kvSetProfileBindkeyList(app bindkeyList)
  let((key cmd)
    foreach(item bindkeyList
      key = nth(0 item)
      cmd = nth(1 item)

      kvSetProfileBindkey(app key cmd)
    )
  )
)


; ------------------------------------------------------------
; Re-register framework critical bindkeys
;
; This should be called after applying any large bindkey profile.
; It protects:
;   - metal display/change bindkeys
;   - main CAD toolkit bindkeys
; ------------------------------------------------------------

procedure(kvRestoreFrameworkBindkeys()
  printf("[KV_CAD][BINDKEY_PROFILE] Restoring framework bindkeys...\n")

  when(isCallable('kvSetupMetalBindkeys)
    kvSetupMetalBindkeys()
  )

  when(isCallable('kvSetupMainBindkeys)
    kvSetupMainBindkeys()
  )

  printf("[KV_CAD][BINDKEY_PROFILE] Framework bindkeys restored.\n")
)


; ------------------------------------------------------------
; Custom bindkey profile
;
; Based on your previous cusBindKeys().
; Notes:
;   - <Key> is changed to <key> for your environment.
;   - F10 calls kvRunEMCalculator() instead of old cusEMGUI().
;   - Ctrl+w uses leHiConvertShapeToPolygon() with parentheses.
;   - "Schematics" is changed to "Schematic".
; ------------------------------------------------------------

procedure(kvApplyCustomBindkeyProfile()
  let((layoutKeys)

    printf("\n")
    printf("============================================================\n")
    printf("[KV_CAD][BINDKEY_PROFILE] Applying Custom Bindkey Profile\n")
    printf("============================================================\n")

    layoutKeys = list(

      ; ------------------------------------------------------
      ; Standard Keys
      ; ------------------------------------------------------

      list("<key>a"       "leHiMove()")
      list("Alt<key>a"    "leHiQuickAlign()")
      list("Shift<key>a"  "geAddSelectBox()")

      list("Alt<key>b"    "leReturn()")

      list("Alt<key>c"    "leHiModifyCorner()")
      list("Ctrl<key>c"   "leHiYank()")

      list("<key>d"       "leHiCreateRuler()")
      list("Shift<key>d"  "leHiClearRuler()")

      list("<key>e"       "leHiCreateWire()")
      list("Shift<key>e"  "leHiEditEditorOptions()")
      list("Ctrl<key>e"   "leHiSize()")

      list("<key>g"       "leCycleSnapModes()")
      list("Shift<key>g"  "leToggleGravity()")

      list("Shift<key>h"  "leHiFlatten()")

      list("<key>n"       "leHiMarkNet()")
      list("Shift<key>n"  "leHiUnmarkNet()")

      list("Shift<key>o"  "leHiCreateGroup()")
      list("Ctrl<key>o"   "leHiUngroup()")

      list("<key>p"       "leHiEditDisplayOptions()")

      list("Alt<key>s"    "geSelectByLine()")

      list("<key>t"       "_leRotateOrFlip(\"MX\")")

      ; Keep your process tool shortcuts
      list("Ctrl<key>u"   "kvRunUpdateBBox()")

      list("<key>v"       "kvRunCrossRuler()")
      list("Alt<key>v"    "leHiAttach()")
      list("Ctrl<key>v"   "leHiPaste()")

      list("Alt<key>w"    "leHiConvertPolygonToPath()")
      list("Ctrl<key>w"   "leHiConvertShapeToPolygon()")
      list("Shift<key>w"  "leHiMerge()")

      list("<key>y"       "_leRotateOrFlip(\"MY\")")

      list("Alt<key>z"    "leHiMoveOrigin()")

      ; ------------------------------------------------------
      ; Special Keys
      ; ------------------------------------------------------

      list("<key>]"       "geChangeEditMode(\"r\")")
      list("<key>["       "geChangeEditMode(\"a\")")
      list("<key>space"   "leHiLayerTap()")
      list("Ctrl<key>space" "leHiDelete()")

      list("<key>F9"      "tsmcPdkGuardRing()")

      ; New framework EM entry
      list("<key>F10"     "kvRunEMCalculator()")
    )

    kvSetProfileBindkeyList("Layout" layoutKeys)

    ; Schematic helper
    kvSetProfileBindkey("Schematic" "<key>0" "geDeleteAllProbe()")

    ; Protect framework bindkeys after applying profile.
    kvRestoreFrameworkBindkeys()

    printf("[KV_CAD][BINDKEY_PROFILE] Custom Bindkey Profile applied.\n")
    printf("============================================================\n\n")

    t
  )
)


; ------------------------------------------------------------
; Compatibility wrapper for old function name
; ------------------------------------------------------------

procedure(cusBindKeys()
  kvApplyCustomBindkeyProfile()
)


; ------------------------------------------------------------
; Default bindkey profile
;
; Important:
;   Your old defaultBindKeys() is very large and overrides many
;   Cadence default keys, including numeric keys.
;
; Recommendation:
;   Do not apply it automatically.
;
; If you want to migrate it later, we should split it into:
;   1. default navigation keys
;   2. default drawing keys
;   3. default assistant / DRD keys
;   4. numeric keypad keys
;
; For now this function is intentionally guarded.
; ------------------------------------------------------------

; ------------------------------------------------------------
; Default bindkey profile
;
; This directly integrates your old defaultBindKeys().
;
; Important:
;   This profile is large and may override metal/main bindkeys.
;   Therefore kvRestoreFrameworkBindkeys() is called at the end.
; ------------------------------------------------------------

procedure(kvApplyDefaultBindkeyProfile()
  let((layoutKeys)

    printf("\n")
    printf("============================================================\n")
    printf("[KV_CAD][BINDKEY_PROFILE] Applying Default Bindkey Profile\n")
    printf("============================================================\n")

    layoutKeys = list(

      ;***************************************************************************
      ; Standard Keys
      ;***************************************************************************

      list("<key>a"             "leHiQuickAlign()")
      list("Shift<key>a"        "geSelectArea()")
      list("Ctrl<key>a"         "geSelectAllFig()")
      list("Ctrl Shift<key>a"   "leHiAddWireVia(hiGetCurrentWindow() \"down\")")

      list("<key>b"             "leReturnToLevel()")
      list("Shift<key>b"        "leReturn()")
      list("Ctrl<key>b"         "leBalloonToggleOnOff()")

      list("<key>c"             "leHiCopy()")
      list("Shift<key>c"        "leHiChop()")

      list("<key>d"             "geSubSelectPoint()")
      list("Shift<key>d"        "geSubSelectBox()")
      list("Ctrl<key>d"         "geDeselectAllFig()")
      list("Ctrl Shift<key>d"   "leHiP2P()")

      list("<key>e"             "leHiEditDisplayOptions()")
      list("Shift<key>e"        "leHiEditEditorOptions()")
      list("Ctrl<key>e"         "leToggleDrdMode()")
      list("Ctrl Shift<key>e"   "leHiAddWireVia(hiGetCurrentWindow() \"targetLayers\")")

      list("<key>f"             "hiZoomAbsoluteScale(hiGetCurrentWindow() 0.9)")
      list("Shift<key>f"        "hiGetCurrentWindow()->stopLevel = dbGetMaxHierDepth()-1")
      list("Ctrl<key>f"         "leSetStopLevelToEditLevel(hiGetCurrentWindow())")

      list("<key>g"             "leToggleGravity()")
      list("Ctrl<key>g"         "geZoomToGrid(hiGetCurrentWindow())")
      list("Shift<key>g"        "leHiCreateGuardRing()")
      list("Ctrl Shift<key>g"   "weGatherBusWires(hiGetCurrentWindow())")

      list("<key>h"             "leHiRepeatCopy()")
      list("Ctrl Shift<key>h"   "drdCompactSelSet('left)")

      list("<key>i"             "leHiCreateInst()")
      list("Ctrl<key>i"         "leBalloonCycleThru()")
      list("Shift<key>i"        "leHiGuidedRoutingReverseEnvelope(hiGetCurrentWindow())")
      list("<key>]"             "leConvertIBToDSIB()")

      list("<key>j"             "geSelObjectsPartiallySelected()")
      list("Ctrl<key>j"         "leHiFlip()")
      list("Ctrl Shift<key>j"   "drdCompactSelSet('right)")

      list("<key>k"             "leHiCreateMeasurement()")
      list("Shift<key>k"        "leHiClearMeasurement()")
      list("Ctrl Shift<key>k"   "leHiClearMeasurementInHier()")
      list("Ctrl<key>k"         "leToggleKeepFirstName()")

      list("<key>l"             "leHiCreateLabel(hiGetCurrentWindow() leGetEnv(\"labelMode\"))")
      list("Ctrl<key>l EF"      "weCWHoldWidth()")

      list("<key>m"             "leHiMove()")
      list("Shift<key>m"        "leHiMerge()")

      list("<key>n"             "leCycleSnapModes()")
      list("Shift<key>n"        "leGetCoordinateForm()")
      list("Ctrl<key>n"         "leSetFormSnapMode(\"L90XFirst\")")
      list("Ctrl Shift<key>n"   "drdCompactSelSet('bottom)")

      list("<key>o"             "leHiCreateVia()")
      list("Shift<key>o"        "leHiRotate()")
      list("Ctrl<key>o"         "geSelectViaPile()")

      list("<key>p"             "leHiCreateWire()")
      list("Shift<key>p"        "leHiCreatePolygon()")
      list("Ctrl<key>p"         "leHiCreatePin()")

      list("<key>q"             "leHiEditProp()")
      list("Shift<key>q"        "leEditDesignProperties()")
      list("Ctrl Shift<key>q"   "leHiAddWireVia(hiGetCurrentWindow() \"up\")")
      list("Ctrl<key>q"         "kvRunQuickMove()")

      list("<key>r"             "leHiCreateRect()")
      list("Shift<key>r"        "leHiReShape()")
      list("Ctrl<key>r"         "hiRedraw()")

      list("<key>s"             "leHiStretch()")
      list("Shift<key>s"        "leHiSearch()")
      list("Ctrl<key>s"         "leHiSplit()")
      list("Ctrl Shift<key>s"   "leHiGuidedRouting()")

      list("<key>t"             "leHiLayerTap()")
      list("Shift<key>t"        "leHiTree()")
      list("Ctrl<key>t"         "leZoomToSelSet()")
      list("Ctrl Shift<key>t"   "drdCompactSelSet('target)")

      list("<key>u"             "hiUndo()")
      list("Shift<key>u"        "hiRedo()")
      list("Ctrl Shift<key>u"   "drdCompactSelSet('top)")

      list("<key>v"             "leHiAttach()")
      list("Shift<key>v"        "deToggleAssistantVisibility(\"World View\")")
      list("Ctrl<key>v"         "hiFocusToCIW(hiGetCurrentWindow())")
      list("Ctrl Shift<key>v"   "leFinishWire()")

      list("<key>w"             "hiPrevWinView(hiGetCurrentWindow())")
      list("Shift<key>w"        "hiNextWinView(hiGetCurrentWindow())")
      list("Ctrl<key>w"         "leCloseWindow()")
      list("Ctrl Shift<key>w"   "leHiCreateWire()")

      list("<key>x"             "leHiEditInPlace()")
      list("Shift<key>x"        "leHiDescend()")
      list("Ctrl<key>x"         "leEIPZoomAbsoluteScale(hiGetCurrentWindow() 0.9)")
      list("Ctrl Shift<key>x"   "leHiCreateBus()")

      list("<key>y"             "leHiYank()")
      list("Shift<key>y"        "leHiPaste()")
      list("Ctrl<key>y"         "geCycleSelectNext()")

      list("<key>z"             "hiZoomIn()")
      list("Shift<key>z"        "hiZoomRelativeScale(hiGetCurrentWindow() 0.5)")
      list("Ctrl<key>z"         "hiZoomRelativeScale(hiGetCurrentWindow() 2.0)")
      list("Ctrl Shift<key>z"   "leWECycleControlWire()")

      list("<DrawThru2>"        "hiDynamicPanGrabbing()")

      ; These may be overridden later by metal bindkeys.
      list("<key>2"             "leFinishTrunk()")
      list("<key>3"             "_iaSelectAreaAndRoute()")

      ;***************************************************************************
      ; Special Keys
      ;***************************************************************************

      list("<key>Escape EF"     "cancelEnterFun()")
      list("<key>Delete EF"     "leHiDelete()")
      list("<key>Delete"        "leHiDelete()")
      list("<key>Tab"           "hiPan()")
      list("<key>Tab EF"        "leSetFocusToEditableFieldsInStatusToolbar(hiGetCurrentWindow())")

      list("<key>F3"            "leHiSaveACopy(hiGetCurrentWindow())")
      list("<key>F3 EF"         "hiToggleEnterForm()")
      list("<key>F2"            "geSave()")
      list("<key>F5"            "ddsHiRefresh()")
      list("Shift<key>F5"       "leFullSelectFigOfSelSet()")
      list("<key>F6"            "leToggleMaintainConnections()")
      list("<key>F7"            "leHiEditDRDRuleOptions()")
      list("<key>F9"            "geToggleFilterSize()")
      list("<key>F10"           "kvRunEMCalculator()")
      list("<key>F11"           "deToggleAssistants()")
      list("Ctrl<key>F11"       "deToggleToolbars()")
      list("Shift<key>F11"      "deToggleToolbars() deToggleAssistants()")

      list("<key>BackSpace"     "deletePoint()")
      list("<key>` EF"          "drdToggleSmartSnapMode()")
      list("Shift<key>` EF"     "drdToggleSmartSnapModeForDiscreteSpacing()")
      list("<key>1 EF"          "drdEnablePixelThreshold(!drdIsPixelThresholdEnabled())")

      ;***************************************************************************
      ; Numeric Key Pad / Panning
      ;***************************************************************************

      list("<key>R7"            "geScroll(nil \"nw\" nil)")
      list("<key>Up"            "geScroll(nil \"n\" nil)")
      list("<key>R9"            "geScroll(nil \"ne\" nil)")
      list("<key>Left"          "geScroll(nil \"w\" nil)")
      list("<key>R11"           "geScroll(nil \"\" nil)")
      list("<key>Right"         "geScroll(nil \"e\" nil)")
      list("<key>R13"           "geScroll(nil \"sw\" nil)")
      list("<key>Down"          "geScroll(nil \"s\" nil)")
      list("<key>R15"           "geScroll(nil \"se\" nil)")

      list("<key>KP_Enter"      "mouseAddPt()")
      list("<key>KP_Add"        "leHiSetRefPoint()")
      list("<key>KP_Subtract"   "leSetRefPointInactive(geGetEditCellView())")

      list("<key>KP_Equal"      "legRpDelta = 0.5")
      list("<key>KP_Divide"     "drdAddTarget()")
      list("<key>KP_Divide EF"  "drdAddTarget()")
      list("<key>KP_Multiply"   "drdRemoveTarget()")
      list("<key>KP_Multiply EF" "drdRemoveTarget()")

      list("<key>R4"            "legRpDelta = 0.5")
      list("<key>R5"            "legRpDelta = 1.0")
      list("<key>R6"            "legRpDelta = 2.0")

      list("Shift<key>R7"       "leMoveCursor(-legRpDelta  legRpDelta)")
      list("Shift<key>Up"       "leMoveCursor(0 legRpDelta)")
      list("Shift<key>R9"       "leMoveCursor(legRpDelta legRpDelta)")
      list("Shift<key>Left"     "leMoveCursor(-legRpDelta 0)")
      list("Shift<key>R11"      "leMoveCursorToRefPoint()")
      list("Shift<key>Right"    "leMoveCursor(legRpDelta 0)")
      list("Shift<key>R13"      "leMoveCursor(-legRpDelta -legRpDelta)")
      list("Shift<key>Down"     "leMoveCursor(0 -legRpDelta)")
      list("Shift<key>R15"      "leMoveCursor(legRpDelta -legRpDelta)")

      list("Ctrl<key>R7"        "geScroll(nil \"nw\" t)")
      list("Ctrl<key>Up"        "geScroll(nil \"n\" t)")
      list("Ctrl<key>R9"        "geScroll(nil \"ne\" t)")
      list("Ctrl<key>Left"      "geScroll(nil \"w\" t)")
      list("Ctrl<key>R11"       "geScroll(nil \"\" t)")
      list("Ctrl<key>Right"     "geScroll(nil \"e\" t)")
      list("Ctrl<key>R13"       "geScroll(nil \"sw\" t)")
      list("Ctrl<key>Down"      "geScroll(nil \"s\" t)")
      list("Ctrl<key>R15"       "geScroll(nil \"se\" t)")

      list("<key>space"         "leHiAddWireVia(hiGetCurrentWindow())")
      list("Ctrl<key>space"     "(leWECycleSnap)")
      list("Ctrl Shift<key>space" "(leWENoSnap)")
      list("<key>space EF"      "leSpaceBarFunc(hiGetCurrentWindow() t)")
      list("Shift<key>space EF" "leSpaceBarFunc(hiGetCurrentWindow() t t)")
      list("Ctrl<key>space EF"  "leSpaceBarFunc(hiGetCurrentWindow() \"cancel\")")
      list("Ctrl Shift <key>space EF" "leSpaceBarFunc(hiGetCurrentWindow() \"ctrlShift\")")

      list("<key>."             "leToggleMagnifier()")
      list("<key>#"             "hiToggleAnchorMagnifier()")
      list("<key>'"             "hiUpdateMagOptions()")

      list("Ctrl Shift<Btn1Down>" "hiZoomInMagnifier(hiGetCurrentWindow())")
      list("Ctrl Shift<Btn2Down>" "hiZoomOutMagnifier(hiGetCurrentWindow())")
      list("Ctrl Shift<Btn4Down> EF" "weScaleMagnifierOrIncreaseWidth()")
      list("Ctrl Shift<Btn5Down> EF" "weScaleMagnifierOrDecreaseWidth()")
      list("Ctrl<Btn4Down> EF" "weScrollOrCycleUpWireViaAlignment()")
      list("Ctrl<Btn5Down> EF" "weScrollOrCycleDownWireViaAlignment()")

      list("Ctrl Shift<key>Up"    "hiScaleMagnifier(1.25)")
      list("Ctrl Shift<key>Down"  "hiScaleMagnifier(0.80)")
      list("<key>+"               "leIncrementStopLevelByOne(hiGetCurrentWindow())")
      list("<key>-"               "leDecrementStopLevelByOne(hiGetCurrentWindow())")
    )

    kvSetProfileBindkeyList("Layout" layoutKeys)

    ; Schematic helper
    kvSetProfileBindkey("Schematic" "<key>0" "geDeleteAllProbe()")

    ; Very important:
    ; restore framework keys after applying large default profile.
    kvRestoreFrameworkBindkeys()

    printf("[KV_CAD][BINDKEY_PROFILE] Default Bindkey Profile applied.\n")
    printf("============================================================\n\n")

    t
  )
)


; ------------------------------------------------------------
; Compatibility wrapper for old function name
; ------------------------------------------------------------

procedure(defaultBindKeys()
  kvApplyDefaultBindkeyProfile()
)


; ------------------------------------------------------------
; Print bindkey profile help
; ------------------------------------------------------------

procedure(kvPrintBindkeyProfileHelp()
  printf("\n")
  printf("============================================================\n")
  printf("[KV_CAD] Bindkey Profile Help\n")
  printf("============================================================\n")
  printf("kvApplyCustomBindkeyProfile()   : Apply custom bindkey profile\n")
  printf("kvApplyDefaultBindkeyProfile()  : Default profile guard / warning\n")
  printf("kvRestoreFrameworkBindkeys()    : Re-register metal/main bindkeys\n")
  printf("cusBindKeys()                   : Compatibility wrapper\n")
  printf("defaultBindKeys()               : Compatibility wrapper\n")
  printf("============================================================\n\n")

  t
)


printf("[KV_CAD] cad_bindkey_profiles loaded\n")
