-module (notes_sup).

-behaviour (supervisor).

-export ([
	start_link/0,
	init/1,
	loop/1 ]).

%% =============================================================== api functions

start_link () ->

	supervisor:start_link (
		{ local, ?MODULE },
		?MODULE,
		[]).

%% ======================================================== supervisor callbacks

init ([]) ->

	% start process registry

	application:start (nprocreg),

	% start mochiweb

	application:load (mochiweb),

	{ ok, BindAddress } =
		application:get_env (bind_address),

	{ ok, Port } =
		application:get_env (port),

	{ ok, ServerName } =
		application:get_env (server_name),

	{ ok, DocRoot } =
		application:get_env (document_root),

	io:format (
		"Starting Mochiweb Server (~s) on ~s:~p, root: '~s'~n", [
			ServerName,
			BindAddress,
			Port,
			DocRoot ]),

	Options = [
		{ name, ServerName },
		{ ip, BindAddress },
		{ port, Port },
		{ loop, fun ?MODULE:loop/1 }
	],

	mochiweb_http:start (Options),

	{ ok, { { one_for_one, 5, 10 }, [] } }.

loop (Req) ->

	{ ok, DocRoot } =
		application:get_env (document_root),

	RequestBridge =
		simple_bridge:make_request (
			mochiweb_request_bridge,
			{ Req, DocRoot }),

	ResponseBridge =
		simple_bridge:make_response (
			mochiweb_response_bridge,
			{ Req, DocRoot }),

	nitrogen:init_request (
		RequestBridge,
		ResponseBridge),

	nitrogen:run ().
