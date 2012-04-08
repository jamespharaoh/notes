% Filename: test/misc/notes_server_test.erl
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

-module (notes_server_test).

-include ("notes_test.hrl").

% macros

-define (MOCK_MODULES, [
	notes_test_server_stub,
	notes_test_server_target ]).

-define (TARGET, notes_server).

-define (SERVER, notes_test_server).

-define (STUB, notes_test_server_stub).

call_new_process_test () ->

	Message = "the message",

	?EXPECT,

		?expect (?STUB, handle_call,

			[	Message,
				em:any (),
				em:any () ],

			{	function,
				fun ([ _Message, _From, State ]) ->
					{ reply, ok, State }
					end }),

	?REPLAY,

		?assertEqual (

			ok,

			?TARGET:call (
				?SERVER,
				?STUB,
				Message)),

	?VERIFY,

	gen_server:call (
		{ global, { ?SERVER, ?STUB } },
		stop).

call_existing_process_test () ->

	Message = "the message",

	notes_test_server:start_link (
		{ global, { ?SERVER, ?STUB } },
		?STUB),

	?EXPECT,

		?expect (?STUB, handle_call,

			[	Message,
				em:any (),
				em:any () ],

			{	function,
				fun ([ _Message, _From, State ]) ->
					{ reply, ok, State }
					end }),

	?REPLAY,

		?assertEqual (

			ok,

			?TARGET:call (
				?SERVER,
				?STUB,
				Message)),

	?VERIFY,

	gen_server:call (
		{ global, { ?SERVER, ?STUB } },
		stop).
