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

		em:strict (Em, wf, q,
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

		em:strict (Em, wf, q,
			[ "openid.ns" ],
			{ return, "open id namespace" }),

		em:strict (Em, notes_config, get,
			[ base_url ],
			{ return, { ok, "base url" } }),

		em:strict (Em, wf, session_id,
			[ ],
			{ return, <<"session id">> }),

		em:strict (Em, wf, params,
			[ ],
			{ return, Params }),

		em:strict (Em, notes_openid, verify,
			[ <<"session id">>, "base url", Params ],
			{ return, { ok, "identity" } }),

		em:strict (Em, wf, user,
			[ "identity" ],
			{ return, ok }),

		em:strict (Em, wf, redirect,
			[ "/" ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:main ()),

	?VERIFY.

body_class_not_logged_in_test () ->

	?EXPECT,

		em:strict (Em, wf, user,
			[ ],
			{ return, undefined }),

	?REPLAY,

		?assertEqual (
			"not_logged_in",
			?TARGET:body_class ()),

	?VERIFY.

body_class_logged_in_test () ->

	?EXPECT,

		em:strict (Em, wf, user,
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

		em:strict (Em, wf, user,
			[ ],
			{ return, undefined }),

		em:strict (Em, notes_layout_login, layout,
			[ ],
			{ return, "login layout" }),

	?REPLAY,

		?assertEqual (
			[ "login layout" ],
			?TARGET:layout ()),

	?VERIFY.

layout_logged_in_test () ->

	?EXPECT,

		em:strict (Em, wf, user,
			[ ],
			{ return, "user id" }),

		em:strict (Em, notes_layout_workspace_create, layout,
			[ ],
			{ return, "workspace create layout" }),

		em:strict (Em, notes_layout_workspace_list, layout,
			[ ],
			{ return, "workspace list layout" }),

	?REPLAY,

		?assertEqual (

			[	#h1 { text = "Notes - Main menu" },

				#hr {},

				"workspace create layout",

				#hr {},

				"workspace list layout"
			],

			?TARGET:layout ()),

	?VERIFY.
