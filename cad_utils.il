; ============================================================
; Kevin CAD Toolkit Utilities
; File: core/cad_utils.il
; Purpose:
;   Common utility functions for layer, form and list handling.
; ============================================================


; ------------------------------------------------------------
; Basic nil / valid check
; ------------------------------------------------------------

procedure(kvIsNil(value)
  value == nil || value == list()
)


procedure(kvIsValid(value)
  value != nil && value != list()
)


; ------------------------------------------------------------
; Layer validation
; A valid layer is usually like:
;   list("M1" "drawing")
;   list("M1" "pin")
; ------------------------------------------------------------

procedure(kvValidLayer(layer)
  layer != nil && layer != list()
)


; ------------------------------------------------------------
; Safe set entry layer
; ------------------------------------------------------------

procedure(kvSetEntryLayer(layer)
  when(kvValidLayer(layer)
    leSetEntryLayer(layer)
  )
)


; ------------------------------------------------------------
; Safe show layer
; ------------------------------------------------------------

procedure(kvShowLayer(layer)
  when(kvValidLayer(layer)
    leSetLayerVisible(layer t)
  )
)


; ------------------------------------------------------------
; Safe hide layer
; ------------------------------------------------------------

procedure(kvHideLayer(layer)
  when(kvValidLayer(layer)
    leSetLayerVisible(layer nil)
  )
)


; ------------------------------------------------------------
; Safe set all layer visible / invisible
; ------------------------------------------------------------

procedure(kvSetAllLayerVisible(flag)
  leSetAllLayerVisible(flag)
)


; ------------------------------------------------------------
; Safe zoom update
; ------------------------------------------------------------

procedure(kvRefreshDisplay()
  hiZoomRelativeScale()
)


; ------------------------------------------------------------
; Get form field value safely
; Example:
;   kvGetFormFieldValue(form 'metal1_info)
; ------------------------------------------------------------

procedure(kvGetFormFieldValue(form fieldName)
  let((field)

    if(form then
      field = get(form fieldName)
    else
      field = nil
    )

    if(field then
      field->value
    else
      nil
    )
  )
)


; ------------------------------------------------------------
; Set form field value safely
; Example:
;   kvSetFormFieldValue(form 'metal1_info list("M1" "drawing"))
; ------------------------------------------------------------

procedure(kvSetFormFieldValue(form fieldName value)
  let((field)

    if(form then
      field = get(form fieldName)
    else
      field = nil
    )

    when(field && value != nil
      field->value = value
    )
  )
)


; ------------------------------------------------------------
; Get current edit cellView safely
; ------------------------------------------------------------

procedure(kvGetEditCellView()
  let((cv)
    cv = geGetEditCellView()

    unless(cv
      printf("[KV_CAD][WARN] No edit cellView.\n")
    )

    cv
  )
)


; ------------------------------------------------------------
; Get selected object list safely
; ------------------------------------------------------------

procedure(kvGetSelSet()
  let((objList)
    objList = geGetSelSet()

    unless(objList && length(objList) > 0
      printf("[KV_CAD][WARN] No selected object.\n")
    )

    objList
  )
)


; ------------------------------------------------------------
; Check whether a SKILL symbol is defined
; ------------------------------------------------------------

procedure(kvIsBound(sym)
  boundp(sym)
)


printf("[KV_CAD] cad_utils loaded\n")
