-module (user_data).

-export ([

	% public api

	get_workspaces/1,
	create_workspace/2,
	stop/1 ]).

-include ("data.hrl").

% public api

get_workspaces (UserId) ->

	gen_server:call (
		get_pid (UserId),
		get_workspaces).

create_workspace (UserId, Name) ->

	gen_server:call (
		get_pid (UserId),
		{ create_workspace, Name }).

stop (UserId) ->

	gen_server:call (
		get_pid (UserId),
		stop).

% internal api

get_pid (UserId) ->

	Name = { user, UserId },

	case gen_server:start_link (
			{ global, Name },
			user_server,
			[ UserId ],
			[]) of

		{ error, { already_started, Pid }} ->
			Pid;

		{ ok, Pid } ->
			Pid

	end.
