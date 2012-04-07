-module (notes_server_test).

-include ("notes_test.hrl").

% macros

-define (MOCK_MODULES, [
	notes_test_server_stub,
	notes_test_server_target ]).

-define (TARGET, notes_server).

-define (SERVER, notes_test_server).

-define (STUB, notes_test_server_stub).

call_new_process_test () ->

	Message = "the message",

	?EXPECT,

		?expect (?STUB, handle_call,

			[	Message,
				em:any (),
				em:any () ],

			{	function,
				fun ([ _Message, _From, State ]) ->
					{ reply, ok, State }
					end }),

	?REPLAY,

		?assertEqual (

			ok,

			?TARGET:call (
				?SERVER,
				?STUB,
				Message)),

	?VERIFY,

	gen_server:call (
		{ global, { ?SERVER, ?STUB } },
		stop).

call_existing_process_test () ->

	Message = "the message",

	notes_test_server:start_link (
		{ global, { ?SERVER, ?STUB } },
		?STUB),

	?EXPECT,

		?expect (?STUB, handle_call,

			[	Message,
				em:any (),
				em:any () ],

			{	function,
				fun ([ _Message, _From, State ]) ->
					{ reply, ok, State }
					end }),

	?REPLAY,

		?assertEqual (

			ok,

			?TARGET:call (
				?SERVER,
				?STUB,
				Message)),

	?VERIFY,

	gen_server:call (
		{ global, { ?SERVER, ?STUB } },
		stop).
