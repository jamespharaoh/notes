-module (notes_layout_workspace_create_test).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_data.hrl").
-include ("notes_global.hrl").
-include ("notes_test.hrl").

-compile (export_all).

-define (MOCK_MODULES, [
	notes_data_user,
	notes_data_workspace,
	wf ]).

-define (TARGET,
	notes_layout_workspace_create).

layout_test () ->

	?EXPECT,

		?expect (wf, temp_id,
			[],
			{ return, "form id" }),

	?REPLAY,

		?assertEqual (

			[	#h2 { text = "Create new workspace" },

				#panel {
					id = "form id",
					class = create_workspace_form,
					body = [

						#p { body = [

							#label {
								text = "Name" },

							#textbox {
								id = workspace_name }
						] },

						#p { body = [

							#button {
								id = create_workspace_button,
								text = "Create workspace",
								delegate = ?TARGET,
								postback = { create_workspace, "form id" } }
						] }

					] }
			],

			?TARGET:layout ()),

	?VERIFY.

event_create_workspace_test () ->

	Workspace =
		#user_workspace {
			workspace_id = "workspace id" },

	?EXPECT,

		?expect (wf, q,
			[ "form id.workspace_name" ],
			{ return, "workspace name" }),

		?expect (wf, user,
			[ ],
			{ return, "user id" }),

		?expect (notes_data_user, create_workspace,
			[ "user id", "workspace name" ],
			{ return, { ok, Workspace } }),

		?expect (notes_data_workspace, create,
			[ "workspace id", "user id", "workspace name" ],
			{ return, ok }),

		?expect (wf, redirect,
			[ notes_test:match_str ("workspace/workspace id") ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:event ({ create_workspace, "form id" })),

	?VERIFY.
