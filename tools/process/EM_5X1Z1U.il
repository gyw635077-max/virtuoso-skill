; ============================================================
; Kevin CAD Toolkit - EM Calculator
; Process:
;   T28_1P10M5X2Y2R
;
; File:
;   tools/process/em/EM_T28_1P10M5X2Y2R.il
;
; Purpose:
;   Process-specific EM calculator.
;
; Public Entry:
;   kvEMGUI()
;
; Compatibility Entry:
;   cusEMGUI()
;
; Notes:
;   This EM calculator is intentionally process-specific.
;   Different process / metal option can use different EM files.
; ============================================================


; ------------------------------------------------------------
; EM tool name
; ------------------------------------------------------------

KevinEMToolName = "T28_1P10M5X2Y2R"


; ------------------------------------------------------------
; Get temperature derating factor
; ------------------------------------------------------------

procedure(kvEMGetTempFactor_T28(material temp)
  let((Cu_Tlist Al_Tlist item factor)

    factor = nil

    Cu_Tlist = list(
      list("100" 2.077)
      list("105" 1.434)
      list("110" 1.000)
      list("115" 0.704)
      list("120" 0.500)
      list("125" 0.358)
    )

    Al_Tlist = list(
      list("100" 1.329)
      list("105" 1.151)
      list("110" 1.000)
      list("115" 0.872)
      list("120" 0.764)
      list("125" 0.671)
    )

    cond(
      ((material == "Cu")
        foreach(item Cu_Tlist
          when(car(item) == temp
            factor = cadr(item)
          )
        )
      )

      ((material == "Al")
        foreach(item Al_Tlist
          when(car(item) == temp
            factor = cadr(item)
          )
        )
      )
    )

    unless(factor
      printf("[KV_CAD][EM][WARN] Temperature factor not found. material=%s temp=%s, use 1.0\n"
             material temp)
      factor = 1.0
    )

    factor
  )
)


; ------------------------------------------------------------
; Calculate EM current and resistance
;
; Input:
;   w    : width, um
;   l    : length, um
;   temp : temperature string, for example "110"
;
; Output:
;   list of report rows:
;     list("M1" "0.05/4.5" "xx.xx" "xx.xx")
; ------------------------------------------------------------

