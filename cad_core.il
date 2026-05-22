; ============================================================
; Kevin CAD Toolkit Core
; File: core/cad_core.il
; Purpose:
;   Basic path setup and safe load functions.
; ============================================================


; ------------------------------------------------------------
; Define toolkit home path
; ------------------------------------------------------------

unless(boundp('KevinSkillHome)
  KevinSkillHome = getShellEnvVar("KEVIN_SKILL_HOME")
)

unless(KevinSkillHome
  KevinSkillHome = "/home/guoyw/CAD_HOME"
)


; ------------------------------------------------------------
; Safe load absolute path
; ------------------------------------------------------------

procedure(kvLoadAbs(filePath)
  let((status)

    if(isFile(filePath) then
      printf("[KV_CAD][LOAD] %s\n" filePath)

      status = errset(load(filePath) t)

      unless(status
        printf("[KV_CAD][ERROR] Failed to load: %s\n" filePath)
      )
    else
      printf("[KV_CAD][WARN] File not found: %s\n" filePath)
    )
  )
)


; ------------------------------------------------------------
; Safe load relative path from KevinSkillHome
; Example:
;   kvLoad("tools/metal_change.il")
; ------------------------------------------------------------

procedure(kvLoad(relPath)
  kvLoadAbs(strcat(KevinSkillHome "/" relPath))
)


; ------------------------------------------------------------
; Load a list of relative paths
; Example:
;   kvLoadList(list("a.il" "b.il"))
; ------------------------------------------------------------

procedure(kvLoadList(fileList)
  foreach(fileName fileList
    kvLoad(fileName)
  )
)


; ------------------------------------------------------------
; Print basic toolkit information
; ------------------------------------------------------------

procedure(kvPrintToolkitInfo()
  printf("\n")
  printf("============================================================\n")
  printf("[KV_CAD] Kevin CAD Toolkit\n")
  printf("[KV_CAD] Home: %s\n" KevinSkillHome)
  printf("============================================================\n")
)


printf("[KV_CAD] cad_core loaded\n")
