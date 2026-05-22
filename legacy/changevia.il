procedure(changeViaRow(num)
	prog((objs row)
	objs=geGetSelSet()
	foreach(obj objs
		row=obj~>cutRows
		if(num == 1 then
			obj~>cutRows=row+1
			else
			obj~>cutRows=row-1
			);if
		);for
);prog
);proc
hiSetBindKey("Layout" "Shift<Btn4Down>" "changeViaRow(1)")
hiSetBindKey("Layout" "Shift<Btn5Down>" "changeViaRow(-1)")


procedure(changeViaColumn(num)
        prog((objs column)
        objs=geGetSelSet()
        foreach(obj objs
                column=obj~>cutColumns
                if(num == 1 then
                        obj~>cutColumns=column+1
                        else
                        obj~>cutColumns=column-1
                        );if
                );for
);prog
);proc
hiSetBindKey("Layout" "Ctrl<Btn4Down>" "changeViaColumn(1)")
hiSetBindKey("Layout" "Ctrl<Btn5Down>" "changeViaColumn(-1)")