procedure(kvCalculateEM_T28_1P10M5X2Y2R(w l temp)
  let((teRat temRat
       M1EM MxEM MyEM MrEM APEM
       m1em_final mxem_final myem_final mrem_final apem_final
       M1EM_str MxEM_str MyEM_str MrEM_str APEM_str
       M1R MxR MyR MrR APR
       resultList)

    ; --------------------------------------------------------
    ; Basic input guard
    ; --------------------------------------------------------

    cond(
      ((w == nil || l == nil)
        printf("[KV_CAD][EM][ERROR] Width or length is nil.\n")
        return(nil)
      )

      ((w <= 0 || l <= 0)
        printf("[KV_CAD][EM][ERROR] Width and length must be greater than 0. W=%L L=%L\n" w l)
        return(nil)
      )
    )

    ; --------------------------------------------------------
    ; Temperature factors
    ; Cu: M1/Mx/My/Mr
    ; Al: AP
    ; --------------------------------------------------------

    teRat  = kvEMGetTempFactor_T28("Cu" temp)
    temRat = kvEMGetTempFactor_T28("Al" temp)

    ; --------------------------------------------------------
    ; Base EM current calculation
    ; Unit: mA
    ; --------------------------------------------------------

    M1EM = 0.996 * (w * 0.9 - 0.003) * teRat
    MxEM = 0.996 * (w * 0.9 - 0.003) * teRat
    MyEM = 2.208 * (w * 0.9 - 0.016) * teRat
    MrEM = 12.631 * (w * 0.9 - 0.020) * teRat
    APEM = 5.790 * w * 0.9 * temRat

    ; --------------------------------------------------------
    ; Default final values
    ; --------------------------------------------------------

    m1em_final = M1EM
    mxem_final = MxEM
    myem_final = MyEM
    mrem_final = MrEM
    apem_final = APEM

    ; --------------------------------------------------------
    ; Length-based current adjustment for My metal
    ;
    ; Original logic:
    ;   L <= 5              -> 4x
    ;   L > 5 and W >= 0.5  -> 2x
    ;   5 < L <= 10 W < 0.5 -> 1.5x
    ;   L > 10 W < 0.5      -> 1x
    ; --------------------------------------------------------

    cond(
      ((l <= 5)
        myem_final = 4 * MyEM
      )

      ((l > 5) && (w >= 0.5)
        myem_final = 2 * MyEM
      )

      ((l > 5) && (l <= 10) && (w < 0.5)
        myem_final = 1.5 * MyEM
      )

      ((l > 10) && (w < 0.5)
        myem_final = MyEM
      )
    )

    ; --------------------------------------------------------
    ; Length-based current adjustment for M1 / Mx / Mr
    ;
    ; Original logic:
    ;   L <= 5                      -> M1/Mx/Mr = 4x
    ;   5 < L <= 10 and W >= 0.1    -> M1/Mx = 2x, Mr = 1.5x
    ;   5 < L <= 10 and W < 0.1     -> M1/Mx = 1x, Mr = 1.5x
    ;   L > 10 and W >= 0.1         -> M1/Mx = 2x, Mr = 1x
    ;   L > 10 and W < 0.1          -> M1/Mx/Mr = 1x
    ; --------------------------------------------------------

    cond(
      ((l <= 5)
        m1em_final = M1EM * 4
        mxem_final = MxEM * 4
        mrem_final = MrEM * 4
      )

      ((l > 5) && (l <= 10) && (w >= 0.1)
        m1em_final = M1EM * 2
        mxem_final = MxEM * 2
        mrem_final = MrEM * 1.5
      )

      ((l > 5) && (l <= 10) && (w < 0.1)
        m1em_final = M1EM
        mxem_final = MxEM
        mrem_final = MrEM * 1.5
      )

      ((l > 10) && (w >= 0.1)
        m1em_final = M1EM * 2
        mxem_final = MxEM * 2
        mrem_final = MrEM
      )

      ((l > 10) && (w < 0.1)
        m1em_final = M1EM
        mxem_final = MxEM
        mrem_final = MrEM
      )
    )

    ; --------------------------------------------------------
    ; Format current strings
    ; --------------------------------------------------------

    sprintf(M1EM_str "%.2f" m1em_final)
    sprintf(MxEM_str "%.2f" mxem_final)
    sprintf(MyEM_str "%.2f" myem_final)
    sprintf(MrEM_str "%.2f" mrem_final)
    sprintf(APEM_str "%.2f" apem_final)

    ; --------------------------------------------------------
    ; Resistance calculation
    ; Unit: ohm
    ; --------------------------------------------------------

    sprintf(M1R "%.2f" 0.550  * (l / w))
    sprintf(MxR "%.2f" 0.550  * (l / w))
    sprintf(MyR "%.2f" 0.182  * (l / w))
    sprintf(MrR "%.2f" 0.0167 * (l / w))
    sprintf(APR "%.2f" 0.0104 * (l / w))

    ; --------------------------------------------------------
    ; Report rows
    ; --------------------------------------------------------

    resultList = list(
      list("M1"  "0.05/4.5"  M1EM_str M1R)
      list("M2"  "0.05/4.5"  MxEM_str MxR)
      list("M3"  "0.05/4.5"  MxEM_str MxR)
      list("M4"  "0.05/4.5"  MxEM_str MxR)
      list("M5"  "0.05/4.5"  MxEM_str MxR)
      list("M6"  "0.05/4.5"  MxEM_str MxR)
      list("M7"  "0.1/12.0"  MyEM_str MyR)
      list("M8"  "0.1/12.0"  MyEM_str MyR)
      list("M9"  "2.0/12.0"  MrEM_str MrR)
      list("M10" "2.0/12.0"  MrEM_str MrR)
      list("AP"  "2.0/35.0"  APEM_str APR)
    )

    resultList
  )
)


; ------------------------------------------------------------
; Update EM report table
; ------------------------------------------------------------

