% Filename: test/path/notes_path_test_reset_test.erl
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
	notes_delegate_timer,
	notes_store ]).

-define (TARGET,
	notes_path_test_reset).

main_test () ->

	Names = [
		{ notes_data_user_server, "user id" },
		{ notes_data_workspace_server, "workspace id" },
		something_else ],

	?EXPECT,

		?expect (notes_global, registered_names,
			[],
			{ return, Names }),

		?expect (notes_data_user, stop,
			[ "user id" ],
			{ return, ok }),

		?expect (notes_data_workspace, stop,
			[ "workspace id" ],
			{ return, ok }),

		?expect (notes_delegate_timer, sleep,
			[ 1 ],
			{ return, ok }),

		?expect (notes_store, delete_all,
			[ ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			"DATABASE RESET",
			?TARGET:main ()),

	?VERIFY.
