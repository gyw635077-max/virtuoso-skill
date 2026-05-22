procedure(ts_cross_ruler()
	prog((cv win ref boundary x1 y1 x2 y2 point coordinate_x coordinate_y)
	cv = geGetEditCellView()
	win = hiGetCurrentWindow()
	ref = hiGetPoint(win)
	point = geWindowToEditPoint(win,ref)
	leHiClearRuler()
	boundary = cv->bBox
	x1 = nth(0 nth(0 boundary))
	y1 = nth(1 nth(0 boundary))
	x2 = nth(0 nth(1 boundary))
	y2 = nth(1 nth(1 boundary))
	coordinate_x = nth(0 point)
	coordinate_y = nth(1 point)
	dbCreateRuler(cv list(point list(x1-200 coordinate_y)))
	dbCreateRuler(cv list(point list(x1-200 coordinate_y+abs(coordinate_x+200-x1))))
	dbCreateRuler(cv list(point list(coordinate_x y2+200)))
	dbCreateRuler(cv list(point list(x2+200 coordinate_y+abs(x2+200-coordinate_x))))
	dbCreateRuler(cv list(point list(x2+200 coordinate_y)))
	dbCreateRuler(cv list(point list(x2+200 coordinate_y-abs(x2+200-coordinate_x))))
	dbCreateRuler(cv list(point list(coordinate_x y1-200)))
	dbCreateRuler(cv list(point list(x1-200 coordinate_y-abs(coordinate_x+200-x1))))
	);prog
);procedure
printf("cross_ruler load\n")





