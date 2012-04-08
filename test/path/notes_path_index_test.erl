% Filename: test/path/notes_path_index_test.erl
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

-module (notes_path_index_test).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_test.hrl").
-include ("notes_data.hrl").

-compile (export_all).

-define (MOCK_MODULES, [
	notes_config,
	notes_layout_login,
	notes_layout_workspace_create,
	notes_layout_workspace_list,
	notes_openid,
	wf ]).

-define (TARGET,
	notes_path_index).

main_normal_test () ->

	?EXPECT,

		?expect (wf, q,
			[ "openid.ns" ],
			{ return, undefined }),

	?REPLAY,

		?assertEqual (
			#template { file = "./templates/page.html" },
			?TARGET:main ()),

	?VERIFY.

main_openid_test () ->

	Params = [
		{ "param key", "param value" }
	],

	?EXPECT,

		?expect (wf, q,
			[ "openid.ns" ],
			{ return, "open id namespace" }),

		?expect (notes_config, get,
			[ base_url ],
			{ return, { ok, "base url" } }),

		?expect (wf, session_id,
			[ ],
			{ return, <<"session id">> }),

		?expect (wf, params,
			[ ],
			{ return, Params }),

		?expect (notes_openid, verify,
			[ <<"session id">>, "base url", Params ],
			{ return, { ok, "identity" } }),

		?expect (wf, user,
			[ "identity" ],
			{ return, ok }),

		?expect (wf, redirect,
			[ "/" ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:main ()),

	?VERIFY.

body_class_not_logged_in_test () ->

	?EXPECT,

		?expect (wf, user,
			[ ],
			{ return, undefined }),

	?REPLAY,

		?assertEqual (
			"not_logged_in",
			?TARGET:body_class ()),

	?VERIFY.

body_class_logged_in_test () ->

	?EXPECT,

		?expect (wf, user,
			[ ],
			{ return, "user id" }),

	?REPLAY,

		?assertEqual (
			"logged_in",
			?TARGET:body_class ()),

	?VERIFY.

title_test () ->

	?assertEqual (
		"Notes",
		?TARGET:title ()).

layout_not_logged_in_test () ->

	?EXPECT,

		?expect (wf, user,
			[ ],
			{ return, undefined }),

		?expect (notes_layout_login, layout,
			[ ],
			{ return, "login layout" }),

	?REPLAY,

		?assertEqual (
			"login layout",
			?TARGET:layout ()),

	?VERIFY.

layout_logged_in_test () ->

	?EXPECT,

		?expect (wf, user,
			[ ],
			{ return, "user id" }),

		?expect (notes_layout_workspace_create, layout,
			[ ],
			{ return, "workspace create layout" }),

		?expect (notes_layout_workspace_list, layout,
			[ ],
			{ return, "workspace list layout" }),

	?REPLAY,

		?assertEqual (

			[	#h1 { text = "Home" },

				"workspace create layout",

				"workspace list layout"
			],

			?TARGET:layout ()),

	?VERIFY.
