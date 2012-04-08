% Filename: test/misc/notes_app_test.erl
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

-module (notes_app_test).

-include_lib ("eunit/include/eunit.hrl").

-include ("notes_data.hrl").
-include ("notes_global.hrl").
-include ("notes_test.hrl").

% macros

-define (MOCK_MODULES, [
	notes_supervisor ]).

-define (TARGET,
	notes_data_workspace_server).

% fixtures

start_test () ->

	StartType = start_type,
	StartArgs = start_args,

	?EXPECT,

		?expect (notes_supervisor, start_link,
			[ ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			notes_app:start (
				StartType,
				StartArgs)),

	?VERIFY.

stop_test () ->

	State = state,

	?EXPECT,

	?REPLAY,

		?assertEqual (
			ok,
			notes_app:stop (State)),

	?VERIFY.
