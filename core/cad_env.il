; ============================================================
; Kevin CAD Toolkit Environment
; File: core/cad_env.il
; Purpose:
;   Environment variables and current process setup.
; ============================================================


; ------------------------------------------------------------
; Get shell environment variable with default value
; ------------------------------------------------------------

procedure(kvGetEnv(envName defaultValue)
  let((value)
    value = getShellEnvVar(envName)

    unless(value
      value = defaultValue
    )

    value
  )
)


; ------------------------------------------------------------
; Initialize CAD environment
; This function must be called by bootstrap.il
; ------------------------------------------------------------

procedure(kvInitEnv()
  KevinCurrentProcess = kvGetEnv("KEVIN_PROCESS" "T28_5X2Y2R")

  KevinConfigDir = kvGetEnv(
    "KEVIN_CONFIG_DIR"
    strcat(KevinSkillHome "/config")
  )

  KevinProcessFileDir = kvGetEnv(
    "KEVIN_PROCESS_FILE_DIR"
    strcat(KevinSkillHome "/process_file")
  )

  SkillPath = kvGetEnv(
    "KEVIN_OLD_SKILL_PATH"
    strcat(KevinSkillHome "/bindkey_pro/")
  )

  KevinUserOverrideFile = strcat(getShellEnvVar("HOME") "/.kevin_skill_user.il")

  KevinMetalChangeMode = kvGetEnv("KEVIN_METAL_CHANGE_MODE" "layerOnly")

  printf("[KV_CAD][ENV] Current process       : %s\n" KevinCurrentProcess)
  printf("[KV_CAD][ENV] Config dir            : %s\n" KevinConfigDir)
  printf("[KV_CAD][ENV] Process file dir      : %s\n" KevinProcessFileDir)
  printf("[KV_CAD][ENV] Old SkillPath         : %s\n" SkillPath)
  printf("[KV_CAD][ENV] User override file    : %s\n" KevinUserOverrideFile)
  printf("[KV_CAD][ENV] Metal change mode     : %s\n" KevinMetalChangeMode)
)


; ------------------------------------------------------------
; Print current environment
; Can be called from CIW:
;   kvPrintEnv()
; ------------------------------------------------------------

procedure(kvPrintEnv()
  printf("\n")
  printf("============================================================\n")
  printf("[KV_CAD] Environment Information\n")
  printf("============================================================\n")

  if(boundp('KevinSkillHome) then
    printf("KevinSkillHome        = %s\n" KevinSkillHome)
  else
    printf("KevinSkillHome        = undefined\n")
  )

  if(boundp('KevinCurrentProcess) then
    printf("KevinCurrentProcess   = %s\n" KevinCurrentProcess)
  else
    printf("KevinCurrentProcess   = undefined\n")
  )

  if(boundp('KevinConfigDir) then
    printf("KevinConfigDir        = %s\n" KevinConfigDir)
  else
    printf("KevinConfigDir        = undefined\n")
  )

  if(boundp('KevinProcessFileDir) then
    printf("KevinProcessFileDir   = %s\n" KevinProcessFileDir)
  else
    printf("KevinProcessFileDir   = undefined\n")
  )

  if(boundp('SkillPath) then
    printf("SkillPath             = %s\n" SkillPath)
  else
    printf("SkillPath             = undefined\n")
  )

  if(boundp('KevinUserOverrideFile) then
    printf("KevinUserOverrideFile = %s\n" KevinUserOverrideFile)
  else
    printf("KevinUserOverrideFile = undefined\n")
  )

  if(boundp('KevinMetalChangeMode) then
    printf("KevinMetalChangeMode  = %s\n" KevinMetalChangeMode)
  else
    printf("KevinMetalChangeMode  = undefined\n")
  )

  printf("============================================================\n")
  printf("\n")
)


printf("[KV_CAD] cad_env loaded\n")
