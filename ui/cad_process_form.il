; ============================================================
; Kevin CAD Toolkit - Process Setting Form
; File:
;   ui/cad_process_form.il
;
; Purpose:
;   GUI form to switch current process and reload metal bindkeys.
;
; Dependency:
;   config/process_table.il
;   bindkey/cad_metal_bindkey.il
;   ui/cad_info_window.il
; ============================================================


; ------------------------------------------------------------
; Convert value to string safely
; ------------------------------------------------------------

procedure(kvToString(value)
  if(value == nil then
    "undefined"
  else
    sprintf(nil "%L" value)
  )
)


; ------------------------------------------------------------
; Get current process name safely
; ------------------------------------------------------------

procedure(kvGetCurrentProcessName()
  if(boundp('KevinCurrentProcess) && KevinCurrentProcess then
    KevinCurrentProcess
  else
    "undefined"
  )
)


; ------------------------------------------------------------
; Process switch result window
; ------------------------------------------------------------

procedure(kvShowProcessSwitchResultWindow(procName status)
  let((rows metalCount configFile resultText)

    if(status then
      resultText = "Success"
    else
      resultText = "Failed"
    )

    if(boundp('KevinMetalStack) && KevinMetalStack then
      metalCount = sprintf(nil "%d" length(KevinMetalStack))
    else
      metalCount = "0 or undefined"
    )

    if(isCallable('kvGetProcessConfigFile) && procName then
      configFile = kvGetProcessConfigFile(procName)
    else
      configFile = "undefined"
    )

    rows = list(
      list("Result" resultText)
      list("Selected Process" procName)
      list("Current Process" kvGetCurrentProcessName())
      list("Config File" configFile)
      list("Metal Count" metalCount)
    )

    if(isCallable('kvShowInfoWindow) then
      kvShowInfoWindow("Process Switch Result" rows)
    else
      progn(
        printf("\n")
        printf("============================================================\n")
        printf("[KV_CAD] Process Switch Result\n")
        printf("Result           : %s\n" resultText)
        printf("Selected Process : %s\n" procName)
        printf("Current Process  : %s\n" kvGetCurrentProcessName())
        printf("Config File      : %s\n" configFile)
        printf("Metal Count      : %s\n" metalCount)
        printf("============================================================\n\n")
      )
    )
  )
)


; ------------------------------------------------------------
; Apply process setting from form
; ------------------------------------------------------------

procedure(kvApplyProcessSettingForm()
  let((form procName status)

    form = hiGetCurrentForm()

    unless(form
      printf("[KV_CAD][PROCESS_FORM][ERROR] No current form.\n")
      return(nil)
    )

    procName = form->kvProcessName->value

    unless(procName
      printf("[KV_CAD][PROCESS_FORM][ERROR] No process selected.\n")
      return(nil)
    )

    printf("[KV_CAD][PROCESS_FORM] Selected process: %s\n" procName)

    if(isCallable('kvSwitchProcess) then
      status = kvSwitchProcess(procName)
    else
      progn(
        printf("[KV_CAD][PROCESS_FORM][ERROR] kvSwitchProcess is not callable.\n")
        status = nil
      )
    )

    kvShowProcessSwitchResultWindow(procName status)

    status
  )
)


; ------------------------------------------------------------
; Show metal stack from process form
; ------------------------------------------------------------

procedure(kvProcessFormShowMetalStack()
  if(isCallable('kvShowMetalStackWindow) then
    kvShowMetalStackWindow()
  else if(isCallable('kvPrintMetalStack) then
    kvPrintMetalStack()
  else
    printf("[KV_CAD][PROCESS_FORM][WARN] No metal stack display function available.\n")
  )
)
)

; ------------------------------------------------------------
; Show bindkey table from process form
; ------------------------------------------------------------

procedure(kvProcessFormShowBindkeyTable()
  if(isCallable('kvShowMetalBindkeyWindow) then
    kvShowMetalBindkeyWindow()
  else if(isCallable('kvPrintMetalBindkeyTable) then
    kvPrintMetalBindkeyTable()
  else
    printf("[KV_CAD][PROCESS_FORM][WARN] No bindkey display function available.\n")
  )
)
)

; ------------------------------------------------------------
; Reload current process from process form
; ------------------------------------------------------------

procedure(kvProcessFormReloadCurrentProcess()
  let((status procName)

    procName = kvGetCurrentProcessName()

    if(isCallable('kvReloadCurrentProcess) then
      status = kvReloadCurrentProcess()
    else
      progn(
        printf("[KV_CAD][PROCESS_FORM][ERROR] kvReloadCurrentProcess is not callable.\n")
        status = nil
      )
    )

    kvShowProcessSwitchResultWindow(procName status)

    status
  )
)


; ------------------------------------------------------------
; Create and display process setting form
; ------------------------------------------------------------

procedure(kvShowProcessSettingForm()
  let((processField currentField configField metalCountField
       applyButton reloadButton stackButton bindkeyButton closeButton
       form processChoices currentProcess configFile metalCount)

    if(boundp('KevinSupportedProcessList) && KevinSupportedProcessList then
      processChoices = KevinSupportedProcessList
    else
      processChoices = list("undefined")
    )

    currentProcess = kvGetCurrentProcessName()

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

    processField = hiCreateCyclicField(
      ?name 'kvProcessName
      ?prompt "Select Process:"
      ?choices processChoices
      ?value currentProcess
    )

    currentField = hiCreateOutputStringField(
      ?name 'kvCurrentProcess
      ?prompt "Current Process:"
      ?value currentProcess
    )

    configField = hiCreateOutputStringField(
      ?name 'kvConfigFile
      ?prompt "Config File:"
      ?value configFile
    )

    metalCountField = hiCreateOutputStringField(
      ?name 'kvMetalCount
      ?prompt "Metal Count:"
      ?value metalCount
    )

    applyButton = hiCreateButton(
      ?name 'kvApplyProcess
      ?buttonText "Apply"
      ?callback "kvApplyProcessSettingForm()"
    )

    reloadButton = hiCreateButton(
      ?name 'kvReloadProcess
      ?buttonText "Reload Current"
      ?callback "kvProcessFormReloadCurrentProcess()"
    )

    stackButton = hiCreateButton(
      ?name 'kvShowStack
      ?buttonText "Show Metal Stack"
      ?callback "kvProcessFormShowMetalStack()"
    )

    bindkeyButton = hiCreateButton(
      ?name 'kvShowBindkey
      ?buttonText "Show Bindkey Table"
      ?callback "kvProcessFormShowBindkeyTable()"
    )

   
    form = hiCreateAppForm(
      ?name 'kvProcessSettingForm
      ?formTitle "Kevin CAD Process Setting"
      ?fields list(
        list(processField    20:20   520:30  140)
        list(currentField    20:65   520:30  140)
        list(configField     20:110  720:30  140)
        list(metalCountField 20:155  300:30  140)

        list(applyButton     20:220  120:35  20)
        list(reloadButton    160:220 140:35  20)
        list(stackButton     320:220 160:35  20)
        list(bindkeyButton   500:220 170:35  20)
      )
      ?buttonLayout 'OKCancel
      ?initialSize 830:310
      ?minSize 830:310
    )

    hiDisplayForm(form)
  )
)


printf("[KV_CAD] cad_process_form loaded\n")
