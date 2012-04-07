-module (notes_path_test_reset).

-include ("notes_data.hrl").
-include ("notes_global.hrl").

-compile (export_all).

main () ->

	StopFunc = fun

		({ notes_data_user_server, UserId }, Count) ->
			notes_data_user:stop (UserId),
			Count + 1;

		({ notes_data_workspace_server, WorkspaceId }, Count) ->
			notes_data_workspace:stop (WorkspaceId),
			Count + 1;

		(_, Count) ->
			Count

		end,

	_NumStopped = lists:foldl (
		StopFunc,
		0,
		notes_global:registered_names ()),

	notes_delegate_timer:sleep (1),

	notes_store:delete_all (),

	"DATABASE RESET".
