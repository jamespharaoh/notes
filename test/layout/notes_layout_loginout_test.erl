-module (notes_layout_loginout_test).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_test.hrl").
-include ("notes_data.hrl").

-compile (export_all).

-define (MOCK_MODULES, [
	wf ]).

-define (TARGET,
	notes_layout_loginout).

layout_with_session_test () ->

	?EXPECT,

		em:strict (Em, wf, user,
			[],
			{ return, "user id" }),

	?REPLAY,

		?assertEqual (

			#p { body =
				#button {
					id = log_out_button,
					text = "Log out",
					delegate = ?TARGET,
					postback = logout }
			},

			?TARGET:layout ()),

	?VERIFY.

layout_without_session_test () ->

	?EXPECT,

		em:strict (Em, wf, user,
			[],
			{ return, undefined }),

	?REPLAY,

		?assertEqual (

			#p { body =
				#link {
					text = "Log in",
					url = "/" }
			},

			?TARGET:layout ()),

	?VERIFY.

event_logout_test () ->

	?EXPECT,

		em:strict (Em, wf, clear_user,
			[],
			{ return, ok }),

		em:strict (Em, wf, redirect,
			[ "/" ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:event (logout)),

	?VERIFY.
