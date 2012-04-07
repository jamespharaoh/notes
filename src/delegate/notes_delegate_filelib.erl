-module (notes_delegate_filelib).

-ifndef (TEST).

-export ([
	ensure_dir/1 ]).

ensure_dir (File) ->

	filelib:ensure_dir (File).

-endif.
