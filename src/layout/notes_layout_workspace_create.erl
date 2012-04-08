% Filename: src/layout/notes_layout_workspace_create.erl
%
% Copyright 2012 James Pharaoh <james@phsys.co.uk>
%
%    Licensed under the Apache License, Version 2.0 (the "License");
%    you may not use this file except in compliance with the License.
%    You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%    Unless required by applicable law or agreed to in writing, software
%    distributed under the License is distributed on an "AS IS" BASIS,
%    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%    See the License for the specific language governing permissions and
%    limitations under the License

-module (notes_layout_workspace_create).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_data.hrl").

-compile (export_all).

layout () ->

	FormId = wf:temp_id (),

	#section { body = [

		#html5_header { body = [
			#h2 { text = "Create new workspace" }
		] },

		#panel {
			id = FormId,
			class = create_workspace_form,
			body = [

				#p { body = [

					#label {
						text = "Name" },

					" ",

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
			]
		}
	] }.

event ({ create_workspace, FormId }) ->

	WorkspaceName =
		wf:q (FormId ++ ".workspace_name"),

	UserId = wf:user (),

	{ ok, Workspace } =
		notes_data_user:create_workspace (
			UserId,
			WorkspaceName),

	ok =
		notes_data_workspace:create (
			Workspace#user_workspace.workspace_id,
			UserId,
			WorkspaceName),

	wf:redirect ([
		"workspace/",
		Workspace#user_workspace.workspace_id ]).
