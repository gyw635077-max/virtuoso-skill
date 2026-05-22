; ============================================================
; Kevin CAD Toolkit - Metal Change Tool
; File:
;   tools/metal_change.il
;
; Purpose:
;   Change selected layout objects to target metal layer.
;
; Usage:
;   metal_change(list("M1" "drawing"))
;   metal_change(list("M2" "drawing"))
;
; Mode:
;   KevinMetalChangeMode = "layerOnly"
;     Only change obj~>layerName.
;
;   KevinMetalChangeMode = "lpp"
;     Change obj~>lpp.
; ============================================================


; ------------------------------------------------------------
; Default mode
; This variable is normally initialized in core/cad_env.il.
; ------------------------------------------------------------

unless(boundp('KevinMetalChangeMode)
  KevinMetalChangeMode = "layerOnly"
)


; ------------------------------------------------------------
; Check whether object can be changed
; ------------------------------------------------------------

procedure(kvCanChangeLayer(obj)
  obj &&
  member(obj~>objType list("rect" "path" "polygon" "label" "pathSeg"))
)


; ------------------------------------------------------------
; Change one object to target layer
; ------------------------------------------------------------

procedure(kvChangeObjectToLayer(obj targetLpp)
  let((targetLayer)

    when(kvCanChangeLayer(obj) && kvValidLayer(targetLpp)

      cond(
        ((KevinMetalChangeMode == "lpp")
          ; Change both layer and purpose
          obj~>lpp = targetLpp
        )

        (t
          ; Keep original behavior:
          ; only change layerName, do not touch purpose.
          targetLayer = car(targetLpp)
          obj~>layerName = targetLayer
        )
      )

      t
    )
  )
)


; ------------------------------------------------------------
; Main function
; Keep original function name for compatibility:
;   metal_change(metal)
; ------------------------------------------------------------

procedure(metal_change(targetLpp)
  let((cv objList obj changedCount skippedCount)

    cv = geGetEditCellView()
    objList = geGetSelSet()

    changedCount = 0
    skippedCount = 0

    cond(
      ((cv == nil)
        printf("[KV_CAD][metal_change][ERROR] No edit cellView.\n")
        nil
      )

      ((objList == nil || length(objList) == 0)
        printf("[KV_CAD][metal_change][WARN] No selected object.\n")
        nil
      )

      ((kvValidLayer(targetLpp) == nil)
        printf("[KV_CAD][metal_change][WARN] Invalid target layer: %L\n" targetLpp)
        nil
      )

      (t
        foreach(obj objList
          if(kvChangeObjectToLayer(obj targetLpp) then
            changedCount = changedCount + 1
          else
            skippedCount = skippedCount + 1
          )
        )

        printf(
          "[KV_CAD][metal_change] Target=%L  Changed=%d  Skipped=%d  Mode=%s\n"
          targetLpp
          changedCount
          skippedCount
          KevinMetalChangeMode
        )

        t
      )
    )
  )
)


; ------------------------------------------------------------
; Convenient debug function
; ------------------------------------------------------------

procedure(kvPrintMetalChangeMode()
  printf("[KV_CAD] KevinMetalChangeMode = %s\n" KevinMetalChangeMode)
)


printf("[KV_CAD] metal_change loaded\n")
