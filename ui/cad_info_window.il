; ============================================================
; Kevin CAD Toolkit - Information Window
; File:
;   ui/cad_info_window.il
;
; Purpose:
;   Display CAD toolkit information in GUI windows.
; ============================================================


; ------------------------------------------------------------
; Convert any value to a display string safely
; ------------------------------------------------------------

procedure(kvInfoToString(value)
  cond(
    ((value == nil)
      "undefined"
    )

    (t
      sprintf(nil "%L" value)
    )
  )
)


; ------------------------------------------------------------
; Normalize report rows
;
; Input:
;   list(
;     list("Item" value)
;     list("Item2" value2)
;   )
;
; Output:
;   list(
;     list("Item" "value")
;     list("Item2" "value2")
;   )
; ------------------------------------------------------------

procedure(kvNormalizeInfoRows(rows)
  let((newRows item value)

    newRows = nil

    if(rows then
      foreach(row rows
        item  = if(car(row) then kvInfoToString(car(row)) else "Item")
        value = if(cadr(row) then kvInfoToString(cadr(row)) else "undefined")

        newRows = append(newRows list(list(item value)))
      )
    else
      newRows = list(list("Info" "No data"))
    )

    newRows
  )
)


; ------------------------------------------------------------
; Close old info window if it exists
; ------------------------------------------------------------

procedure(kvCloseOldInfoWindow()
  when(boundp('kvInfoWindowForm)
    errset(hiFormDone(kvInfoWindowForm) t)
  )
)


; ------------------------------------------------------------
; Generic report window
; ------------------------------------------------------------

procedure(kvShowInfoWindow(title rows)
  let((reportField form safeTitle safeRows)

    safeTitle = kvInfoToString(title)
    safeRows  = kvNormalizeInfoRows(rows)

    ; Close previous info window first.
    kvCloseOldInfoWindow()

    reportField = hiCreateReportField(
      ?name 'kvInfoReportField
      ?title safeTitle
      ?titleAlignment 'center
      ?headers list(
        list("Item" 180 'left)
        list("Value" 560 'left)
      )
      ?choices safeRows
    )

    form = hiCreateAppForm(
      ?name 'kvInfoWindowForm
      ?formTitle safeTitle
      ?fields list(
        list(reportField 20:20 780:360 20)
      )
      ?buttonLayout 'OKCancel
      ?initialSize 840:450
      ?minSize 840:450
    )

    hiDisplayForm(form)
  )
)


; ------------------------------------------------------------
; CAD status window
; ------------------------------------------------------------

procedure(kvShowCadStatusWindow()
  let((rows metalCount skillHome currentProcess configDir metalMode)

    skillHome = if(boundp('KevinSkillHome) then KevinSkillHome else "undefined")
    currentProcess = if(boundp('KevinCurrentProcess) then KevinCurrentProcess else "undefined")
    configDir = if(boundp('KevinConfigDir) then KevinConfigDir else "undefined")
    metalMode = if(boundp('KevinMetalChangeMode) then KevinMetalChangeMode else "undefined")

    if(boundp('KevinMetalStack) && KevinMetalStack then
      metalCount = sprintf(nil "%d" length(KevinMetalStack))
    else
      metalCount = "undefined"
    )

    rows = list(
      list("KevinSkillHome" skillHome)
      list("Current Process" currentProcess)
      list("Config Dir" configDir)
      list("Metal Count" metalCount)
      list("Metal Change Mode" metalMode)
    )

    kvShowInfoWindow("Kevin CAD Toolkit Status" rows)
  )
)


; ------------------------------------------------------------
; Current process window
; ------------------------------------------------------------

procedure(kvShowCurrentProcessWindow()
  let((rows configFile metalCount currentProcess configDir)

    currentProcess = if(boundp('KevinCurrentProcess) then KevinCurrentProcess else "undefined")
    configDir = if(boundp('KevinConfigDir) then KevinConfigDir else "undefined")

    if(isCallable('kvGetProcessConfigFile) && currentProcess != "undefined" then
      configFile = kvGetProcessConfigFile(currentProcess)
    else
      configFile = "undefined"
    )

    if(boundp('KevinMetalStack) && KevinMetalStack then
      metalCount = sprintf(nil "%d" length(KevinMetalStack))
    else
      metalCount = "0 or undefined"
    )

    rows = list(
      list("Current Process" currentProcess)
      list("Config Dir" configDir)
      list("Config File" configFile)
      list("Metal Count" metalCount)
    )

    kvShowInfoWindow("Current Process Information" rows)
  )
)


; ------------------------------------------------------------
; Supported process window
; ------------------------------------------------------------

procedure(kvShowSupportedProcessWindow()
  let((rows idx)

    rows = nil
    idx = 1

    if(boundp('KevinSupportedProcessList) && KevinSupportedProcessList then
      foreach(procName KevinSupportedProcessList
        rows = append(rows list(list(sprintf(nil "%d" idx) procName)))
        idx = idx + 1
      )
    else
      rows = list(list("Process List" "undefined"))
    )

    kvShowInfoWindow("Supported Process List" rows)
  )
)


; ------------------------------------------------------------
; Metal stack window
; ------------------------------------------------------------

procedure(kvShowMetalStackWindow()
  let((rows idx metal pin via valueStr)

    rows = nil

    if(boundp('KevinMetalStack) && KevinMetalStack then
      foreach(metalData KevinMetalStack
        idx   = nth(0 metalData)
        metal = nth(1 metalData)
        pin   = nth(2 metalData)
        via   = nth(3 metalData)

        valueStr = sprintf(nil "metal=%L    pin=%L    via=%L" metal pin via)

        rows = append(
          rows
          list(
            list(sprintf(nil "M%d" idx) valueStr)
          )
        )
      )
    else
      rows = list(list("Metal Stack" "undefined"))
    )

    kvShowInfoWindow("Metal Stack Information" rows)
  )
)


; ------------------------------------------------------------
; Metal bindkey table window
; ------------------------------------------------------------

procedure(kvShowMetalBindkeyWindow()
  let((rows idx metal normalKey shiftKey ctrlKey altKey valueStr)

    rows = nil

    if(boundp('KevinMetalStack) && KevinMetalStack then
      foreach(metalData KevinMetalStack
        idx       = nth(0 metalData)
        metal     = nth(1 metalData)
        normalKey = nth(8 metalData)
        shiftKey  = nth(9 metalData)
        ctrlKey   = nth(10 metalData)
        altKey    = nth(11 metalData)

        valueStr = sprintf(
          nil
          "show=%s    add=%s    hide=%s    change=%s"
          kvInfoToString(normalKey)
          kvInfoToString(shiftKey)
          kvInfoToString(ctrlKey)
          kvInfoToString(altKey)
        )

        rows = append(
          rows
          list(
            list(sprintf(nil "M%d %L" idx metal) valueStr)
          )
        )
      )
    else
      rows = list(list("Metal Bindkey" "undefined"))
    )

    kvShowInfoWindow("Metal Bindkey Table" rows)
  )
)


printf("[KV_CAD] cad_info_window loaded\n")
