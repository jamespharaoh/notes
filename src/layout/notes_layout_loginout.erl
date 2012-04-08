-module (notes_layout_loginout).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_data.hrl").

-compile (export_all).

layout () ->

	case wf:user () of

		undefined ->

			#link {
				text = "Log in",
				url = "/" };

		_ ->

			#button {
				id = log_out_button,
				text = "Log out",
				delegate = ?MODULE,
				postback = logout }

		end.

event (logout) ->

	wf:clear_user (),

	wf:redirect ("/").
