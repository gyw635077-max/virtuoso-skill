; ============================================================
; Kevin CAD Toolkit Process Table
; File:
;   config/process_table.il
;
; Purpose:
;   1. Define supported process list.
;   2. Load process-specific metal stack config.
;   3. Provide process switch / reload / query functions.
;
; Dependency:
;   core/cad_core.il
;   core/cad_utils.il
;   core/cad_env.il
; ============================================================


; ------------------------------------------------------------
; Supported process list
; Each process should have a corresponding metal stack file:
;
;   config/metal_stack_<processName>.il
;
; Example:
;   T28_5X2Y2R
;   -> config/metal_stack_T28_5X2Y2R.il
; ------------------------------------------------------------

KevinSupportedProcessList = list(
  "T22_5X1Z1U"
  "ST130_6M2X1B2TAP"
  "T28_5X2Y2R"
  "HL22_6Mx1TM8x1UTM"
)


; ------------------------------------------------------------
; Default process
; If KEVIN_PROCESS is not set, this process will be used.
; ------------------------------------------------------------

KevinDefaultProcess = "T28_5X2Y2R"


; ------------------------------------------------------------
; Check whether a process is supported
; ------------------------------------------------------------

procedure(kvIsSupportedProcess(procName)
  let((result)

    result = nil

    foreach(item KevinSupportedProcessList
      when(item == procName
        result = t
      )
    )

    result
  )
)


; ------------------------------------------------------------
; Get metal stack config file path by process name
; ------------------------------------------------------------

procedure(kvGetProcessConfigFile(procName)
  strcat(KevinConfigDir "/metal_stack_" procName ".il")
)


; ------------------------------------------------------------
; Print all supported process names
; Can be called from CIW:
;   kvPrintSupportedProcess()
; ------------------------------------------------------------

procedure(kvPrintSupportedProcess()
  printf("\n")
  printf("============================================================\n")
  printf("[KV_CAD] Supported Process List\n")
  printf("============================================================\n")

  foreach(procName KevinSupportedProcessList
    printf("  %s\n" procName)
  )

  printf("============================================================\n\n")
)

; ------------------------------------------------------------
; Load one process rule file by prefix
;
; Example:
;   kvLoadProcessRuleFile("metal_stack" "T28_5X2Y2R")
;   -> config/metal_stack_T28_5X2Y2R.il
; ------------------------------------------------------------

procedure(kvLoadProcessRuleFile(prefix procName)
  let((filePath status)

    filePath = strcat(KevinConfigDir "/" prefix "_" procName ".il")

    if(isFile(filePath) then
      progn(
        printf("[KV_CAD][PROCESS] Loading rule file: %s\n" filePath)

        status = errset(load(filePath) t)

        if(status then
          progn(
            printf("[KV_CAD][PROCESS] Loaded rule file: %s\n" filePath)
            t
          )
        else
          progn(
            printf("[KV_CAD][PROCESS][ERROR] Failed to load rule file: %s\n" filePath)
            nil
          )
        )
      )
    else
      progn(
        printf("[KV_CAD][PROCESS][WARN] Rule file not found: %s\n" filePath)
        nil
      )
    )
  )
)


; ------------------------------------------------------------
; Clear process-dependent global variables before loading rules
; ------------------------------------------------------------

procedure(kvClearProcessRuleVars()
  KevinMetalStack = nil
  KevinBlockRuleTable = nil
  KevinEMRuleTable = nil
  KevinEMTempTableCu = nil
  KevinEMTempTableAl = nil
  KevinViaRuleTable = nil

  printf("[KV_CAD][PROCESS] Cleared process rule variables.\n")
)

; ------------------------------------------------------------
; Load process-specific EM tool
;
; File naming:
;   tools/process/em/EM_<procName>.il
;
; Example:
;   EM_T28_1P10M5X2Y2R.il
; ------------------------------------------------------------

procedure(kvLoadProcessEMTool(procName)
  let((emFile defaultFile status)

    emFile = strcat(KevinSkillHome "/tools/process/em/EM_" procName ".il")
    defaultFile = strcat(KevinSkillHome "/tools/process/em/EM_default.il")

    if(isFile(emFile) then
      progn(
        printf("[KV_CAD][PROCESS] Loading EM tool: %s\n" emFile)

        status = errset(load(emFile) t)

        if(status then
          progn(
            printf("[KV_CAD][PROCESS] EM tool loaded for: %s\n" procName)
            t
          )
        else
          progn(
            printf("[KV_CAD][PROCESS][ERROR] Failed to load EM tool: %s\n" emFile)
            nil
          )
        )
      )
    else
      if(isFile(defaultFile) then
        progn(
          printf("[KV_CAD][PROCESS][WARN] EM tool not found for %s, load default EM tool.\n" procName)
          status = errset(load(defaultFile) t)

          if(status then
            progn(
              printf("[KV_CAD][PROCESS] Default EM tool loaded.\n")
              t
            )
          else
            progn(
              printf("[KV_CAD][PROCESS][ERROR] Failed to load default EM tool: %s\n" defaultFile)
              nil
            )
          )
        )
      else
        progn(
          printf("[KV_CAD][PROCESS][WARN] No EM tool found for process: %s\n" procName)
          printf("[KV_CAD][PROCESS][WARN] Expected file: %s\n" emFile)
          nil
        )
      )
    )
  )
)
; ------------------------------------------------------------
; Load all process rule files
; ------------------------------------------------------------

