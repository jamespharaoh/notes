-module (index).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("data.hrl").

-compile (export_all).

main () ->

	case wf:q ("openid.ns") of

		undefined ->
			#template { file = "./templates/page.html" };

		_ ->
			do_login ()

	end.

body_class () ->

	case wf:user () of

		undefined ->
			"not_logged_in";

		_ ->
			"logged_in"

	end.

do_login () ->

	{ ok, BaseUrl } =
		application:get_env (base_url),

	SessionId = session_id (),
	ReturnTo = BaseUrl,

	Params = wf:params (),

	{ ok, Identity } =
		gen_server:call (
			openid,
			{ verify, SessionId, ReturnTo, Params }),

	wf:user (Identity),

	wf:redirect ("/").

title () ->
	"Notes".

session_id () ->

	case wf:session (session_id) of

		undefined ->

			SessionId = random:random_id (),

			wf:session (session_id, SessionId),

			SessionId;

		SessionId ->

			SessionId
	end.

layout () ->

	case wf:user () of

		undefined ->
			layout_not_authenticated ();

		_ ->
			layout_authenticated ()

	end.

layout_not_authenticated () ->

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
					postback = { login, FormId } }

			] }
	].

layout_authenticated () ->

	FormId = wf:temp_id (),

	{ ok, Workspaces } =
		user_data:get_workspaces (wf:user ()),

	[	#h1 { text = "Notes - Main menu" },

		#hr {},

		#h2 { text = "Create new workspace" },

		#panel {
			id = FormId,
			class = create_workspace_form,
			body = [

				#p { body = [

					#label {
						text = "Name" },

					#textbox {
						id = workspace_name }
				] },

				#p { body = [

					#button {
						id = create_workspace_button,
						text = "Create workspace",
						postback = { create_workspace, FormId } }
				] }

			] },

		#hr {},

		#h2 { text = "Your workspaces" },

		lists:map (

			fun (Workspace) ->

				#p { body = [

					#link {
						text = Workspace#user_workspace.name,
						url = [
							"workspace/",
							Workspace#user_workspace.workspace_id ] }
				] }

				end,

			Workspaces)
	].

event ({ create_workspace, FormId }) ->

	WorkspaceName =
		wf:q (FormId ++ ".workspace_name"),

	{ ok, Workspace } =
		user_data:create_workspace (
			wf:user (),
			WorkspaceName),

	ok =
		workspace_data:create (
			Workspace#user_workspace.workspace_id,
			wf:user (),
			WorkspaceName),

	wf:redirect ([
		"workspace/",
		Workspace#user_workspace.workspace_id ]);

event ({ login, FormId }) ->

	OpenIdUrl =
		wf:q (FormId ++ ".openid_url"),

	SessionId = session_id (),

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

	wf:redirect (AuthUrl);

event (Event) ->

	common:event (Event).