procedure(kvUpdateEMReport_T28()
  let((form w l temp resultList)

    form = hiGetCurrentForm()

    unless(form
      printf("[KV_CAD][EM][ERROR] No current EM form.\n")
      return(nil)
    )

    w = form->width->value
    l = form->leng->value
    temp = form->temp->value

    resultList = kvCalculateEM_T28_1P10M5X2Y2R(w l temp)

    when(resultList
      form->Result->choices = resultList
    )

    t
  )
)


; ------------------------------------------------------------
; EM GUI
; Public entry for menu / bindkey:
;   kvEMGUI()
; ------------------------------------------------------------

procedure(kvEMGUI()
  let((width_GUI length_GUI temp_GUI report_GUI tech_GUI note_GUI)

    width_GUI = hiCreateFloatField(
      ?name 'width
      ?prompt "Width:"
      ?value 4.0
    )

    length_GUI = hiCreateFloatField(
      ?name 'leng
      ?prompt "Length:"
      ?value 20.0
    )

    temp_GUI = hiCreateCyclicField(
      ?name 'temp
      ?prompt "Temperature:"
      ?value "110"
      ?choices list("100" "105" "110" "115" "120" "125")
    )

    tech_GUI = hiCreateOutputStringField(
      ?name 'tech
      ?prompt "Technology:"
      ?value KevinEMToolName
    )

    note_GUI = hiCreateOutputStringField(
      ?name 'note
      ?prompt "Note:"
      ?value "W/L unit: um, Current unit: mA, Resistance unit: ohm"
    )

    report_GUI = hiCreateReportField(
      ?name 'Result
      ?title "EM Result"
      ?titleAlignment 'center
      ?headers list(
        list("Layer"        80  'center)
        list("minW/maxW"    110 'center)
        list("EM(mA)"       100 'center)
        list("Res(ohm)"     100 'center)
      )
      ?choices list(
        list("M1"  "0.05/4.5"  "ready" "0.550")
        list("M2"  "0.05/4.5"  "ready" "0.550")
        list("M3"  "0.05/4.5"  "ready" "0.550")
        list("M4"  "0.05/4.5"  "ready" "0.550")
        list("M5"  "0.05/4.5"  "ready" "0.550")
        list("M6"  "0.05/4.5"  "ready" "0.550")
        list("M7"  "0.1/12.0"  "ready" "0.182")
        list("M8"  "0.1/12.0"  "ready" "0.182")
        list("M9"  "2.0/12.0"  "ready" "0.0167")
        list("M10" "2.0/12.0"  "ready" "0.0167")
        list("AP"  "2.0/35.0"  "ready" "0.0104")
      )
    )

    hiCreateAppForm(
      ?name 'KV_EM_T28_1P10M5X2Y2R_Form
      ?formTitle "EM Calculator - T28_1P10M5X2Y2R"
      ?callback "kvUpdateEMReport_T28()"
      ?fields list(
        list(width_GUI  20:10   120:30  50)
        list(length_GUI 170:10  130:30  60)
        list(temp_GUI   330:10  220:30  90)
        list(tech_GUI   20:45   530:30  90)
        list(note_GUI   20:80   530:30  90)
        list(report_GUI 20:125  520:260 20)
      )
      ?buttonLayout 'OKCancelApply
      ?initialSize 580:440
      ?minSize 580:440
    )

    hiDisplayForm('KV_EM_T28_1P10M5X2Y2R_Form)
  )
)


; ------------------------------------------------------------
; Compatibility wrapper
; Keep old menu / bindkey working if they still call cusEMGUI().
; ------------------------------------------------------------

procedure(cusEMGUI()
  kvEMGUI()
)


; ------------------------------------------------------------
; Optional compatibility wrapper for old calculation name
; ------------------------------------------------------------

procedure(cusCalEM(w l temp)
  let((form resultList)

    resultList = kvCalculateEM_T28_1P10M5X2Y2R(w l temp)

    form = hiGetCurrentForm()

    when(form && resultList && get(form 'Result)
      form->Result->choices = resultList
    )

    resultList
  )
)


printf("[KV_CAD] EM tool loaded: T28_1P10M5X2Y2R\n")
