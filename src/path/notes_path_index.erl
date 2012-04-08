-module (notes_path_index).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_data.hrl").
-include ("notes_global.hrl").

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
		notes_config:get (base_url),

	SessionId = wf:session_id (),
	ReturnTo = BaseUrl,

	Params = wf:params (),

	{ ok, Identity } =
		notes_openid:verify (
			SessionId,
			ReturnTo,
			Params),

	wf:user (Identity),

	wf:redirect ("/").

title () ->
	"Notes".

layout () ->

	case wf:user () of

		undefined ->
			layout_not_authenticated ();

		_ ->
			layout_authenticated ()

	end.

layout_not_authenticated () ->

	notes_layout_login:layout ().

layout_authenticated () ->

	[	#h1 { text = "Home" },

		notes_layout_workspace_create:layout (),

		notes_layout_workspace_list:layout ()
	].
