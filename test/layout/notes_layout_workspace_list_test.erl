-module (notes_layout_workspace_list_test).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_test.hrl").
-include ("notes_data.hrl").

-compile (export_all).

-define (MOCK_MODULES, [
	notes_data_user,
	wf ]).

-define (TARGET,
	notes_layout_workspace_list).

layout_test () ->

	Workspace =
		#user_workspace {
			workspace_id = "workspace id",
			name = "workspace name" },

	Workspaces =
		[ Workspace ],

	?EXPECT,

		em:strict (Em, wf, user,
			[],
			{ return, "user id" }),

		em:strict (Em, notes_data_user, get_workspaces,
			[ "user id" ],
			{ return, { ok, Workspaces }}),

	?REPLAY,

		?assertEqual (

			[	#h2 { text = "Your workspaces" },

				[	#p { body = [

						#link {
							text = "workspace name",
							url = [ "workspace/", "workspace id" ] }
					] }
				]
			],

			?TARGET:layout ()),

	?VERIFY.
