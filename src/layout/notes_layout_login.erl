-module (notes_layout_login).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("data.hrl").

-compile (export_all).

layout () ->

	FormId = wf:temp_id (),

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
	].

event ({ login, FormId }) ->

	OpenIdUrl =
		wf:q (FormId ++ ".openid_url"),

	SessionId =
		notes_wf:session_id (),

	{ ok, AuthReq } =
		gen_server:call (
			openid,
			{ prepare, SessionId, OpenIdUrl, true }),

	{ ok, BaseUrl } =
		application:get_env (base_url),

	ReturnTo = BaseUrl,
	Realm = BaseUrl,

	AuthUrl =
		openid:authentication_url (
			AuthReq,
			ReturnTo,
			Realm),

	wf:redirect (AuthUrl).
