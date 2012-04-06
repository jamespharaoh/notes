-module (notes_wf).

-export ([
	session_id/0 ]).

session_id () ->

	case wf:session (session_id) of

		undefined ->

			SessionId = notes_random:random_id (),

			wf:session (session_id, SessionId),

			SessionId;

		SessionId ->

			SessionId
	end.
