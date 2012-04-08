% Filename: src/layout/notes_layout_login.erl
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
