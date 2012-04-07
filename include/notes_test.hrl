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

-define (expect (Module, Function, Args, Return),

	case lists:member (Module, ?MOCK_MODULES) of

		true ->
			em:strict (Em, Module, Function, Args, Return);

		false ->
			throw (
				lists:flatten (
					io_lib:format (
						"Module not included in MOCK_MODULES: ~s",
						[ Module ])))

		end).

-define (NOTES_SERVER_TEST (Name, Args),

	?EXPECT,

		Message =
			case Args of
				[_|_] -> list_to_tuple ([ Name | Args ]);
				_ -> Name
				end,

		?expect (notes_server, call,
			[ ?SERVER, some_id, Message ],
			{ return, some_return }),

	?REPLAY,

		?assertEqual (
			some_return,
			apply (?TARGET, Name, [ some_id | Args ])),

	?VERIFY).
