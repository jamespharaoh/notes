% Filename: test/layout/notes_layout_loginout_test.erl
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

-module (notes_layout_loginout_test).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_data.hrl").
-include ("notes_global.hrl").
-include ("notes_test.hrl").

-compile (export_all).

-define (MOCK_MODULES, [
	wf ]).

-define (TARGET,
	notes_layout_loginout).

layout_with_session_test () ->

	?EXPECT,

		?expect (wf, user,
			[],
			{ return, "user id" }),

	?REPLAY,

		?assertEqual (

			#button {
				id = log_out_button,
				text = "Log out",
				delegate = ?TARGET,
				postback = logout },

			?TARGET:layout ()),

	?VERIFY.

layout_without_session_test () ->

	?EXPECT,

		?expect (wf, user,
			[],
			{ return, undefined }),

	?REPLAY,

		?assertEqual (

			#link {
				text = "Log in",
				url = "/" },

			?TARGET:layout ()),

	?VERIFY.

event_logout_test () ->

	?EXPECT,

		?expect (wf, clear_user,
			[],
			{ return, ok }),

		?expect (wf, redirect,
			[ "/" ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:event (logout)),

	?VERIFY.
