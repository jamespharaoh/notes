-module (notes_data_user_test).

-include ("notes_global.hrl").
-include ("notes_test.hrl").

% macros

-define (MOCK_MODULES,
	[ notes_server ]).

-define (TARGET,
	notes_data_user).

-define (SERVER,
	notes_data_user_server).

% init tests

get_workspaces_test () ->
	?NOTES_SERVER_TEST (get_workspaces, []).

create_workspace_test () ->
	?NOTES_SERVER_TEST (create_workspace, [ "Workspace name" ]).

stop_test () ->
	?NOTES_SERVER_TEST (stop, []).
