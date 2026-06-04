/*******************************************************************************
* Procedure : TrDummyNetCleanSelected
* Function  : Remove wrong XL net information from selected dummy devices/figures
* Version   : V1.0
*
* Usage:
*   1. Select dummy instance / dummy shapes in layout XL
*   2. Run TrDummyNetCleanPreview() first
*   3. Run TrDummyNetCleanSelected() to really clear net info
*
* Scope:
*   - selected figures with net info
*   - selected instance terminals with net info
*
* Safe policy:
*   - Do not delete any geometry
*   - Do not modify master cell
*   - Do not modify non-selected objects
*******************************************************************************/


/*------------------------------------------------------------
 * Global counters
 *-----------------------------------------------------------*/
TrDN_checkedCnt = 0
TrDN_netFoundCnt = 0
TrDN_clearCnt = 0
TrDN_failCnt = 0


/*------------------------------------------------------------
 * Message helper
 *-----------------------------------------------------------*/
procedure(TrDNMsg(msg)
    printf("[TrDummyNetClean] %s\n" msg)
)


/*------------------------------------------------------------
 * Dialog helpers
 *-----------------------------------------------------------*/
procedure(TrDNErrorBox(boxName msg)
    hiDisplayAppDBox(
        ?name boxName
        ?dboxText msg
        ?dialogType hicErrorDialog
        ?buttonLayout 'Close
    )
)


procedure(TrDNInfoBox(boxName msg)
    hiDisplayAppDBox(
        ?name boxName
        ?dboxText msg
        ?dialogType hicInformationDialog
        ?buttonLayout 'Close
    )
)


/*------------------------------------------------------------
 * Reset counters
 *-----------------------------------------------------------*/
procedure(TrDNResetCounter()
    TrDN_checkedCnt = 0
    TrDN_netFoundCnt = 0
    TrDN_clearCnt = 0
    TrDN_failCnt = 0
)


/*------------------------------------------------------------
 * Safe get objType
 *-----------------------------------------------------------*/
procedure(TrDNGetObjType(obj)
    let((r)
        r = errset(obj~>objType nil)
        if(r then
            car(r)
        else
            "UNKNOWN"
        )
    )
)


/*------------------------------------------------------------
 * Safe get object name
 *-----------------------------------------------------------*/
procedure(TrDNGetObjName(obj)
    let((r)
        r = errset(obj~>name nil)
        if(r then
            car(r)
        else
            ""
        )
    )
)


/*------------------------------------------------------------
 * Safe get net object
 *-----------------------------------------------------------*/
procedure(TrDNGetNet(obj)
    let((r)
        r = errset(obj~>net nil)
        if(r then
            car(r)
        else
            nil
        )
    )
)


/*------------------------------------------------------------
 * Safe get net name
 *-----------------------------------------------------------*/
procedure(TrDNGetNetName(obj)
    let((net r name)
        name = ""
        net = TrDNGetNet(obj)

        when(net
            r = errset(net~>name nil)
            if(r then
                name = car(r)
            else
                name = "<net-without-name>"
            )
        )

        name
    )
)


/*------------------------------------------------------------
 * Safe clear net slot
 * dryRun = t   : only report
 * dryRun = nil : really clear obj~>net
 *-----------------------------------------------------------*/
procedure(TrDNClearNetSlot(obj objDesc dryRun)
    let((netName r)

        TrDN_checkedCnt = TrDN_checkedCnt + 1
        netName = TrDNGetNetName(obj)

        when(netName != ""
            TrDN_netFoundCnt = TrDN_netFoundCnt + 1

            if(dryRun then
                printf("[TrDummyNetClean][Preview] %s has net: %s  obj=%L\n"
                    objDesc netName obj
                )
            else
                r = errset(obj~>net = nil nil)

                if(r then
                    TrDN_clearCnt = TrDN_clearCnt + 1
                    printf("[TrDummyNetClean][Clean] Cleared %s net: %s  obj=%L\n"
                        objDesc netName obj
                    )
                else
                    TrDN_failCnt = TrDN_failCnt + 1
                    printf("[TrDummyNetClean][Failed] Cannot clear %s net: %s  obj=%L\n"
                        objDesc netName obj
                    )
                )
            )
        )
    )
)


/*------------------------------------------------------------
 * Get instance terms safely
 *-----------------------------------------------------------*/
procedure(TrDNGetInstTerms(inst)
    let((r)
        r = errset(inst~>instTerms nil)
        if(r then
            car(r)
        else
            nil
        )
    )
)


/*------------------------------------------------------------
 * Clean selected instance terminal net info
 *-----------------------------------------------------------*/
procedure(TrDNCleanInst(inst dryRun)
    let((terms instName instType termName desc)

        instName = TrDNGetObjName(inst)
        instType = TrDNGetObjType(inst)

        printf("[TrDummyNetClean] Check instance: %s  type=%s  obj=%L\n"
            instName instType inst
        )

        terms = TrDNGetInstTerms(inst)

        if(terms then
            foreach(instTerm terms
                termName = TrDNGetObjName(instTerm)

                if(termName && termName != "" then
                    desc = sprintf(nil "instTerm %s/%s" instName termName)
                else
                    desc = sprintf(nil "instTerm %s/<unknownTerm>" instName)
                )

                TrDNClearNetSlot(instTerm desc dryRun)
            )
        else
            printf("[TrDummyNetClean] No instTerms found on instance: %s\n" instName)
        )
    )
)


