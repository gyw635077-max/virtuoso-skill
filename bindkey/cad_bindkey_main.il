; ============================================================
; Kevin CAD Toolkit - Main Bindkeys
; File:
;   bindkey/cad_bindkey_main.il
;
; Purpose:
;   Register non-metal CAD utility bindkeys.
;
; Note:
;   Metal display/change bindkeys are handled by:
;     bindkey/cad_metal_bindkey.il
;
;   This file should avoid overriding:
;     <key>1 ~ <key>0
;     Shift<key>1 ~ Shift<key>0
;     Ctrl<key>1 ~ Ctrl<key>0
;     Alt<key>1 ~ Alt<key>0
; ============================================================


; ------------------------------------------------------------
; Safe bindkey register
; ------------------------------------------------------------

procedure(kvSetMainBindkey(app key cmd)
  when(app && key && cmd
    hiSetBindKey(app key cmd)
    printf("[KV_CAD][MAIN_BINDKEY] Bind %-10s %-16s -> %s\n" app key cmd)
  )
)


; ------------------------------------------------------------
; Safe callable wrapper
; This is useful for optional tools.
; ------------------------------------------------------------

procedure(kvCallIfCallable(funcSym)
  if(isCallable(funcSym) then
    funcall(funcSym)
  else
    printf("[KV_CAD][MAIN_BINDKEY][WARN] Function is not callable: %L\n" funcSym)
  )
)


; ------------------------------------------------------------
; Wrapper functions for optional tools
; ------------------------------------------------------------

procedure(kvRunEMCalculator()
  if(isCallable('kvEMGUI) then
    kvEMGUI()
  else
    printf("[KV_CAD][MAIN_BINDKEY][WARN] kvEMGUI is not callable. EM tool is not loaded.\n")
  )
)


procedure(kvRunQuickMove()
  if(isCallable('QUICK_MOVE) then
    QUICK_MOVE()
  else
    printf("[KV_CAD][MAIN_BINDKEY][WARN] QUICK_MOVE is not callable. Quick Move tool is not loaded.\n")
  )
)


procedure(kvRunZoomToPoint()
  if(isCallable('Zoom_To_Point) then
    Zoom_To_Point()
  else
    printf("[KV_CAD][MAIN_BINDKEY][WARN] Zoom_To_Point is not callable. Zoom tool is not loaded.\n")
  )
)


procedure(kvRunUpdateBBox()
  if(isCallable('ts_update_bbox) then
    ts_update_bbox()
  else
    printf("[KV_CAD][MAIN_BINDKEY][WARN] ts_update_bbox is not callable.\n")
  )
)


procedure(kvRunCrossRuler()
  if(isCallable('ts_cross_ruler) then
    ts_cross_ruler()
  else
    printf("[KV_CAD][MAIN_BINDKEY][WARN] ts_cross_ruler is not callable.\n")
  )
)


procedure(kvRunCreateLogo()
  if(isCallable('leCreatePgTextForm) then
    leCreatePgTextForm()
  else
    printf("[KV_CAD][MAIN_BINDKEY][WARN] leCreatePgTextForm is not callable.\n")
  )
)


procedure(kvRunRefreshWin()
  if(isCallable('refreshWin) then
    refreshWin()
  else
    printf("[KV_CAD][MAIN_BINDKEY][WARN] refreshWin is not callable.\n")
  )
)


procedure(kvRunDNWNWENCLOSURE()
  if(isCallable('TrCreateRectNwDnw) then
    TrCreateRectNwDnw()
  else
    printf("[KV_CAD][MAIN_BINDKEY][WARN] TrCreateRectNwDnw is not callable.\n")
  )
)


procedure(kvRunEMCalculator()
  if(isCallable('kvEMGUI) then
    kvEMGUI()
  else
    printf("[KV_CAD][MAIN_BINDKEY][WARN] kvEMGUI is not callable. EM tool is not loaded.\n")
  )
)
; ------------------------------------------------------------
; Register main layout bindkeys
; ------------------------------------------------------------

procedure(kvSetupMainBindkeys()

  printf("[KV_CAD][MAIN_BINDKEY] Registering main bindkeys...\n")

  ; ----------------------------------------------------------
  ; Basic Virtuoso operations
  ; ----------------------------------------------------------

  kvSetMainBindkey("Layout" "<key>F5" "ddsHiRefresh()")
  kvSetMainBindkey("Layout" "Ctrl<key>r" "hiRedraw()")
  ; ----------------------------------------------------------
; Refresh window by mouse right button
; ----------------------------------------------------------

kvSetMainBindkey("Layout"    "<Btn3Down>" "kvRunRefreshWin()")
kvSetMainBindkey("Schematic" "<Btn3Down>" "kvRunRefreshWin()")
  ; ----------------------------------------------------------
  ; Optional CAD tools
  ; ----------------------------------------------------------

  kvSetMainBindkey("Layout" "<key>F10" "kvRunEMCalculator()")
  kvSetMainBindkey("Layout" "Ctrl<key>q" "kvRunQuickMove()")
  kvSetMainBindkey("Layout" "Ctrl<key>u" "kvRunUpdateBBox()")
  kvSetMainBindkey("Layout" "<key>v" "kvRunCrossRuler()")
  kvSetMainBindkey("Layout" "Ctrl<key>z" "kvRunZoomToPoint()")
  kvSetMainBindkey("Layout" "Ctrl<key>j" "kvRunGenerateBlock()")
  kvSetMainBindkey("Layout" "Ctrl<key>l" "kvRunDNWNWENCLOSURE()") 

  ; ----------------------------------------------------------
  ; Menu / status helpers
  ; ----------------------------------------------------------

  kvSetMainBindkey("Layout" "Shift<key>F10" "kvPrintCadStatus()")

  when(isCallable('kvShowProcessSettingForm)
    kvSetMainBindkey("Layout" "Shift<key>F12" "kvShowProcessSettingForm()")
  )

  ; ----------------------------------------------------------
  ; Schematic helper
  ; ----------------------------------------------------------

  kvSetMainBindkey("Schematic" "<key>0" "geDeleteAllProbe()")

  printf("[KV_CAD][MAIN_BINDKEY] Main bindkeys registered.\n")

  t
)


procedure(kvRunGenerateBlock()
  if(isCallable('kvGenerateBlockForm) then
    kvGenerateBlockForm()
  else
    printf("[KV_CAD][MAIN_BINDKEY][WARN] kvGenerateBlockForm is not callable.\n")
  )
)

; ------------------------------------------------------------
; Print main bindkey summary
; ------------------------------------------------------------

procedure(kvPrintMainBindkeyHelp()
  printf("\n")
  printf("============================================================\n")
  printf("[KV_CAD] Main Bindkey Help\n")
  printf("============================================================\n")
  printf("Layout <key>F5        : Refresh\n")
  printf("Layout Ctrl<key>r     : Redraw\n")
  printf("Layout <key>F10       : EM Calculator\n")
  printf("Layout Ctrl<key>q     : Quick Move\n")
  printf("Layout Ctrl<key>u     : Update BBox\n")
  printf("Layout <key>v         : Cross Ruler\n")
  printf("Layout Ctrl<key>z     : Zoom To Point\n")
  printf("Layout Shift<key>F10  : Print CAD Status\n")
  printf("Layout Shift<key>F12  : Process Setting Form\n")
  printf("Schematic <key>0      : Delete All Probe\n")
  printf("============================================================\n\n")

  t
)


printf("[KV_CAD] cad_bindkey_main loaded\n")
