-module (notes_layout_login).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_data.hrl").
-include ("notes_global.hrl").

-compile (export_all).

layout () ->

	#template {
		file = "templates/login.html" }.

accounts () ->

	#link {
		class = button,
		text = "Google",
		delegate = ?MODULE,
		postback = { login, easy, "https://www.google.com/accounts/o8/id" }
	}.

openid () ->

	FormId = wf:temp_id (),

	#span {
		id = FormId,
		class = login_form,
		body = [

			#textbox {
				id = openid_url },

			" ",

			#button {
				class = ok_button,
				text = "Ok",
				delegate = ?MODULE,
				postback = { login, form, FormId } }
		]
	}.

login (OpenIdUrl) ->

	SessionId =
		wf:session_id (),

	{ ok, AuthReq } =
		notes_openid:prepare (
			SessionId,
			OpenIdUrl,
			true),

	{ ok, BaseUrl } =
		notes_config:get (base_url),

	ReturnTo = BaseUrl,
	Realm = BaseUrl,

	AuthUrl =
		openid:authentication_url (
			AuthReq,
			ReturnTo,
			Realm),

	wf:redirect (AuthUrl).

event ({ login, easy, OpenIdUrl }) ->

	login (OpenIdUrl);

event ({ login, form, FormId }) ->

	OpenIdUrl =
		wf:q (FormId ++ ".openid_url"),

	login (OpenIdUrl).
