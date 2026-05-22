procedure(Zoom_To_Point()
	prog((WIN_FORM X_Coord Y_Coord SCALE)
		X_Coord = hiCreateFloatField(?name      'X_Coord
					     ?prompt    "Coordinate X:"
					     ?value     0.0
						)
		Y_Coord = hiCreateFloatField(?name      'Y_Coord
					     ?prompt    "Coordinate y:"
					     ?value     0.0
						)
		SCALE =   hiCreateFloatField(?name      'SCALE
					     ?prompt    "Scale Rate:"
					     ?value     50.0
						)
		WIN_FORM = hiCreateAppForm(?name 'Zoom_To_Point
					   ?formTitle    "Zoom_To_Point"
					   ?callback   "kevin_zoom_to_point()"
					   ?fields     list(list(X_Coord    30:15 200:30  110)
							    list(Y_Coord    30:50 200:30  110)
							    list(SCALE      30:86 200:30  110)
							)
					   ?buttonLayout  'OKCancelDefApply
					   ?initialSize   1000:150
						)
				hiDisplayForm(WIN_FORM)
);prog
);proc

procedure(kevin_zoom_to_point()
	prog((current_form win x_coord y_coord scale_rate)
		current_form = hiGetCurrentForm()
		win =hiGetCurrentWindow()
		hiZoomAbsoluteScale(win 0.9)
		x_coord = float(current_form->X_Coord->value)
		y_coord = float(current_form->Y_Coord->value)
		scale_rate = float(current_form->SCALE->value)
		hiZoomWindowAtPoint(win scale_rate list(x_coord y_coord))
		leZoomToPoint(win list(x_coord y_coord))
		ts_cross_ruler()
)
)

printf("zoom_to_point  loaded\n")

