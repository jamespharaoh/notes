-module (notes_layout_workspace_create).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_data.hrl").

-compile (export_all).

layout () ->

	FormId = wf:temp_id (),

	[	#h2 { text = "Create new workspace" },

		#panel {
			id = FormId,
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
						delegate = ?MODULE,
						postback = { create_workspace, FormId } }
				] }

			] }
	].

event ({ create_workspace, FormId }) ->

	WorkspaceName =
		wf:q (FormId ++ ".workspace_name"),

	{ ok, Workspace } =
		notes_data_user:create_workspace (
			wf:user (),
			WorkspaceName),

	ok =
		notes_data_workspace:create (
			Workspace#user_workspace.workspace_id,
			wf:user (),
			WorkspaceName),

	wf:redirect ([
		"workspace/",
		Workspace#user_workspace.workspace_id ]).
