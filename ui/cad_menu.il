; ============================================================
; Kevin CAD Toolkit - Menu
; File:
;   ui/cad_menu.il
;
; Purpose:
;   Create Kevin CAD menu in Virtuoso Layout window.
;
; Dependency:
;   config/process_table.il
;   config/metal_stack_<process>.il
;   bindkey/cad_metal_bindkey.il
; ============================================================


; ------------------------------------------------------------
; Print CAD toolkit status
; ------------------------------------------------------------

procedure(kvPrintCadStatus()
  printf("\n")
  printf("============================================================\n")
  printf("[KV_CAD] CAD Toolkit Status\n")
  printf("============================================================\n")

  if(boundp('KevinSkillHome) then
    printf("KevinSkillHome       : %s\n" KevinSkillHome)
  else
    printf("KevinSkillHome       : undefined\n")
  )

  if(boundp('KevinCurrentProcess) then
    printf("Current Process      : %s\n" KevinCurrentProcess)
  else
    printf("Current Process      : undefined\n")
  )

  if(boundp('KevinConfigDir) then
    printf("Config Dir           : %s\n" KevinConfigDir)
  else
    printf("Config Dir           : undefined\n")
  )

  if(boundp('KevinMetalStack) && KevinMetalStack then
    printf("Metal Count          : %d\n" length(KevinMetalStack))
  else
    printf("Metal Count          : undefined\n")
  )

  if(boundp('KevinMetalChangeMode) then
    printf("Metal Change Mode    : %s\n" KevinMetalChangeMode)
  else
    printf("Metal Change Mode    : undefined\n")
  )

  printf("============================================================\n\n")
)


; ------------------------------------------------------------
; Menu wrapper: reload current process
; ------------------------------------------------------------

procedure(kvMenuReloadCurrentProcess()
  if(isCallable('kvReloadCurrentProcess) then
    kvReloadCurrentProcess()
  else
    printf("[KV_CAD][MENU][ERROR] kvReloadCurrentProcess is not callable.\n")
  )
)


; ------------------------------------------------------------
; Menu wrapper: print current process
; ------------------------------------------------------------

procedure(kvMenuPrintCurrentProcess()
  if(isCallable('kvPrintCurrentProcess) then
    kvPrintCurrentProcess()
  else
    printf("[KV_CAD][MENU][ERROR] kvPrintCurrentProcess is not callable.\n")
  )
)


; ------------------------------------------------------------
; Menu wrapper: print supported process list
; ------------------------------------------------------------

procedure(kvMenuPrintSupportedProcess()
  if(isCallable('kvPrintSupportedProcess) then
    kvPrintSupportedProcess()
  else
    printf("[KV_CAD][MENU][ERROR] kvPrintSupportedProcess is not callable.\n")
  )
)


; ------------------------------------------------------------
; Menu wrapper: print metal stack
; ------------------------------------------------------------

procedure(kvMenuPrintMetalStack()
  if(isCallable('kvPrintMetalStack) then
    kvPrintMetalStack()
  else
    printf("[KV_CAD][MENU][ERROR] kvPrintMetalStack is not callable.\n")
  )
)


; ------------------------------------------------------------
; Menu wrapper: print metal bindkey table
; ------------------------------------------------------------

procedure(kvMenuPrintMetalBindkeyTable()
  if(isCallable('kvPrintMetalBindkeyTable) then
    kvPrintMetalBindkeyTable()
  else
    printf("[KV_CAD][MENU][ERROR] kvPrintMetalBindkeyTable is not callable.\n")
  )
)


; ------------------------------------------------------------
; Menu wrapper: setup metal bindkeys again
; ------------------------------------------------------------

procedure(kvMenuSetupMetalBindkeys()
  if(isCallable('kvSetupMetalBindkeys) then
    kvSetupMetalBindkeys()
  else
    printf("[KV_CAD][MENU][ERROR] kvSetupMetalBindkeys is not callable.\n")
  )
)


; ------------------------------------------------------------
; Menu wrapper: show all layers
; ------------------------------------------------------------

procedure(kvMenuShowAllLayers()
  if(isCallable('kvShowAllLayers) then
    kvShowAllLayers()
  else
    printf("[KV_CAD][MENU][ERROR] kvShowAllLayers is not callable.\n")
  )
)


; ------------------------------------------------------------
; Menu wrapper: show FEOL only
; ------------------------------------------------------------

procedure(kvMenuShowFeolOnly()
  if(isCallable('kvShowFeolOnly) then
    kvShowFeolOnly()
  else
    printf("[KV_CAD][MENU][ERROR] kvShowFeolOnly is not callable.\n")
  )
)


; ------------------------------------------------------------
; Menu wrapper: show special layers only
; ------------------------------------------------------------

procedure(kvMenuShowSpecialOnly()
  if(isCallable('kvShowSpecialOnly) then
    kvShowSpecialOnly()
  else
    printf("[KV_CAD][MENU][ERROR] kvShowSpecialOnly is not callable.\n")
  )
)


; ------------------------------------------------------------
; Optional tool wrappers
; These allow the menu to exist even if optional tools are not loaded.
; ------------------------------------------------------------

; ------------------------------------------------------------
; Menu wrapper: EM calculation
; The actual EM GUI is process-specific.
; Current process should load its own kvEMGUI().
; ------------------------------------------------------------

procedure(kvMenuEMCalculation()
  if(isCallable('kvEMGUI) then
    kvEMGUI()
  else
    printf("[KV_CAD][MENU][WARN] kvEMGUI is not callable. EM tool is not loaded.\n")
  )
)

procedure(kvMenuQuickMove()
  if(isCallable('QUICK_MOVE) then
    QUICK_MOVE()
  else
    printf("[KV_CAD][MENU][WARN] QUICK_MOVE is not callable. Quick move tool is not loaded.\n")
  )
)


procedure(kvMenuZoomToPoint()
  if(isCallable('Zoom_To_Point) then
    Zoom_To_Point()
  else
    printf("[KV_CAD][MENU][WARN] Zoom_To_Point is not callable. Zoom tool is not loaded.\n")
  )
)

; ------------------------------------------------------------
; Menu wrapper: Apply custom bindkey profile
; ------------------------------------------------------------

procedure(kvMenuApplyCustomBindkeyProfile()
  if(isCallable('kvApplyCustomBindkeyProfile) then
    kvApplyCustomBindkeyProfile()
  else
    printf("[KV_CAD][MENU][WARN] kvApplyCustomBindkeyProfile is not callable.\n")
  )
)


; ------------------------------------------------------------
; Menu wrapper: Apply default bindkey profile
; ------------------------------------------------------------

procedure(kvMenuApplyDefaultBindkeyProfile()
  if(isCallable('kvApplyDefaultBindkeyProfile) then
    kvApplyDefaultBindkeyProfile()
  else
    printf("[KV_CAD][MENU][WARN] kvApplyDefaultBindkeyProfile is not callable.\n")
  )
)


; ------------------------------------------------------------
; Menu wrapper: Restore framework bindkeys
; ------------------------------------------------------------

procedure(kvMenuRestoreFrameworkBindkeys()
  if(isCallable('kvRestoreFrameworkBindkeys) then
    kvRestoreFrameworkBindkeys()
  else
    printf("[KV_CAD][MENU][WARN] kvRestoreFrameworkBindkeys is not callable.\n")
  )
)


; ------------------------------------------------------------
; Menu wrapper: Print bindkey profile help
; ------------------------------------------------------------

procedure(kvMenuPrintBindkeyProfileHelp()
  if(isCallable('kvPrintBindkeyProfileHelp) then
    kvPrintBindkeyProfileHelp()
  else
    printf("[KV_CAD][MENU][WARN] kvPrintBindkeyProfileHelp is not callable.\n")
  )
)


; ------------------------------------------------------------
; Create Kevin CAD menu
; This function will be called by Virtuoso user trigger.
; ------------------------------------------------------------

procedure(kvCreateCadMenu(args)
  let((itemProcessSetting
       itemOptionalTools
       itemStatus
       itemCurrentProcess
       itemSupportedProcess
       itemReloadProcess
       itemPrintStack
       itemPrintBindkey
       itemRegisterBindkey
       itemShowAll
       itemShowFeol
       itemShowSpecial
       itemEM
       itemQuickMove
       itemZoomToPoint
       pullmenu
       itemApplyCustomProfile 
       itemRestoreFrameworkBindkeys 
       itemBindkeyProfileHelp
       menuList)


    itemProcessSetting = hiCreateMenuItem(
  	?name 'kv_item_process_setting
  	?itemText "Process Setting..."
  	?callback "kvShowProcessSettingForm()"
	)

    itemOptionalTools = hiCreateMenuItem(
        ?name 'kv_item_optional_tools
        ?itemText "Show Optional Tools"
        ?callback "kvShowOptionalToolWindow()"
	)
	
    itemStatus = hiCreateMenuItem(
      ?name 'kv_item_status
      ?itemText "Show CAD Toolkit Status"
      ?callback "kvShowCadStatusWindow()"
    )

    itemCurrentProcess = hiCreateMenuItem(
      ?name 'kv_item_current_process
      ?itemText "Print Current Process"
      ?callback "kvShowCurrentProcessWindow()"
    )

    itemSupportedProcess = hiCreateMenuItem(
      ?name 'kv_item_supported_process
      ?itemText "Print Supported Process"
      ?callback "kvShowSupportedProcessWindow()"
    )

    itemReloadProcess = hiCreateMenuItem(
      ?name 'kv_item_reload_process
      ?itemText "Reload Current Process"
      ?callback "kvMenuReloadCurrentProcess()"
    )

    itemPrintStack = hiCreateMenuItem(
      ?name 'kv_item_print_stack
      ?itemText "Print Metal Stack"
      ?callback "kvShowMetalStackWindow()" 
    )

    itemPrintBindkey = hiCreateMenuItem(
      ?name 'kv_item_print_bindkey
      ?itemText "Print Metal Bindkey Table"
      ?callback "kvShowMetalBindkeyWindow()" 
    )

    itemRegisterBindkey = hiCreateMenuItem(
      ?name 'kv_item_register_bindkey
      ?itemText "Register Metal Bindkeys"
      ?callback "kvMenuSetupMetalBindkeys()"
    )

    itemShowAll = hiCreateMenuItem(
      ?name 'kv_item_show_all
      ?itemText "Show All Layers"
      ?callback "kvMenuShowAllLayers()"
    )

    itemShowFeol = hiCreateMenuItem(
      ?name 'kv_item_show_feol
      ?itemText "Show FEOL Only"
      ?callback "kvMenuShowFeolOnly()"
    )

    itemShowSpecial = hiCreateMenuItem(
      ?name 'kv_item_show_special
      ?itemText "Show Special Layers"
      ?callback "kvMenuShowSpecialOnly()"
    )

    itemEM = hiCreateMenuItem(
      ?name 'kv_item_em
      ?itemText "EM Calculation"
      ?callback "kvMenuEMCalculation()"
    )

    itemQuickMove = hiCreateMenuItem(
      ?name 'kv_item_quick_move
      ?itemText "Quick Move"
      ?callback "kvMenuQuickMove()"
    )

    itemZoomToPoint = hiCreateMenuItem(
      ?name 'kv_item_zoom_to_point
      ?itemText "Zoom To Point"
      ?callback "kvMenuZoomToPoint()"
    )

    itemApplyCustomProfile = hiCreateMenuItem(
      ?name 'kv_item_apply_custom_profile
      ?itemText "Apply Custom Bindkey Profile"
      ?callback "kvMenuApplyCustomBindkeyProfile()"
    )

    itemApplyDefaultProfile = hiCreateMenuItem(
      ?name 'kv_item_apply_default_profile
      ?itemText "Apply Default Bindkey Profile"
      ?callback "kvMenuApplyDefaultBindkeyProfile()"
    )

    itemRestoreFrameworkBindkeys = hiCreateMenuItem(
      ?name 'kv_item_restore_framework_bindkeys
      ?itemText "Restore Framework Bindkeys"
      ?callback "kvMenuRestoreFrameworkBindkeys()"
    )

    itemBindkeyProfileHelp = hiCreateMenuItem(
      ?name 'kv_item_bindkey_profile_help
      ?itemText "Bindkey Profile Help"
      ?callback "kvMenuPrintBindkeyProfileHelp()"
    )

    menuList = list(
      itemApplyCustomProfile 
      itemRestoreFrameworkBindkeys 
      itemBindkeyProfileHelp
      itemProcessSetting
      itemStatus
      itemCurrentProcess
      itemSupportedProcess
      itemReloadProcess
      itemPrintStack
      itemPrintBindkey
      itemRegisterBindkey
      itemShowAll
      itemShowFeol
      itemShowSpecial
      itemEM
      itemQuickMove
      itemZoomToPoint
      itemOptionalTools
    )

    pullmenu = hiCreatePulldownMenu(
      'kvCadPulldownMenu
      "Kevin CAD"
      menuList
    )

    hiInsertBannerMenu(
      args->window
      pullmenu
      length(hiGetBannerMenus(args->window))
    )
  )
)







; ------------------------------------------------------------
; Register menu trigger
; This inserts menu when a layout window is opened.
; ------------------------------------------------------------

procedure(kvSetupMenuTrigger()
  deRegUserTriggers("maskLayout"    nil nil 'kvCreateCadMenu)
  deRegUserTriggers("maskLayoutXL"  nil nil 'kvCreateCadMenu)
  deRegUserTriggers("maskLayoutGXL" nil nil 'kvCreateCadMenu)

  printf("[KV_CAD] CAD menu trigger registered.\n")
)


printf("[KV_CAD] cad_menu loaded\n")
