-module (notes_layout_login_test).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_data.hrl").
-include ("notes_global.hrl").
-include ("notes_test.hrl").

-compile (export_all).

-define (MOCK_MODULES, [
	notes_config,
	notes_openid,
	openid,
	wf ]).

-define (TARGET,
	notes_layout_login).

layout_test () ->

	?EXPECT,

	?REPLAY,

		?assertEqual (

			#template {
				file = "templates/login.html" },

			?TARGET:layout ()),

	?VERIFY.

accounts_test () ->

	?EXPECT,

	?REPLAY,

		?assertEqual (

			#link {
				class = button,
				text = "Google",
				delegate = ?TARGET,
				postback = { login, easy, "https://www.google.com/accounts/o8/id" }
			},

			?TARGET:accounts ()),

	?VERIFY.

openid_test () ->

	?EXPECT,

		?expect (wf, temp_id,
			[ ],
			{ return, "form id" }),

	?REPLAY,

		?assertEqual (

			#span {
				id = "form id",
				class = login_form,
				body = [

					#textbox {
						id = openid_url },

					" ",

					#button {
						class = ok_button,
						text = "Ok",
						delegate = ?TARGET,
						postback = { login, form, "form id" } }
				]
			},

			?TARGET:openid ()),

	?VERIFY.

event_login_easy_test () ->

	?EXPECT,

		?expect (wf, session_id,
			[ ],
			{ return, <<"session id">> }),

		?expect (notes_openid, prepare,
			[ <<"session id">>, "open id url", true ],
			{ return, { ok, "auth req" } }),

		?expect (notes_config, get,
			[ base_url ],
			{ return, { ok, "base url" } }),

		?expect (openid, authentication_url,
			[ "auth req", "base url", "base url" ],
			{ return, "auth url" }),

		?expect (wf, redirect,
			[ "auth url" ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (

			ok,

			?TARGET:event ({ login, easy, "open id url" })),

	?VERIFY.

event_login_form_test () ->

	?EXPECT,

		?expect (wf, q,
			[ "form_id.openid_url" ],
			{ return, "open id url" }),

		?expect (wf, session_id,
			[ ],
			{ return, <<"session id">> }),

		?expect (notes_openid, prepare,
			[ <<"session id">>, "open id url", true ],
			{ return, { ok, "auth req" } }),

		?expect (notes_config, get,
			[ base_url ],
			{ return, { ok, "base url" } }),

		?expect (openid, authentication_url,
			[ "auth req", "base url", "base url" ],
			{ return, "auth url" }),

		?expect (wf, redirect,
			[ "auth url" ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (

			ok,

			?TARGET:event ({ login, form, "form_id" })),

	?VERIFY.
