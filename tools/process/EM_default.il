; ============================================================
; Kevin CAD Toolkit - Default EM Tool
; File:
;   tools/process/em/em_default.il
; ============================================================

procedure(kvEMGUI()
  let((msg)
    msg = if(boundp('KevinCurrentProcess) then
            sprintf(nil "No EM calculator is available for process: %s" KevinCurrentProcess)
          else
            "No EM calculator is available for current process."
          )

    if(isCallable('kvShowInfoWindow) then
      kvShowInfoWindow(
        "EM Calculator"
        list(
          list("Status" "Unavailable")
          list("Message" msg)
        )
      )
    else
      printf("[KV_CAD][EM][WARN] %s\n" msg)
    )
  )
)

printf("[KV_CAD] default EM tool loaded\n")
