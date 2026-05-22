procedure(QUICK_MOVE()
	prog((WIN_FORM KEVIN_UP KEVIN_DOWN KEVIN_LEFT KEVIN_RIGHT KEVIN_VALUE)

		KEVIN_UP = hiCreateButton(?name      'KEVIN_UP
		                          ?buttonText "UP"
				          ?callback  "kevin_quick_move(\"UP\")"
						)
		KEVIN_DOWN = hiCreateButton(?name      'KEVINDOWN
		                          ?buttonText "DOWN"
				          ?callback  "kevin_quick_move(\"DOWN\")"
						)
		KEVIN_LEFT = hiCreateButton(?name      'KEVIN_LEFT
		                          ?buttonText "LEFT"
				          ?callback  "kevin_quick_move(\"LEFT\")"
						)
		
              KEVIN_RIGHT = hiCreateButton(?name      'KEVIN_RIGHT
		                          ?buttonText "RIGHT"
				          ?callback  "kevin_quick_move(\"RIGHT\")"
						)
		KEVIN_VALUE = hiCreateFloatField(?name      'KEVIN_VALUE
		                                 ?value 50.0
						)
		WIN_FORM = hiCreateAppForm(?name 'QUICK_MOVE
					   ?formTitle    "QUICK_MOVE"
					   ?fields     list(list(KEVIN_UP  100:10 60:30  )
							    list(KEVIN_DOWN   100:90 60:30 )
							    list(KEVIN_LEFT   20:50 60:30  )
							    list(KEVIN_RIGHT  190:50 60:30  )
							    list(KEVIN_VALUE      100:50 60:30  )
							)
					   ?buttonLayout  'OKCancel
					   ?initialSize   1000:150
						)
				hiDisplayForm(WIN_FORM)
);prog
);proc

procedure(kevin_quick_move(direction)
	prog((current_form win cv obj objs value)
		current_form = hiGetCurrentForm()
		cv=geGetEditCellView()
		objs=geGetSelSet()
		value=current_form->KEVIN_VALUE->value
		for(i 0 length(objs)-1
			obj=nth(i objs)
			if(direction == "UP" then dbMoveFig(obj nil list(0:0+value "R0") ))
			if(direction == "DOWN" then dbMoveFig(obj nil list(0:0-value "R0") ))
			if(direction == "LEFT" then dbMoveFig(obj nil list(0-value:0 "R0") ))
			if(direction == "RIGHT" then dbMoveFig(obj nil list(0+value:0 "R0") ))
		)
)
)

printf("kevin_quick_move  loaded\n")

