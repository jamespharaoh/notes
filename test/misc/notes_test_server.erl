-module (notes_test_server).

-behaviour (gen_server).

-export ([

	% public api

	start_link/2,
	stop/1,

	% callbacks

	init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3 ]).

% public api

start_link (Name, Target) ->

	gen_server:start_link (
		Name,
		?MODULE,
		[ Target ],
		[]).

stop (Pid) ->

	gen_server:call (
		Pid,
		stop).

% callbacks

init ([ Target ]) ->

	{ ok, Target }.

handle_call (stop, _From, Target) ->

	{ stop, normal, ok, Target };

handle_call (Request, From, Target) ->

	case Target:handle_call (Request, From) of

		ok ->
			{ reply, ok, Target }

	end.

handle_cast (Message, Target) ->

	Target:handle_cast (Message).

handle_info (Info, Target) ->

	Target:handle_info (Info).

terminate (_Reason, _Target) ->

	ok.

code_change (_OldVersion, Target, _Extra) ->

	{ ok, Target }.
