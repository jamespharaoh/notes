-module (notes_layout_workspace_list_test).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_data.hrl").
-include ("notes_global.hrl").
-include ("notes_test.hrl").

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

		?expect (wf, user,
			[],
			{ return, "user id" }),

		?expect (notes_data_user, get_workspaces,
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
