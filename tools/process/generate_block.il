; ============================================================
; Kevin CAD Toolkit - Generate Block Tool
; File:
;   tools/process/generate_block.il
;
; Purpose:
;   Generate block / dummy exclude / keepout layers
;   based on current process KevinBlockRuleTable.
;
; Dependency:
;   config/block_rule_<process>.il
;
; KevinBlockRuleTable format:
;
;   list(
;     list("OD"  list("ODBLK" "dm")     t)
;     list("PO"  list("POBLK" "dm")     t)
;     list("M1"  list("DMEXCL" "dm1")   t)
;     ...
;   )
;
; Field:
;   display_name
;   lpp
;   default_enable
; ============================================================


; ------------------------------------------------------------
; Global variables used by form callback
; ------------------------------------------------------------

KevinBlockButtonMap = nil
KevinGenerateBlockForm = nil


; ------------------------------------------------------------
; Check block rule table
; ------------------------------------------------------------

procedure(kvHasBlockRuleTable()
  boundp('KevinBlockRuleTable) && KevinBlockRuleTable
)


; ------------------------------------------------------------
; Block rule accessors
; ------------------------------------------------------------

procedure(kvBlockRuleName(rule)
  nth(0 rule)
)


procedure(kvBlockRuleLpp(rule)
  nth(1 rule)
)


procedure(kvBlockRuleDefaultEnable(rule)
  nth(2 rule)
)


; ------------------------------------------------------------
; Print block rule table
; ------------------------------------------------------------

procedure(kvPrintBlockRuleTable()
  let((name lpp enable)

    printf("\n")
    printf("============================================================\n")
    printf("[KV_CAD] Block Rule Table: %s\n"
           if(boundp('KevinCurrentProcess) then KevinCurrentProcess else "undefined"))
    printf("============================================================\n")

    if(kvHasBlockRuleTable() then
      foreach(rule KevinBlockRuleTable
        name   = kvBlockRuleName(rule)
        lpp    = kvBlockRuleLpp(rule)
        enable = kvBlockRuleDefaultEnable(rule)

        printf("%-10s  %-24L  default=%L\n" name lpp enable)
      )
    else
      printf("[KV_CAD][BLOCK][WARN] KevinBlockRuleTable is not defined.\n")
    )

    printf("============================================================\n\n")
  )
)


; ------------------------------------------------------------
; Safe check for selected object
; ------------------------------------------------------------

procedure(kvBlockValidSourceObj(obj)
  obj &&
  member(obj~>objType list("rect" "polygon" "path" "pathSeg"))
)


; ------------------------------------------------------------
; Create block shape from source object
;
; rect    -> rect with same bbox
; polygon -> polygon with same points
; path    -> rect with bbox
; pathSeg -> rect with bbox
; others  -> rect with bbox if available
; ------------------------------------------------------------

procedure(kvCreateBlockShapeFromObj(cv sourceObj targetLpp)
  let((newObj bbox points)

    newObj = nil

    when(cv && sourceObj && targetLpp
      cond(
        ((sourceObj~>objType == "rect")
          bbox = sourceObj~>bBox
          when(bbox
            newObj = dbCreateRect(cv targetLpp bbox)
          )
        )

        ((sourceObj~>objType == "polygon")
          points = sourceObj~>points
          when(points
            newObj = dbCreatePolygon(cv targetLpp points)
          )
        )

        ((sourceObj~>bBox)
          bbox = sourceObj~>bBox
          when(bbox
            newObj = dbCreateRect(cv targetLpp bbox)
          )
        )

        (t
          printf("[KV_CAD][BLOCK][WARN] Unsupported object type: %L\n" sourceObj~>objType)
        )
      )
    )

    newObj
  )
)


; ------------------------------------------------------------
; Get selected block rules from form
; KevinBlockButtonMap format:
;   list(
;     list(buttonObj rule)
;     ...
;   )
; ------------------------------------------------------------

procedure(kvGetSelectedBlockRules()
  let((selectedRules button rule)

    selectedRules = nil

    foreach(item KevinBlockButtonMap
      button = nth(0 item)
      rule   = nth(1 item)

      when(button && button->value
        selectedRules = append(selectedRules list(rule))
      )
    )

    selectedRules
  )
)


; ------------------------------------------------------------
; Generate block layers from selected objects
; ------------------------------------------------------------

procedure(kvGenerateBlockLayers()
  let((cv objList form selectedRules deleteOriginal totalCreated totalSource
       obj rule targetLpp newObj)

    cv = geGetEditCellView()
    objList = geGetSelSet()
    form = hiGetCurrentForm()

    totalCreated = 0
    totalSource = 0

    cond(
      ((cv == nil)
        printf("[KV_CAD][BLOCK][ERROR] No edit cellView.\n")
        nil
      )

      ((objList == nil || length(objList) == 0)
        printf("[KV_CAD][BLOCK][WARN] No selected object.\n")
        nil
      )

      ((kvHasBlockRuleTable() == nil)
        printf("[KV_CAD][BLOCK][ERROR] KevinBlockRuleTable is not defined.\n")
        nil
      )

      (t
        selectedRules = kvGetSelectedBlockRules()

        unless(selectedRules
          printf("[KV_CAD][BLOCK][WARN] No block layer selected in form.\n")
          return(nil)
        )

        if(form && get(form 'kvDeleteOriginal) then
          deleteOriginal = form->kvDeleteOriginal->value
        else
          deleteOriginal = nil
        )

        foreach(obj objList
          when(kvBlockValidSourceObj(obj)
            totalSource = totalSource + 1

            foreach(rule selectedRules
              targetLpp = kvBlockRuleLpp(rule)

              newObj = kvCreateBlockShapeFromObj(cv obj targetLpp)

              when(newObj
                totalCreated = totalCreated + 1
              )
            )

            when(deleteOriginal
              dbDeleteObject(obj)
            )
          )
        )

        printf("[KV_CAD][BLOCK] Source objects : %d\n" totalSource)
        printf("[KV_CAD][BLOCK] Created shapes : %d\n" totalCreated)
        printf("[KV_CAD][BLOCK] Delete original: %L\n" deleteOriginal)

        hiRedraw()

        t
      )
    )
  )
)


; ------------------------------------------------------------
; Create dynamic block rule checkboxes
; ------------------------------------------------------------

procedure(kvCreateBlockRuleFields()
  let((fields idx x y button name rule defaultEnable fieldName)

    fields = nil
    KevinBlockButtonMap = nil
    idx = 0

    foreach(rule KevinBlockRuleTable
      name = kvBlockRuleName(rule)
      defaultEnable = kvBlockRuleDefaultEnable(rule)

      ; 4 columns layout
      x = 20 + mod(idx 4) * 130
      y = 20 + fix(idx / 4) * 32

      fieldName = concat('kvBlockRule_ idx)

      button = hiCreateBooleanButton(
        ?name fieldName
        ?buttonText name
        ?defValue defaultEnable
      )

      fields = append(
        fields
        list(list(button x:y 110:28))
      )

      KevinBlockButtonMap = append(
        KevinBlockButtonMap
        list(list(button rule))
      )

      idx = idx + 1
    )

    fields
  )
)


; ------------------------------------------------------------
; Show Generate Block Form
; ------------------------------------------------------------

procedure(kvGenerateBlockForm()
  let((ruleFields deleteOriginalButton generateButton printRuleButton
       formHeight formWidth ruleCount rowCount yButton)

    unless(kvHasBlockRuleTable()
      printf("[KV_CAD][BLOCK][ERROR] KevinBlockRuleTable is not defined.\n")
      printf("[KV_CAD][BLOCK][INFO] Please check block_rule_<process>.il and reload process.\n")
      return(nil)
    )

    ruleCount = length(KevinBlockRuleTable)
    rowCount = ceiling(ruleCount / 4.0)

    formWidth = 600
    formHeight = 120 + rowCount * 32
    yButton = 35 + rowCount * 32

    ruleFields = kvCreateBlockRuleFields()

    deleteOriginalButton = hiCreateBooleanButton(
      ?name 'kvDeleteOriginal
      ?buttonText "Delete Original"
      ?defValue nil
    )

    generateButton = hiCreateButton(
      ?name 'kvGenerateBlockButton
      ?buttonText "Generate"
      ?callback "kvGenerateBlockLayers()"
    )

    printRuleButton = hiCreateButton(
      ?name 'kvPrintBlockRuleButton
      ?buttonText "Print Rule"
      ?callback "kvPrintBlockRuleTable()"
    )

    KevinGenerateBlockForm = hiCreateAppForm(
      ?name 'KevinGenerateBlockForm
      ?formTitle "Kevin CAD Generate Block"
      ?fields append(
        ruleFields
        list(
          list(deleteOriginalButton 20:yButton 160:30 20)
          list(generateButton 220:yButton 120:32 20)
          list(printRuleButton 360:yButton 120:32 20)
        )
      )
      ?buttonLayout 'OKCancel
      ?initialSize formWidth:formHeight
      ?minSize formWidth:formHeight
    )

    hiDisplayForm(KevinGenerateBlockForm)
  )
)


; ------------------------------------------------------------
; Compatibility wrapper
; Keep old function name if you want to bind old menu/key.
; ------------------------------------------------------------

procedure(generate_allblock()
  kvGenerateBlockForm()
)


; ------------------------------------------------------------
; GUI window for block rule table
; Requires ui/cad_info_window.il
; ------------------------------------------------------------

procedure(kvShowBlockRuleWindow()
  let((rows name lpp enable valueStr)

    rows = nil

    if(kvHasBlockRuleTable() then
      foreach(rule KevinBlockRuleTable
        name   = kvBlockRuleName(rule)
        lpp    = kvBlockRuleLpp(rule)
        enable = kvBlockRuleDefaultEnable(rule)

        if(enable then
          valueStr = sprintf(nil "lpp=%L    default=ON" lpp)
        else
          valueStr = sprintf(nil "lpp=%L    default=OFF" lpp)
        )

        rows = append(rows list(list(name valueStr)))
      )
    else
      rows = list(list("Block Rule" "undefined"))
    )

    if(isCallable('kvShowInfoWindow) then
      kvShowInfoWindow("Block Rule Table" rows)
    else
      kvPrintBlockRuleTable()
    )
  )
)


printf("[KV_CAD] process/generate_block loaded\n")
