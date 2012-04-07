-module (notes_supervisor).

-behaviour (supervisor).

-export ([
	start_link/0,
	init/1,
	loop/1 ]).

-include ("notes_global.hrl").

% api functions

start_link () ->

	?supervisor:start_link (
		{ local, ?MODULE },
		?MODULE,
		[ ]).

% supervisor callbacks

init ([]) ->

	% mochiweb

	{ ok, BindAddress } =
		notes_config:get (bind_address),

	{ ok, Port } =
		notes_config:get (port),

	MochiOptions = [
		{ ip, BindAddress },
		{ port, Port },
		{ loop, fun ?MODULE:loop/1 }
	],

	% and return

	MaxRestart = 5,
	MaxTime = 100,
	RestartPolicy = { one_for_one, MaxRestart, MaxTime },

	ChildSpecs = [

		{	mochiweb,
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
	],

	SupervisorOptions = { RestartPolicy, ChildSpecs },

	{ ok, SupervisorOptions }.

loop (Req) ->

	{ ok, DocRoot } =
		notes_config:get (document_root),

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
