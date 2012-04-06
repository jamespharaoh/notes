-module (common).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("data.hrl").

-compile (export_all).

loginout () ->

	case wf:user () of

		undefined ->
			#p { body =
				#link {
					text = "Log in",
					url = "/" }
			};

		_ ->
			#p { body =
				#button {
					id = log_out_button,
					text = "Log out",
					postback = logout }
			}

		end.

event (logout) ->

	wf:clear_user (),

	wf:redirect ("/").
