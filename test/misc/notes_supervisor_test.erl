-module (notes_supervisor_test).

-include ("notes_global.hrl").
-include ("notes_test.hrl").

% macros

-define (MOCK_MODULES, [
	nitrogen,
	notes_config,
	notes_delegate_supervisor,
	simple_bridge ]).

-define (TARGET, notes_supervisor).

% tests

start_link_test () ->

	Name = { local, ?TARGET },

	?EXPECT,

		?expect (notes_delegate_supervisor, start_link,
			[ Name, ?TARGET, [] ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:start_link ()),

	?VERIFY.

init_test () ->

	MochiOptions = [
		{ ip, "1.2.3.4" },
		{ port, 5678 },
		{ loop, fun ?TARGET:loop/1 }
	],

	?EXPECT,

		?expect (notes_config, get,
			[ bind_address ],
			{ return, { ok, "1.2.3.4" } }),

		?expect (notes_config, get,
			[ port ],
			{ return, { ok, 5678 } }),

	?REPLAY,

		?assertEqual (

			{	ok,

				{	{ one_for_one, 5, 100 },

					[	{	mochiweb,
							{ mochiweb_http, start_link, [ MochiOptions ] },
							permanent,
							10000,
							worker,
							[ mochiweb_http ] },

						{	openid,
							{ openid_srv, start_link, [ openid ] },
							permanent,
							10000,
							worker,
							[ openid_srv ] }
					]
				}
			},

			?TARGET:init ([ ])),

	?VERIFY.

loop_test () ->

	?EXPECT,

		?expect (notes_config, get,
			[ document_root ],
			{ return, { ok, "document root" } }),

		?expect (simple_bridge, make_request,
			[ mochiweb_request_bridge, { "request", "document root" } ],
			{ return, "request bridge" }),

		?expect (simple_bridge, make_response,
			[ mochiweb_response_bridge, { "request", "document root" } ],
			{ return, "response bridge" }),

		?expect (nitrogen, init_request,
			[ "request bridge", "response bridge" ],
			{ return, "response bridge" }),

		?expect (nitrogen, run,
			[ ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:loop ("request")),

	?VERIFY.