/*------------------------------------------------------------
 * Clean selected figure net info
 *-----------------------------------------------------------*/
procedure(TrDNCleanFig(fig dryRun)
    let((objType desc)

        objType = TrDNGetObjType(fig)
        desc = sprintf(nil "figure type=%s" objType)

        TrDNClearNetSlot(fig desc dryRun)
    )
)


/*------------------------------------------------------------
 * Decide how to handle selected object
 *-----------------------------------------------------------*/
procedure(TrDNProcessSelectedObj(obj dryRun)
    let((objType)

        objType = TrDNGetObjType(obj)

        cond(
            /*
             * Layout instances / mosaics
             * Main target for dummy devices in XL.
             */
            ((objType == "inst" || objType == "mosaicInst")
                TrDNCleanInst(obj dryRun)
            )

            /*
             * Common layout figures.
             * If dummy shape accidentally got net info, clear it.
             */
            ((objType == "rect" ||
              objType == "path" ||
              objType == "pathSeg" ||
              objType == "polygon" ||
              objType == "label")
                TrDNCleanFig(obj dryRun)
            )

            /*
             * Other selectable db objects.
             * Still try to clear net slot safely.
             */
            (t
                printf("[TrDummyNetClean] Unknown/other objType=%s, try safe net cleanup. obj=%L\n"
                    objType obj
                )
                TrDNClearNetSlot(obj sprintf(nil "object type=%s" objType) dryRun)
            )
        )
    )
)


/*------------------------------------------------------------
 * Main engine
 * dryRun = t   preview only
 * dryRun = nil real clean
 *-----------------------------------------------------------*/
procedure(TrDummyNetCleanEngine(dryRun)
    let((cv selSet modeText)

        cv = geGetEditCellView()
        selSet = geGetSelSet()

        if(dryRun then
            modeText = "Preview"
        else
            modeText = "Clean"
        )

        TrDNResetCounter()

        if(cv == nil then
            TrDNErrorBox(
                'TrDNNoCV
                "No editable layout cellview found."
            )
        else
            if(selSet == nil then
                TrDNErrorBox(
                    'TrDNNoSelection
                    "No object selected.\n\nPlease select dummy instances or dummy figures first."
                )
            else
                printf("\n")
                printf("============================================================\n")
                printf("[TrDummyNetClean] Mode: %s\n" modeText)
                printf("[TrDummyNetClean] CellView: %s / %s / %s\n"
                    cv~>libName cv~>cellName cv~>viewName
                )
                printf("============================================================\n")

                foreach(obj selSet
                    TrDNProcessSelectedObj(obj dryRun)
                )

                printf("============================================================\n")
                printf("[TrDummyNetClean] Summary\n")
                printf("  Checked objects/terms : %d\n" TrDN_checkedCnt)
                printf("  Net info found        : %d\n" TrDN_netFoundCnt)

                if(dryRun then
                    printf("  Cleared               : 0  preview only\n")
                else
                    printf("  Cleared               : %d\n" TrDN_clearCnt)
                    printf("  Failed                : %d\n" TrDN_failCnt)
                )

                printf("============================================================\n")

                if(dryRun then
                    TrDNInfoBox(
                        'TrDNPreviewDone
                        sprintf(nil
                            "Preview finished.\n\nChecked objects/terms: %d\nNet info found: %d\n\nNo database modification was made."
                            TrDN_checkedCnt TrDN_netFoundCnt
                        )
                    )
                else
                    hiRedraw()

                    TrDNInfoBox(
                        'TrDNCleanDone
                        sprintf(nil
                            "Dummy net cleanup finished.\n\nChecked objects/terms: %d\nNet info found: %d\nCleared: %d\nFailed: %d"
                            TrDN_checkedCnt TrDN_netFoundCnt TrDN_clearCnt TrDN_failCnt
                        )
                    )
                )
            )
        )
    )
)


/*------------------------------------------------------------
 * Public entry: preview
 *-----------------------------------------------------------*/
procedure(TrDummyNetCleanPreview()
    TrDummyNetCleanEngine(t)
)


/*------------------------------------------------------------
 * Public entry: real clean
 *-----------------------------------------------------------*/
procedure(TrDummyNetCleanSelected()
    TrDummyNetCleanEngine(nil)
)


/*------------------------------------------------------------
 * Optional bindkeys
 *-----------------------------------------------------------*/
/*
 * Preview:
 *   Ctrl + Shift + n
 *
 * Real clean:
 *   Ctrl + Shift + Alt + n
 *
 * You can change them according to your bindkey rule.
 */
hiSetBindKey("Layout" "Ctrl Shift <Key>n" "TrDummyNetCleanPreview()")
hiSetBindKey("Layout" "Ctrl Shift Alt <Key>n" "TrDummyNetCleanSelected()")
