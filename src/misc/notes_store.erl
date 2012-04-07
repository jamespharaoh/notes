-module (notes_store).

-export ([
	read/1,
	write/2,
	delete_all/0 ]).

-include ("notes_global.hrl").

-ifdef (TEST).
-define (DIR, "test").
-else.
-define (DIR, "data").
-endif.

full_path (Path) ->
	[ ?DIR, "/", Path ].

% public api

read (Path) ->

	FullPath = full_path (Path),

	% read records

	case notes_delegate_file:consult (FullPath) of

		{ ok, Records } ->

			% return

			{ ok, Records };

		{ error, enoent } ->

			% not found, return empty

			{ ok, [] }

	end.

write (Path, Records) ->

	FullPath = full_path (Path),

	% make sure directory exists

	ok =
		notes_delegate_filelib:ensure_dir (FullPath),

	% open file

	{ ok, IoDevice } =
		notes_delegate_file:open (FullPath, [ write ]),

	% write records

	lists:foreach (

		fun (Record) ->

			ok =
				notes_delegate_io:fwrite (
					IoDevice,
					"~p.~n",
					[ Record ])

			end,

		Records),

	% close file

	ok =
		notes_delegate_file:close (IoDevice),

	% return

	ok.

delete_all () ->

	notes_file:delete_dir (?DIR).
