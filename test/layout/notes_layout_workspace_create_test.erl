% Filename: test/layout/notes_layout_workspace_create_test.erl
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

			#section { body = [

				#html5_header { body = [
					#h2 { text = "Create new workspace" }
				] },

				#panel {
					id = "form id",
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
								delegate = ?TARGET,
								postback = { create_workspace, "form id" } }
						] }
					]
				}
			] },

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
