-module (data).

-export ([
	read/1,
	write/2 ]).

-ifdef (TEST).

full_path (Path) ->
	[ "test/", Path ].

-else.

full_path (Path) ->
	[ "data/", Path ].

-endif.

% public api

read (Path) ->

	FullPath = full_path (Path),

	% read records

	case file:consult (FullPath) of

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

	filelib:ensure_dir (FullPath),

	% open file

	{ ok, IoDevice } =
		file:open (FullPath, [ write ]),

	% write records

	lists:foreach (

		fun (Record) ->
			io:fwrite (IoDevice, "~p.~n", [ Record ])
			end,

		Records),

	% close file

	file:close (IoDevice),

	% return

	ok.
