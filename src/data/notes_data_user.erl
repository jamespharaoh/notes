-module (notes_data_user).

-export ([

	% public api

	get_workspaces/1,
	create_workspace/2,
	stop/1 ]).

-include ("notes_data.hrl").

-define (TARGET,
	notes_data_user_server).

-define (CALL (Message),
	notes_server:call (
		?TARGET,
		UserId,
		Message)).

% public api

get_workspaces (UserId) ->

	?CALL (get_workspaces).

create_workspace (UserId, Name) ->

	?CALL ({ create_workspace, Name }).

stop (UserId) ->

	?CALL (stop).
