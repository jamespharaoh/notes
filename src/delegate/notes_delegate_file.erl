-module (notes_delegate_file).

-ifndef (TEST).

-export ([
	consult/1,
	open/2,
	close/1 ]).

consult (File) ->

	file:consult (File).

open (Path, Modes) ->

	file:open (Path, Modes).

close (IoDevice) ->

	file:close (IoDevice).

-endif.
