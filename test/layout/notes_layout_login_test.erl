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

	FormId = "form id",

	?EXPECT,

		?expect (wf, temp_id,
			[],
			{ return, FormId }),

	?REPLAY,

		?assertEqual (

			[	#panel {
					id = FormId,
					class = login_form,
					body = [

						#h1 { text = "Notes - Please log in" },

						#textbox {
							id = openid_url,
							text = "https://www.google.com/accounts/o8/id" },

						#button {
							class = ok_button,
							text = "Ok",
							delegate = notes_layout_login,
							postback = { login, FormId } }

					] }
			],

			?TARGET:layout ()),

	?VERIFY.

event_login_test () ->

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

			?TARGET:event ({ login, "form_id" })),

	?VERIFY.
