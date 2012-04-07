-module (notes_path_test_reset_test).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_test.hrl").
-include ("notes_data.hrl").
-include ("notes_global.hrl").

-compile (export_all).

-define (MOCK_MODULES, [
	notes_global,
	notes_data_user,
	notes_data_workspace,
	notes_store,
	notes_timer ]).

-define (TARGET,
	notes_path_test_reset).

main_test () ->

	Names = [
		{ notes_data_user_server, "user id" },
		{ notes_data_workspace_server, "workspace id" },
		something_else ],

	?EXPECT,

		em:strict (Em, notes_global, registered_names,
			[],
			{ return, Names }),

		em:strict (Em, notes_data_user, stop,
			[ "user id" ],
			{ return, ok }),

		em:strict (Em, notes_data_workspace, stop,
			[ "workspace id" ],
			{ return, ok }),

		em:strict (Em, notes_timer, sleep,
			[ 1 ],
			{ return, ok }),

		em:strict (Em, notes_store, delete_all,
			[ ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			"DATABASE RESET",
			?TARGET:main ()),

	?VERIFY.
