-module (notes_server).

-export ([
	call/3 ]).

call (Mod, Id, Message) ->

	gen_server:call (
		get_pid (Mod, Id),
		Message).

get_pid (Mod, Id) ->

	Name = { Mod, Id },

	case gen_server:start_link (
		{ global, Name },
		Mod,
		[ Id ],
		[]) of

		{ error, { already_started, Pid }} ->
			Pid;

		{ ok, Pid } ->
			Pid

	end.
