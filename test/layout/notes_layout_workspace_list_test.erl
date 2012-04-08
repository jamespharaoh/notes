% Filename: test/layout/notes_layout_workspace_list_test.erl
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
