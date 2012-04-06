-module (notes_data_user_server_test).

-include_lib ("eunit/include/eunit.hrl").

-include ("data.hrl").

% macros

-define (EXPECT,
	Em = em:new (),
	em:nothing (Em, notes_random),
	em:nothing (Em, notes_store)).

-define (REPLAY,
	em:replay (Em)).

-define (VERIFY,
	em:verify (Em)).

-define (TARGET,
	notes_data_user_server).

% fixtures

state_fixture () ->

	#user_state {
		user_id = "user_0",
		workspaces = workspaces_fixture () }.

workspaces_fixture () ->

	[ workspace_0_fixture () ].

workspace_0_fixture () ->

	#user_workspace {
		workspace_id = "workspace_0",
		name = "Workspace zero" }.

% init tests

init_test () ->

	?EXPECT,

		em:strict (Em, notes_store, read,

			[ notes_test:match_str ([
				"users/",
				notes_misc:sha1 ("user_0"),
				"/workspaces" ]) ],

			{ return,
				{ ok, workspaces_fixture () } }),

	?REPLAY,

		?assertEqual (

			{ ok, state_fixture () },

			?TARGET:init (
				[ "user_0" ])),

	?VERIFY.

% handle_call stop tests

handle_call_stop_test () ->

	State = state_fixture (),

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ stop, normal, ok, State },

			?TARGET:handle_call (
				stop,
				from,
				State)),

	?VERIFY.

handle_call_get_workspaces_test () ->

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ reply,
				{ ok, workspaces_fixture () },
				state_fixture () },

			?TARGET:handle_call (
				get_workspaces,
				from,
				state_fixture ())),

	?VERIFY.

handle_call_create_workspace_test () ->

	State =
		state_fixture (),

	NewWorkspace =
		#user_workspace {
			workspace_id = "workspace_z",
			name = "Workspace zed" },

	NewWorkspaces =
		[ NewWorkspace | workspaces_fixture () ],

	NewState =
		State #user_state {
			workspaces = NewWorkspaces },

	?EXPECT,

		em:strict (Em, notes_random, random_id, [ ],
			{ return, "workspace_z" }),

		em:strict (Em, notes_store, write,

			[	notes_test:match_str ([
					"users/",
					notes_misc:sha1 ("user_0"),
					"/workspaces" ]),
				NewWorkspaces ],

			{ return, ok }),

	?REPLAY,

		?assertEqual (

			{ reply,
				{ ok, NewWorkspace },
				NewState },

			?TARGET:handle_call (
				{ create_workspace, "Workspace zed" },
				from,
				State)),

	?VERIFY.

handle_call_test () ->

	State = state_fixture (),

	Message = some_nonsense,

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ stop,
				{ unknown_call, Message },
				State },

			?TARGET:handle_call (
				Message,
				from,
				State)),

	?VERIFY.

handle_cast_test () ->

	State = state_fixture (),

	Message = some_nonsense,

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ stop,
				{ unknown_cast, Message },
				State },

			?TARGET:handle_cast (
				Message,
				State)),

	?VERIFY.

handle_info_test () ->

	State = state_fixture (),

	Message = some_nonsense,

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ stop,
				{ unknown_info, Message },
				State },

			?TARGET:handle_info (
				Message,
				State)),

	?VERIFY.

terminate_test () ->

	State = state_fixture (),

	Reason = some_reason,

	?EXPECT,

	?REPLAY,

		?assertEqual (

			ok,

			?TARGET:terminate (
				Reason,
				State)),

	?VERIFY.

code_change_test () ->

	State = state_fixture (),

	OldVersion = some_version,

	Extra = something_extra,

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ ok, State },

			?TARGET:code_change (
				OldVersion,
				State,
				Extra)),

	?VERIFY.
