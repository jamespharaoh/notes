-include_lib ("eunit/include/eunit.hrl").

-define (EXPECT,
	Em = em:new (),
	lists:foreach (
		fun (NotesTestModule) ->
			em:nothing (Em, NotesTestModule)
			end,
		?MOCK_MODULES)).

-define (REPLAY,
	em:replay (Em)).

-define (VERIFY,
	em:verify (Em)).

-define (NOTES_SERVER_TEST (Name, Args),

	?EXPECT,

		Message =
			case Args of
				[_|_] -> list_to_tuple ([ Name | Args ]);
				_ -> Name
				end,

		em:strict (Em, notes_server, call,
			[ ?SERVER, some_id, Message ],
			{ return, some_return }),

	?REPLAY,

		?assertEqual (
			some_return,
			apply (?TARGET, Name, [ some_id | Args ])),

	?VERIFY).
