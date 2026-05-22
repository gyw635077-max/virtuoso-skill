/*------------------------------------------------------------
 * Get FEOL layer by alias
 *
 * Preferred:
 *   KevinFeolAliasTable = list(
 *     list("NW"  list("NW"  "drawing"))
 *     list("DNW" list("DNW" "drawing"))
 *   )
 *
 * Fallback:
 *   use defaultLpp
 *-----------------------------------------------------------*/
procedure(TrGetFeolLayerByAlias(aliasName defaultLpp)
    let((result name lpp)

        result = nil

        when(boundp('KevinFeolAliasTable) && KevinFeolAliasTable
            foreach(item KevinFeolAliasTable
                name = nth(0 item)
                lpp  = nth(1 item)

                when(name == aliasName
                    result = lpp
                )
            )
        )

        unless(result
            TrNwDnwMsg(
                sprintf(nil
                    "Warning: FEOL alias %s not found. Use default layer: %L"
                    aliasName defaultLpp
                )
            )
            result = defaultLpp
        )

        result
    )
)

/*******************************************************************************
* Procedure : TrCreateRectNwDnw
* Function  : Create merged NW ring and DNW rectangle based on selected bbox
* Version   : V1.1
*
* Feature:
*   1. Create NW ring around selected object's bbox
*   2. Merge 4 NW rectangles into one merged shape
*   3. Create DNW rectangle inside NW ring
*******************************************************************************/


procedure(TrNwDnwMsg(msg)
    printf("[TrCreateRectNwDnw] %s\n" msg)
)


procedure(TrNwDnwErrorBox(boxName msg)
    hiDisplayAppDBox(
        ?name boxName
        ?dboxText msg
        ?dialogType hicErrorDialog
        ?buttonLayout 'Close
    )
)


procedure(TrNwDnwInfoBox(boxName msg)
    hiDisplayAppDBox(
        ?name boxName
        ?dboxText msg
        ?dialogType hicInformationDialog
        ?buttonLayout 'Close
    )
)


/*------------------------------------------------------------
 * Merge created NW rectangles
 *-----------------------------------------------------------*/
procedure(TrMergeNwRing(nwRects)
    let((mergeResult)

        mergeResult = nil

        when(nwRects
            mergeResult = errset(
                leMergeShapes(nwRects)
                nil
            )

            if(mergeResult then
                TrNwDnwMsg("NW ring rectangles merged.")
            else
                TrNwDnwMsg("Warning: leMergeShapes failed. NW ring remains as 4 rectangles.")
            )
        )

        mergeResult
    )
)


/*------------------------------------------------------------
 * Core function
 *-----------------------------------------------------------*/
procedure(TrCreateMergedNwDnwByBBox(cv bBox nwWidth dnwEncl nwLayer dnwLayer)
    let((halfWidth
         x1 y1 x2 y2
         outX1 outY1 outX2 outY2
         inX1 inY1 inX2 inY2
         dnwX1 dnwY1 dnwX2 dnwY2
         nwTop nwBottom nwLeft nwRight nwRects
         created)

        created = nil
        nwRects = nil

        halfWidth = nwWidth / 2.0

        x1 = xCoord(lowerLeft(bBox))
        y1 = yCoord(lowerLeft(bBox))
        x2 = xCoord(upperRight(bBox))
        y2 = yCoord(upperRight(bBox))

        /********************************************************
         * NW outer boundary
         ********************************************************/
        outX1 = x1 - halfWidth
        outY1 = y1 - halfWidth
        outX2 = x2 + halfWidth
        outY2 = y2 + halfWidth

        /********************************************************
         * NW inner boundary
         ********************************************************/
        inX1 = x1 + halfWidth
        inY1 = y1 + halfWidth
        inX2 = x2 - halfWidth
        inY2 = y2 - halfWidth

        if(inX2 <= inX1 || inY2 <= inY1 then
            TrNwDnwMsg(
                sprintf(nil
                    "Skipped: bbox is too small for NW ring. BBox=(%g %g) (%g %g), NW width=%g"
                    x1 y1 x2 y2 nwWidth
                )
            )
        else
            /****************************************************
             * Create 4 NW rectangles first
             ****************************************************/

            nwTop = dbCreateRect(
                cv
                nwLayer
                list(
                    list(outX1 inY2)
                    list(outX2 outY2)
                )
            )

            nwBottom = dbCreateRect(
                cv
                nwLayer
                list(
                    list(outX1 outY1)
                    list(outX2 inY1)
                )
            )

            nwLeft = dbCreateRect(
                cv
                nwLayer
                list(
                    list(outX1 inY1)
                    list(inX1 inY2)
                )
            )

            nwRight = dbCreateRect(
                cv
                nwLayer
                list(
                    list(inX2 inY1)
                    list(outX2 inY2)
                )
            )

            nwRects = list(nwTop nwBottom nwLeft nwRight)

            /****************************************************
             * Merge NW 4 rectangles into one merged shape
             ****************************************************/
            TrMergeNwRing(nwRects)

            /****************************************************
             * Create DNW rectangle
             ****************************************************/
            dnwX1 = outX1 + dnwEncl
            dnwY1 = outY1 + dnwEncl
            dnwX2 = outX2 - dnwEncl
            dnwY2 = outY2 - dnwEncl

            if(dnwX2 > dnwX1 && dnwY2 > dnwY1 then
                dbCreateRect(
                    cv
                    dnwLayer
                    list(
                        list(dnwX1 dnwY1)
                        list(dnwX2 dnwY2)
                    )
                )

                created = t

                TrNwDnwMsg(
                    sprintf(nil
                        "Created merged NW ring and DNW. BBox=(%g %g) (%g %g)"
                        x1 y1 x2 y2
                    )
                )
            else
                created = t

                TrNwDnwMsg(
                    sprintf(nil
                        "Created merged NW ring only. DNW area is too small. DNW=(%g %g) (%g %g)"
                        dnwX1 dnwY1 dnwX2 dnwY2
                    )
                )
            )
        )

        created
    )
)


/*------------------------------------------------------------
 * Main function with process-aware NW/DNW layers
 *-----------------------------------------------------------*/
procedure(TrCreateRectNwDnw()
    let((cv selSet
         nwWidth dnwEncl
         nwLayer dnwLayer
         count createdCount)

        cv = geGetEditCellView()
        selSet = geGetSelSet()

        nwWidth = 1.4
        dnwEncl = 1.0

        ; Get NW/DNW from current process config.
        ; The alias table should be defined in metal_stack_<process>.il:
        ;
        ;   KevinFeolAliasTable = list(
        ;     list("NW"  list("NW"  "drawing"))
        ;     list("DNW" list("DNW" "drawing"))
        ;   )
        ;
        nwLayer  = TrGetFeolLayerByAlias("NW"  list("NW"  "drawing"))
        dnwLayer = TrGetFeolLayerByAlias("DNW" list("DNW" "drawing"))

        count = 0
        createdCount = 0

        if(cv == nil then
            TrNwDnwErrorBox(
                'TrNwDnwNoCV
                "No editable layout cellview found."
            )
        else
            if(selSet == nil then
                TrNwDnwErrorBox(
                    'TrNwDnwNoSelection
                    "No objects selected. Please select one or more layout objects first."
                )
            else
                foreach(obj selSet
                    when(obj~>bBox
                        count = count + 1

                        when(
                            TrCreateMergedNwDnwByBBox(
                                cv
                                obj~>bBox
                                nwWidth
                                dnwEncl
                                nwLayer
                                dnwLayer
                            )
                            createdCount = createdCount + 1
                        )
                    )
                )

                hiRedraw()

                TrNwDnwInfoBox(
                    'TrNwDnwDone
                    sprintf(nil
                        "NW/DNW creation finished.\n\nSelected objects processed: %d\nSuccessfully created: %d\n\nNW layer: %L\nDNW layer: %L\nNW width: %g um\nDNW enclosure: %g um"
                        count createdCount nwLayer dnwLayer nwWidth dnwEncl
                    )
                )
            )
        )
    )
)

/*------------------------------------------------------------
 * Optional bindkey
 *-----------------------------------------------------------*/
hiSetBindKey("Layout" "Ctrl Shift <Key>d" "TrCreateRectNwDnw()")
