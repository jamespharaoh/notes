-module (data).

-export ([

	read/1,
	write/2 ]).

% public api

read (Path) ->

	case file:consult (Path) of

		{ ok, Records } ->
			{ ok, Records };

		{ error, enoent } ->
			{ ok, [] }

	end.

write (Path, Records) ->

	filelib:ensure_dir (Path),

	{ ok, IoDevice } =
		file:open (Path, [ write ]),

	lists:foreach (

		fun (Record) ->
			io:fwrite (IoDevice, "~p.~n", [ Record ])
			end,

		Records),

	file:close (IoDevice),

	ok.
