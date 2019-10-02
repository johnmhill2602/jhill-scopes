# index oven video images

procedure mkindex ()

begin

delete ("index_all")

hselect ( "*.fts", 
	fields="$I,CAMERA,SHUTTER,GAIN,OFFSET,STROBES,TIME,CARD",
	expr='STROBES > 0', > "index_all" )

delete ("index_dark")

hselect ( "*.fts", 
	fields="$I,CAMERA,SHUTTER,GAIN,OFFSET,STROBES,TIME,CARD",
	expr='STROBES == 0', > "index_dark" )

delete ("indexA")
delete ("indexB")
delete ("indexC")
delete ("indexD")

match ( "A", "index_all") | fields (fields=1, >> "indexA" )
match ( "B", "index_all") | fields (fields=1, >> "indexB" )
match ( "C", "index_all") | fields (fields=1, >> "indexC" )
match ( "D", "index_all") | fields (fields=1, >> "indexD" )

delete ("darkA")
delete ("darkB")
delete ("darkC")
delete ("darkD")

match ( "A", "index_dark") | fields (fields=1, >> "darkA" )
match ( "B", "index_dark") | fields (fields=1, >> "darkB" )
match ( "C", "index_dark") | fields (fields=1, >> "darkC" )
match ( "D", "index_dark") | fields (fields=1, >> "darkD" )

end
