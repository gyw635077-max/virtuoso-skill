; ============================================================
; Kevin CAD Toolkit Bootstrap
; File: bootstrap.il
; ============================================================

unless(boundp('KevinSkillHome)
  KevinSkillHome = getShellEnvVar("KEVIN_SKILL_HOME")
)

unless(KevinSkillHome
  KevinSkillHome = "CAD_HOME"
)

procedure(kvBootstrapLoad(relPath)
  let((filePath status)
    filePath = strcat(KevinSkillHome "/" relPath)

    if(isFile(filePath) then
      printf("[BOOTSTRAP] Loading: %s\n" filePath)
      status = errset(load(filePath) t)
      unless(status
        printf("[BOOTSTRAP][ERROR] Failed to load: %s\n" filePath)
      )
    else
      printf("[BOOTSTRAP][WARN] File not found: %s\n" filePath)
    )
  )
)

printf("\n")
printf("============================================================\n")
printf("[BOOTSTRAP] Kevin CAD Toolkit Starting\n")
printf("[BOOTSTRAP] Home: %s\n" KevinSkillHome)
printf("============================================================\n")

; ------------------------------------------------------------
; Core files
; ------------------------------------------------------------

kvBootstrapLoad("core/cad_core.il")
kvBootstrapLoad("core/cad_utils.il")
kvBootstrapLoad("core/cad_env.il")

if(isCallable('kvInitEnv) then
  kvInitEnv()
else
  printf("[BOOTSTRAP][ERROR] kvInitEnv is not callable. Please check core/cad_env.il\n")
)

kvLoad("config/process_table.il")

; ------------------------------------------------------------
; Tool files
; ------------------------------------------------------------

kvLoad("tools/metal_change.il")

; ------------------------------------------------------------
; Load optional tool loader
; ------------------------------------------------------------
kvLoad("tools/tool_loader.il")

if(isCallable('kvLoadOptionalTools) then
  kvLoadOptionalTools()
else
  printf("[BOOTSTRAP][WARN] kvLoadOptionalTools is not callable. Skip optional tools.\n")
)





kvLoad("tools/process/generate_block.il")
; Bindkey
kvLoad("bindkey/cad_metal_bindkey.il")
kvLoad("bindkey/cad_bindkey_main.il")
kvLoad("bindkey/profile/cad_bindkey_profiles.il")
; ------------------------------------------------------------
; Initialize process
; This loads metal_stack_<process>.il
; ------------------------------------------------------------

if(isCallable('kvInitProcess) then
  kvInitProcess()
else
  printf("[BOOTSTRAP][WARN] kvInitProcess is not callable. Skip process init.\n")
)


; ------------------------------------------------------------
; Load UI menu
; ------------------------------------------------------------
kvLoad("ui/cad_info_window.il")
kvLoad("ui/cad_process_form.il")
kvLoad("ui/cad_menu.il")

if(isCallable('kvSetupMenuTrigger) then
  kvSetupMenuTrigger()
else
  printf("[BOOTSTRAP][WARN] kvSetupMenuTrigger is not callable. Skip menu trigger.\n")
)

; ------------------------------------------------------------
; Register main bindkeys
; ------------------------------------------------------------

if(isCallable('kvSetupMainBindkeys) then
  kvSetupMainBindkeys()
else
  printf("[BOOTSTRAP][WARN] kvSetupMainBindkeys is not callable. Skip main bindkeys.\n")
)

; ------------------------------------------------------------
; Init process and UI
; ------------------------------------------------------------

when(boundp('kvInitProcess)
  kvInitProcess()
)

when(boundp('kvSetupMainBindkeys)
  kvSetupMainBindkeys()
)

when(boundp('kvSetupMenuTrigger)
  kvSetupMenuTrigger()
)

; ------------------------------------------------------------
; User override
; ------------------------------------------------------------

if(boundp('KevinUserOverrideFile) && KevinUserOverrideFile then
  when(isFile(KevinUserOverrideFile)
    kvLoadAbs(KevinUserOverrideFile)
  )
else
  printf("[BOOTSTRAP][WARN] KevinUserOverrideFile is not defined. Skip user override.\n")
)

printf("============================================================\n")
printf("[BOOTSTRAP] Kevin CAD Toolkit Loaded\n")
printf("============================================================\n\n")
