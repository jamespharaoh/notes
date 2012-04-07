-module (notes_openid_test).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_test.hrl").
-include ("notes_data.hrl").

-compile (export_all).

-define (MOCK_MODULES, [
	notes_test_server_target ]).

-define (TARGET,
	notes_openid).

prepare_test () ->

	{ ok, Server } =
		notes_test_server:start_link (
			{ local, openid },
			notes_test_server_target),

	?EXPECT,

		em:strict (Em, notes_test_server_target, handle_call,

			[	{	prepare,
					"session id",
					"open id url",
					true },
				em:any (),
				em:any () ],

			{ function,
				fun ([ _Message, _From, State ]) ->
					{ reply, ok, State }
					end }),

	?REPLAY,

		?assertEqual (

			ok,

			?TARGET:prepare (
				"session id",
				"open id url",
				true)),

	?VERIFY,

	ok = notes_test_server:stop (Server).

verify_test () ->

	Params = [
		{ "param key", "param value" }
	],

	{ ok, Server } =
		notes_test_server:start_link (
			{ local, openid },
			notes_test_server_target),

	?EXPECT,

		em:strict (Em, notes_test_server_target, handle_call,

			[	{	verify,
					"session id",
					"return to",
					Params },
				em:any (),
				em:any () ],

			{ function,
				fun ([ _Message, _From, State ]) ->
					{ reply, ok, State }
					end }),

	?REPLAY,

		?assertEqual (

			ok,

			?TARGET:verify (
				"session id",
				"return to",
				Params)),

	?VERIFY,

	ok = notes_test_server:stop (Server).