procedure(kvLoadAllProcessRules(procName)
  let((metalStatus)

    kvClearProcessRuleVars()

    ; metal_stack is mandatory
    metalStatus = kvLoadProcessRuleFile("metal_stack" procName)

    ; these are optional
    kvLoadProcessRuleFile("block_rule" procName)

    ; EM uses process-specific tool file
    kvLoadProcessEMTool(procName)
    metalStatus
  )
)

; ------------------------------------------------------------
; Load process config package
; Mandatory:
;   metal_stack_<procName>.il
;
; Optional:
;   block_rule_<procName>.il
;   em_rule_<procName>.il
;   via_rule_<procName>.il
; ------------------------------------------------------------

procedure(kvLoadProcessConfig(procName)
  let((status)

    cond(
      ((procName == nil)
        printf("[KV_CAD][ERROR] kvLoadProcessConfig: procName is nil.\n")
        nil
      )

      ((kvIsSupportedProcess(procName) == nil)
        printf("[KV_CAD][WARN] Unsupported process: %s\n" procName)
        printf("[KV_CAD][WARN] Supported processes are:\n")
        foreach(item KevinSupportedProcessList
          printf("  %s\n" item)
        )
        nil
      )

      (t
        printf("[KV_CAD][PROCESS] Loading process package: %s\n" procName)

        status = kvLoadAllProcessRules(procName)

        if(status then
          progn(
            KevinCurrentProcess = procName
            printf("[KV_CAD][PROCESS] Current process set to: %s\n" KevinCurrentProcess)
            t
          )
        else
          progn(
            printf("[KV_CAD][PROCESS][ERROR] Failed to load mandatory metal_stack for: %s\n" procName)
            nil
          )
        )
      )
    )
  )
)
; ------------------------------------------------------------
; Initialize process
; This function should be called from bootstrap.il.
;
; Logic:
;   1. Use KevinCurrentProcess from cad_env.il if it exists.
;   2. Otherwise use KevinDefaultProcess.
;   3. Load corresponding metal stack file.
;   4. Register metal bindkeys if kvSetupMetalBindkeys exists.
; ------------------------------------------------------------

procedure(kvInitProcess()
  let((procName status)

    if(isCallable('KevinCurrentProcess) && KevinCurrentProcess then
      procName = KevinCurrentProcess
    else
      procName = KevinDefaultProcess
    )

    unless(kvIsSupportedProcess(procName)
      printf("[KV_CAD][WARN] Current process %s is not supported.\n" procName)
      printf("[KV_CAD][WARN] Use default process: %s\n" KevinDefaultProcess)
      procName = KevinDefaultProcess
    )

    status = kvLoadProcessConfig(procName)

    when(status
      when(isCallable('kvSetupMetalBindkeys)
        kvSetupMetalBindkeys()
	)
	printf("[KV_CAD][PROCESS][WARN] kvSetupMetalBindkeys is not callable. Skip bindkey setup.\n")
      )
    

    status
  )
)
; ------------------------------------------------------------
; Switch process manually
; This function can be called from CIW or GUI:
;
;   kvSwitchProcess("T28_5X2Y2R")
;   kvSwitchProcess("ST130_6M2X1B2TAP")
; ------------------------------------------------------------

procedure(kvSwitchProcess(procName)
  let((status)

    printf("[KV_CAD][PROCESS] Switching process to: %s\n" procName)

    status = kvLoadProcessConfig(procName)

    when(status
      when(isCallable('kvSetupMetalBindkeys)
        kvSetupMetalBindkeys()
      )

      printf("[KV_CAD][PROCESS] Process switched successfully: %s\n" procName)
    )

    status
  )
)


; ------------------------------------------------------------
; Reload current process
; Useful after editing metal_stack_xxx.il
;
; CIW:
;   kvReloadCurrentProcess()
; ------------------------------------------------------------

procedure(kvReloadCurrentProcess()
  let((procName)

    if(isCallable('KevinCurrentProcess) && KevinCurrentProcess then
      procName = KevinCurrentProcess
    else
      procName = KevinDefaultProcess
    )

    printf("[KV_CAD][PROCESS] Reload current process: %s\n" procName)

    kvSwitchProcess(procName)
  )
)


; ------------------------------------------------------------
; Print current process information
; ------------------------------------------------------------

procedure(kvPrintCurrentProcess()
  printf("\n")
  printf("============================================================\n")
  printf("[KV_CAD] Current Process Information\n")
  printf("============================================================\n")

  if(boundp('KevinCurrentProcess) then
    printf("Current Process : %s\n" KevinCurrentProcess)
  else
    printf("Current Process : undefined\n")
  )

  if(boundp('KevinConfigDir) then
    printf("Config Dir      : %s\n" KevinConfigDir)
  else
    printf("Config Dir      : undefined\n")
  )

  when(boundp('KevinCurrentProcess) && KevinCurrentProcess
    printf("Config File     : %s\n" kvGetProcessConfigFile(KevinCurrentProcess))
  )

  if(boundp('KevinMetalStack) && KevinMetalStack then
    printf("Metal Count     : %d\n" length(KevinMetalStack))
  else
    printf("Metal Count     : 0 or undefined\n")
  )

  printf("============================================================\n\n")
)


; ------------------------------------------------------------
; Get process list for GUI cyclic field
; ------------------------------------------------------------

procedure(kvGetSupportedProcessList()
  KevinSupportedProcessList
)


printf("[KV_CAD] process_table loaded\n")
