% Filename: test/misc/notes_openid_test.erl
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

-module (notes_openid_test).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_test.hrl").
-include ("notes_data.hrl").

-compile (export_all).

-define (MOCK_MODULES, [
	notes_test_server_target ]).

-define (TARGET,
	notes_openid).

prepare_test () ->

	{ ok, Server } =
		notes_test_server:start_link (
			{ local, openid },
			notes_test_server_target),

	?EXPECT,

		?expect (notes_test_server_target, handle_call,

			[	{	prepare,
					"session id",
					"open id url",
					true },
				em:any (),
				em:any () ],

			{ function,
				fun ([ _Message, _From, State ]) ->
					{ reply, ok, State }
					end }),

	?REPLAY,

		?assertEqual (

			ok,

			?TARGET:prepare (
				"session id",
				"open id url",
				true)),

	?VERIFY,

	ok = notes_test_server:stop (Server).

verify_test () ->

	Params = [
		{ "param key", "param value" }
	],

	{ ok, Server } =
		notes_test_server:start_link (
			{ local, openid },
			notes_test_server_target),

	?EXPECT,

		?expect (notes_test_server_target, handle_call,

			[	{	verify,
					"session id",
					"return to",
					Params },
				em:any (),
				em:any () ],

			{ function,
				fun ([ _Message, _From, State ]) ->
					{ reply, ok, State }
					end }),

	?REPLAY,

		?assertEqual (

			ok,

			?TARGET:verify (
				"session id",
				"return to",
				Params)),

	?VERIFY,

	ok = notes_test_server:stop (Server).
