; ============================================================
; Kevin CAD Toolkit - Block Rule
; Process:
;   T22_5X1Z1U
;
; File:
;   config/block_rule_T22_5X1Z1U.il
;
; Purpose:
;   Define block / dummy exclude / keepout layers
;   for generate_block tool.
;
; Data format:
;   list(
;     display_name
;     lpp
;     default_enable
;   )
; ============================================================


KevinBlockRuleTable = list(

  ; FEOL block layers
  list("OD"  list("ODBLK" "dummy")       t)
  list("PO"  list("POBLK" "dummy")       t)

  ; Metal dummy exclude layers
  list("M1"  list("DMEXCL" "dummy1")     t)
  list("M2"  list("DMEXCL" "dummy2")     t)
  list("M3"  list("DMEXCL" "dummy3")     t)
  list("M4"  list("DMEXCL" "dummy4")     t)
  list("M5"  list("DMEXCL" "dummy5")     t)
  list("M6"  list("DMEXCL" "dummy6")     t)
  list("M7"  list("DMEXCL" "dummy7")     t)
  list("M8"  list("DMEXCL" "dummy8")     t)


  ; Optional layers
  list("NTN" list("NT_N" "drawing")   nil)
  list("RPO" list("RPO" "drawing")    nil)
  list("PP"  list("PP" "drawing")     nil)
)


procedure(kvPrintBlockRuleTable()
  let((name lpp enable)

    printf("\n")
    printf("============================================================\n")
    printf("[KV_CAD] Block Rule Table: %s\n" KevinCurrentProcess)
    printf("============================================================\n")

    foreach(rule KevinBlockRuleTable
      name   = nth(0 rule)
      lpp    = nth(1 rule)
      enable = nth(2 rule)

      printf("%-8s  %-20L  default=%L\n" name lpp enable)
    )

    printf("============================================================\n\n")
  )
)


printf("[KV_CAD] block_rule_T22_5X1Z1U loaded\n")
printf("[KV_CAD] Block rule count: %d\n" length(KevinBlockRuleTable))
