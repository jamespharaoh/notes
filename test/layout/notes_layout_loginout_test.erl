-module (notes_layout_loginout_test).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_data.hrl").
-include ("notes_global.hrl").
-include ("notes_test.hrl").

-compile (export_all).

-define (MOCK_MODULES, [
	wf ]).

-define (TARGET,
	notes_layout_loginout).

layout_with_session_test () ->

	?EXPECT,

		?expect (wf, user,
			[],
			{ return, "user id" }),

	?REPLAY,

		?assertEqual (

			#button {
				id = log_out_button,
				text = "Log out",
				delegate = ?TARGET,
				postback = logout },

			?TARGET:layout ()),

	?VERIFY.

layout_without_session_test () ->

	?EXPECT,

		?expect (wf, user,
			[],
			{ return, undefined }),

	?REPLAY,

		?assertEqual (

			#link {
				text = "Log in",
				url = "/" },

			?TARGET:layout ()),

	?VERIFY.

event_logout_test () ->

	?EXPECT,

		?expect (wf, clear_user,
			[],
			{ return, ok }),

		?expect (wf, redirect,
			[ "/" ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:event (logout)),

	?VERIFY.
