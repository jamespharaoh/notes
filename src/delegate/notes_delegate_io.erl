-module (notes_delegate_io).

-ifndef (TEST).

-export ([
	fwrite/3 ]).

fwrite (IoDevice, Format, Args) ->

	io:fwrite (IoDevice, Format, Args).

-endif.
