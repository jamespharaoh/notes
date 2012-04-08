% Filename: src/path/notes_path_test_reset.erl
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

	?timer:sleep (1),

	notes_store:delete_all (),

	"DATABASE RESET".
