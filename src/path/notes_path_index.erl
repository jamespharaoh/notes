-module (notes_path_index).

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

	SessionId = notes_wf:session_id (),
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

layout () ->

	case wf:user () of

		undefined ->
			layout_not_authenticated ();

		_ ->
			layout_authenticated ()

	end.

layout_not_authenticated () ->

	[ notes_layout_login:layout () ].

layout_authenticated () ->

	[	#h1 { text = "Notes - Main menu" },

		#hr {},

		notes_layout_workspace_create:layout (),

		#hr {},

		notes_layout_workspace_list:layout ()
	].
