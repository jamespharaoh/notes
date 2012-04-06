-module (notes_supervisor).

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
		[ ]).

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

	Options = [
		{ name, ServerName },
		{ ip, BindAddress },
		{ port, Port },
		{ loop, fun ?MODULE:loop/1 }
	],

	{ ok, _MochiPid } = mochiweb_http:start (Options),

	% start openid

	ok = application:start (crypto),
	ok = application:start (ibrowse),
	ok = application:start (openid),
	ok = application:start (public_key),
	ok = application:start (ssl),

	% start nitrogen

	ok = application:start (sasl),
	ok = application:start (nitrogen_core),

	% and return

	MaxRestart = 5,
	MaxTime = 100,
	RestartPolicy = { one_for_one, MaxRestart, MaxTime },

	ChildSpecs = [

		%{	data,
		%	{ data, start_link, [] },
		%	permanent,
		%	10000,
		%	worker,
		%	[ data ] },

		{	openid,
			{ openid_srv, start_link, [ openid ] },
			permanent,
			10000,
			worker,
			[ openid ] }
	],

	SupervisorOptions = { RestartPolicy, ChildSpecs },

	{ ok, SupervisorOptions }.

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
