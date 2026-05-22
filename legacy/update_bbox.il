procedure(update_bbox()
	prog((cv obj shape)
	cv =geGetEditCellView()
	foreach(obj cv->steiners dbDeleteObject(obj))
	foreach(obj cv->guides   dbDeleteObject(obj))
	foreach(obj cv->markers  dbDeleteObject(obj))
	foreach(obj getEditRep()~>lpps
		if(obj~>layerName == "changedLayer"
			then 
			foreach(shape obj~>shapes
				dbDeleteObject(shape)	
				)
			)
		)
	)
)
printf("update_bbox loaded\n")
