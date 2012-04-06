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

	[	#panel {
			id = "login_form",
			body = [

				#h1 { text = "Notes - Please log in" },

				#textbox {
					id = openid_url,
					text = "https://www.google.com/accounts/o8/id" },

				#button {
					id = ok_button,
					text = "Ok",
					postback = login }

			] }
	].

layout_authenticated () ->

	WorkspaceNameId = wf:temp_id (),

	{ ok, Workspaces } =
		user_data:get_workspaces (wf:user ()),

	[	#h1 { text = "Notes - Main menu" },

		#hr {},

		#h2 { text = "Create new workspace" },

		#p { body = [

			#label { text = "Name" },

			#textbox { id = WorkspaceNameId }
		] },

		#p { body = [

			#button {
				text = "Create workspace",
				postback = { create_workspace, WorkspaceNameId } }
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

event ({ create_workspace, WorkspaceNameId }) ->

	WorkspaceName = wf:q (WorkspaceNameId),

	{ ok, Workspace } =
		user_data:create_workspace (
			wf:user (),
			WorkspaceName),

	ok =
		workspace_data:set_owner (
			Workspace#user_workspace.workspace_id,
			wf:user ()),

	wf:redirect ([
		"workspace/",
		Workspace#user_workspace.workspace_id ]);

event (login) ->

	OpenIdUrl =
		wf:q (openid_url),

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
