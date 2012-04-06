-module (notes_layout_workspace_list).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("data.hrl").

-compile (export_all).

layout () ->

	{ ok, Workspaces } =
		notes_data_user:get_workspaces (wf:user ()),

	[	#h2 { text = "Your workspaces" },

		lists:map (

			fun (Workspace) ->

				#p { body = [

					#link {
						text = Workspace#user_workspace.name,
						url = [
							"workspace/",
							Workspace#user_workspace.workspace_id ] }
				] }

				end,

			Workspaces)
	].
