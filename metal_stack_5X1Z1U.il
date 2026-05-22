; ============================================================
; Kevin CAD Toolkit Metal Stack Config
; Process:
;   T22_5X1Z1U
;
; File:
;   config/metal_stack_T22_5X1Z1U.il
;
; Purpose:
;   Define metal / pin / via / block / top layer information
;   for process T22_5X1Z1U.
;
; Data Format of KevinMetalStack:
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
; key Usage:
;   normal_key : show this metal only
;   shift_key  : add this metal visible
;   ctrl_key   : hide this metal
;   alt_key    : change selected objects to this metal
; ============================================================


; ------------------------------------------------------------
; Current process name
; ------------------------------------------------------------

KevinCurrentProcess = "T22_5X1Z1U"


; ------------------------------------------------------------
; Special display layers
; These layers are used by global layer display shortcuts.
; Please modify them according to the real PDK layer names.
; ------------------------------------------------------------

KevinTextLayer   = list("text" "drawing")
KevinPowerLayer  = list("VDDDMY"  "drawing")
KevinGroundLayer = list("VSSDMY"  "drawing")
KevinSignalLayer = list("text"  "drawing")

KevinPadLayerList = list(
  list("CB2_FC" "drawing")
  list("CB2" "drawing")
  list("PM" "drawing")
  list("UBM" "drawing")
)

; ------------------------------------------------------------
; FEOL alias table
;
; Format:
;   list(aliasName lpp)
; ------------------------------------------------------------

KevinFeolAliasTable = list(
  list("NW"  list("NW"  "drawing"))
  list("DNW" list("DNW" "drawing"))
  list("OD"  list("OD"  "drawing"))
  list("PO"  list("PO"  "drawing"))
)




; ------------------------------------------------------------
; FEOL layers
; These are used for FEOL-only display.
; Please modify them according to the real PDK layer names.
; ------------------------------------------------------------

KevinFeolLayerList = list(
  list("NW"  "drawing")
  list("DNW" "drawing")
  list("PP"  "drawing")
  list("NP"  "drawing")
  list("OD"  "drawing")
  list("CO"  "drawing")
  list("PO"  "drawing")
  list("M1"  "drawing")
)


; ------------------------------------------------------------
; Metal stack
;
; For T22_5X1Z1U example:
;   M1  - M6 : X metal
;   M7       : Z metal
;   M8       : U metal
;   AP       : AP metal
;
; You can adjust the real metal stack according to your PDK.
; ------------------------------------------------------------

KevinMetalStack = list(

  list(1
       list("M1" "drawing")
       list("M1" "pin")
       list("VIA1" "drawing")
       list("M1" "test0")
       list("M1" "test1")
       list("M1" "test2")
       list("M1" "test3")
       "<key>1"
       "Shift<key>1"
       "Ctrl<key>1"
       "Alt<key>1"
  )

  list(2
       list("M2" "drawing")
       list("M2" "pin")
       list("VIA2" "drawing")
       list("M2" "test0")
       list("M2" "test1")
       list("M2" "test2")
       list("M2" "test3")
       "<key>2"
       "Shift<key>2"
       "Ctrl<key>2"
       "Alt<key>2"
  )

  list(3
       list("M3" "drawing")
       list("M3" "pin")
       list("VIA3" "drawing")
       list("M3" "test0")
       list("M3" "test1")
       list("M3" "test2")
       list("M3" "test3")
       "<key>3"
       "<key>#"
       "Ctrl<key>3"
       "Alt<key>3"
  )

  list(4
       list("M4" "drawing")
       list("M4" "pin")
       list("VIA4" "drawing")
       list("M4" "test0")
       list("M4" "test1")
       list("M4" "test2")
       list("M4" "test3")
       "<key>4"
       "Shift<key>4"
       "Ctrl<key>4"
       "Alt<key>4"
  )

  list(5
       list("M5" "drawing")
       list("M5" "pin")
       list("VIA5" "drawing")
       list("M5" "test0")
       list("M5" "test1")
       list("M5" "test2")
       list("M5" "test3")
       "<key>5"
       "Shift<key>5"
       "Ctrl<key>5"
       "Alt<key>5"
  )

  list(6
       list("M6" "drawing")
       list("M6" "pin")
       list("VIA6" "drawing")
       list("M6" "test0")
       list("M6" "test1")
       list("M6" "test2")
       list("M6" "test3")
       "<key>6"
       "Shift<key>6"
       "Ctrl<key>6"
       "Alt<key>6"
  )

  list(7
       list("M7" "drawing")
       list("M7" "pin")
       list("VIA7" "drawing")
       list("M7" "test0")
       list("M7" "test1")
       list("M7" "test2")
       list("M7" "test3")
       "<key>7"
       "Shift<key>7"
       "Ctrl<key>7"
       "Alt<key>7"
  )

  list(8
       list("M8" "drawing")
       list("M8" "pin")
       list("VIA8" "drawing")
       list("M8" "test0")
       list("M8" "test1")
       list("M8" "test2")
       list("M8" "test3")
       "<key>8"
       "Shift<key>8"
       "Ctrl<key>8"
       "Alt<key>8"
  )

  list(9
       list("AP" "drawing")
       list("AP" "pin")
       list("RV" "drawing")
       list("AP" "test1")
       list("AP" "test2")
       list("AP" "test1")
       list("AP" "test2")
       "<key>9"
       "<key>("
       "Ctrl<key>9"
       "Alt<key>9"
  )


)


; ------------------------------------------------------------
; Utility print function for current metal stack
; ------------------------------------------------------------

procedure(kvPrintMetalStack()
  let((idx metal pin via)

    printf("\n")
    printf("============================================================\n")
    printf("[KV_CAD] Metal Stack: %s\n" KevinCurrentProcess)
    printf("============================================================\n")

    foreach(metalData KevinMetalStack
      idx   = nth(0 metalData)
      metal = nth(1 metalData)
      pin   = nth(2 metalData)
      via   = nth(3 metalData)

      printf("M%-2d  metal=%L  pin=%L  via=%L\n" idx metal pin via)
    )

    printf("============================================================\n\n")
  )
)


printf("[KV_CAD] metal_stack_T22_5X1Z1U loaded\n")
printf("[KV_CAD] Metal count: %d\n" length(KevinMetalStack))
