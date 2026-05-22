; ============================================================
; Kevin CAD Toolkit - Optional Tool Loader
; File:
;   tools/tool_loader.il
;
; Purpose:
;   Load optional CAD utility scripts in a controlled way.
;
; Notes:
;   1. Core framework files should NOT be loaded here.
;   2. Process/metal stack/bindkey/menu files should NOT be loaded here.
;   3. Only optional user tools should be managed here.
; ============================================================


; ------------------------------------------------------------
; Optional tool root
;
; You can put old scripts in:
;   /home/guoyw/CAD_HOME/legacy/
;
; Or keep them in the old location and use absolute path.
; ------------------------------------------------------------

unless(boundp('KevinLegacyToolDir)
  KevinLegacyToolDir = strcat(KevinSkillHome "/legacy")
)


; ------------------------------------------------------------
; Optional tool list
;
; Format:
;   list(
;     enable_flag
;     display_name
;     relative_or_absolute_path
;   )
;
; If path starts with "/", it is treated as absolute path.
; Otherwise it is treated as relative to KevinSkillHome.
; ------------------------------------------------------------

KevinOptionalToolList = list(

  ; ----------------------------------------------------------
  ; Recommended: move old scripts into CAD_HOME/tools or legacy
  ; ----------------------------------------------------------

  list(t "Quick Move"
       "legacy/kevin_quickmove.il")

  list(t "Zoom To Point"
       "legacy/kevin_zoom_to_point.il")

  list(t "Object Info"
       "legacy/objInfo.il")

  list(t "Generate Block"
       "legacy/generate_block.il")

  list(t "Change Via"
       "legacy/changevia.il")

  list(t "Layout View Check"
       "legacy/layout_view_check.il")

  list(t "Create Logo"
       "legacy/create_logo.il")

  list(t "Cross Ruler"
       "legacy/ts_cross_ruler.il")

  list(t "Update BBox"
       "legacy/ts_update_bbox.il")

  list(t "Refresh Win"
       "legacy/refresh_win.il")

  list(t "DNW_NW_ENCLOSURE"
       "legacy/DNW_NW_enclosure.il")
  

)

; ------------------------------------------------------------
; Check whether a path is absolute
; ------------------------------------------------------------

procedure(kvIsAbsPath(path)
  path && substring(path 1 1) == "/"
)


; ------------------------------------------------------------
; Convert relative path to absolute path
; ------------------------------------------------------------

procedure(kvResolveToolPath(path)
  if(kvIsAbsPath(path) then
    path
  else
    strcat(KevinSkillHome "/" path)
  )
)


; ------------------------------------------------------------
; Safe load one optional tool
; ------------------------------------------------------------

procedure(kvLoadOptionalTool(toolInfo)
  let((enableFlag displayName path absPath status)

    enableFlag  = nth(0 toolInfo)
    displayName = nth(1 toolInfo)
    path        = nth(2 toolInfo)

    cond(
      ((enableFlag == nil)
        printf("[KV_CAD][TOOL_LOADER] Skip disabled tool: %s\n" displayName)
        nil
      )

      ((path == nil)
        printf("[KV_CAD][TOOL_LOADER][WARN] Tool path is nil: %s\n" displayName)
        nil
      )

      (t
        absPath = kvResolveToolPath(path)

        if(isFile(absPath) then
          progn(
            printf("[KV_CAD][TOOL_LOADER] Loading %-24s : %s\n" displayName absPath)

            status = errset(load(absPath) t)

            if(status then
              progn(
                printf("[KV_CAD][TOOL_LOADER] Loaded  %-24s\n" displayName)
                t
              )
            else
              progn(
                printf("[KV_CAD][TOOL_LOADER][ERROR] Failed to load: %s\n" absPath)
                nil
              )
            )
          )
        else
          progn(
            printf("[KV_CAD][TOOL_LOADER][WARN] File not found for %-24s : %s\n" displayName absPath)
            nil
          )
        )
      )
    )
  )
)


; ------------------------------------------------------------
; Load all optional tools
; ------------------------------------------------------------

procedure(kvLoadOptionalTools()
  let((loadedCount skippedCount result)

    loadedCount = 0
    skippedCount = 0

    printf("\n")
    printf("============================================================\n")
    printf("[KV_CAD][TOOL_LOADER] Loading optional tools\n")
    printf("============================================================\n")

    foreach(toolInfo KevinOptionalToolList
      result = kvLoadOptionalTool(toolInfo)

      if(result then
        loadedCount = loadedCount + 1
      else
        skippedCount = skippedCount + 1
      )
    )

    printf("============================================================\n")
    printf("[KV_CAD][TOOL_LOADER] Optional tools loaded: %d, skipped: %d\n"
           loadedCount skippedCount)
    printf("============================================================\n\n")

    t
  )
)


; ------------------------------------------------------------
; Print optional tool table
; ------------------------------------------------------------

procedure(kvPrintOptionalToolTable()
  let((enableFlag displayName path absPath)

    printf("\n")
    printf("============================================================\n")
    printf("[KV_CAD] Optional Tool Table\n")
    printf("============================================================\n")

    foreach(toolInfo KevinOptionalToolList
      enableFlag  = nth(0 toolInfo)
      displayName = nth(1 toolInfo)
      path        = nth(2 toolInfo)
      absPath     = kvResolveToolPath(path)

      printf(
        "%-6s  %-28s  %s\n"
        if(enableFlag then "ON" else "OFF")
        displayName
        absPath
      )
    )

    printf("============================================================\n\n")

    t
  )
)


; ------------------------------------------------------------
; GUI window for optional tools
; Requires:
;   ui/cad_info_window.il
; ------------------------------------------------------------

procedure(kvShowOptionalToolWindow()
  let((rows enableFlag displayName path absPath statusText)

    rows = nil

    foreach(toolInfo KevinOptionalToolList
      enableFlag  = nth(0 toolInfo)
      displayName = nth(1 toolInfo)
      path        = nth(2 toolInfo)
      absPath     = kvResolveToolPath(path)

      if(enableFlag then
        statusText = "ON"
      else
        statusText = "OFF"
      )

      rows = append(
        rows
        list(
          list(displayName sprintf(nil "%s    %s" statusText absPath))
        )
      )
    )

    if(isCallable('kvShowInfoWindow) then
      kvShowInfoWindow("Optional Tool Table" rows)
    else
      kvPrintOptionalToolTable()
    )
  )
)


printf("[KV_CAD] tool_loader loaded\n")
