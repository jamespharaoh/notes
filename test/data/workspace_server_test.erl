-module (workspace_server_test).

-include_lib ("eunit/include/eunit.hrl").

-include ("data.hrl").

% macros

-define (EXPECT,
	Em = em:new (),
	em:nothing (Em, data),
	em:nothing (Em, random)).

-define (REPLAY,
	em:replay (Em)).

-define (VERIFY,
	em:verify (Em)).

% match functions

match_str (String) ->

	fun (Arg) ->
		lists:flatten (Arg) == lists:flatten (String)
		end.

% fixtures

workspace_id () ->
	"workspace_0".

workspace_name () ->
	"Workspace 0".

workspace_fixture () ->
	#workspace {
		workspace_id = workspace_id (),
		name = workspace_name () }.

state_fixture () ->

	#workspace_state {
		workspace_id = workspace_id (),
		workspace = workspace_fixture (),
		notes = notes_fixture (),
		perms = perms_fixture () }.

perms_fixture () ->

	[	#workspace_perm {
			user_id = "read_user",
			roles = [ read ] },

		#workspace_perm {
			user_id = "write_user",
			roles = [ write ] },

		#workspace_perm {
			user_id = "owner_user",
			roles = [ owner ] }
	].

notes_fixture () ->

	[ note_0_fixture () ].

note_0_fixture () ->

	#workspace_note {
		note_id = "note_0",
		text = "This is note 0" }.

% init test

init_test () ->

	?EXPECT,

		em:strict (Em, data, read,
			[ match_str ("workspaces/workspace_0/workspace") ],
			{ return, { ok, [ workspace_fixture () ] } }),

		em:strict (Em, data, read,
			[ match_str ("workspaces/workspace_0/notes") ],
			{ return, { ok, notes_fixture () } }),

		em:strict (Em, data, read,
			[ match_str ("workspaces/workspace_0/perms") ],
			{ return, { ok, perms_fixture () } }),

	?REPLAY,

		?assertEqual (

			{ ok, state_fixture () },

			workspace_server:init (
				[ workspace_id () ])),

	?VERIFY.

init_new_test () ->

	NewState =
		#workspace_state {
			workspace_id = "workspace_0",
			workspace = undefined,
			perms = [],
			notes = [] },

	?EXPECT,

		em:strict (Em, data, read,
			[ match_str ("workspaces/workspace_0/workspace") ],
			{ return, { ok, [ ] } }),

		em:strict (Em, data, read,
			[ match_str ("workspaces/workspace_0/notes") ],
			{ return, { ok, [ ] } }),

		em:strict (Em, data, read,
			[ match_str ("workspaces/workspace_0/perms") ],
			{ return, { ok, [ ] } }),

	?REPLAY,

		?assertEqual (

			{ ok, NewState },

			workspace_server:init (
				[ workspace_id () ])),

	?VERIFY.

% handle_call create tests

handle_call_create_success_test () ->

	BeforeState =
		#workspace_state {
			workspace_id = "workspace_0" },

	NewWorkspace =
		#workspace {
			workspace_id = "workspace_0",
			name = "Workspace name" },

	NewPerms = [
		#workspace_perm {
			user_id = "some_user",
			roles = [ owner ] } ],

	AfterState =
		BeforeState#workspace_state {
			workspace = NewWorkspace,
			perms = NewPerms },

	?EXPECT,

		em:strict (Em, data, write,
			[	match_str ("workspaces/workspace_0/workspace"),
				[ NewWorkspace ] ],
			{ return, ok }),

		em:strict (Em, data, write,
			[	match_str ("workspaces/workspace_0/perms"),
				NewPerms ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (

			{ reply, ok, AfterState },

			workspace_server:handle_call (
				{ create, "some_user", "Workspace name" },
				from,
				BeforeState)),

	?VERIFY.

handle_call_create_already_exists_test () ->

	State = state_fixture (),

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ reply, already_exists, State },

			workspace_server:handle_call (
				{ create, "some_user", "Workspace name" },
				from,
				State)),

	?VERIFY.

% handle_call get_workspace tests

handle_call_get_workspace_permission_denied_test () ->

	State = state_fixture (),

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ reply, permission_denied, State },

			workspace_server:handle_call (
				{ get_workspace, "none_user" },
				from,
				State)),

	?VERIFY.

handle_call_get_workspace_success_test () ->

	State = state_fixture (),

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{	reply,
				{ ok, workspace_fixture () },
				State },

			workspace_server:handle_call (
				{ get_workspace, "read_user" },
				from,
				State)),

	?VERIFY.

% handle_call add_note tests

handle_call_add_note_permission_denied_test () ->

	State = state_fixture (),

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ reply, permission_denied, State },

			workspace_server:handle_call (
				{ add_note, "read_user", "Body" },
				from,
				State)),

	?VERIFY.

handle_call_add_note_success_test () ->

	BeforeState = state_fixture (),

	Note =
		#workspace_note {
			note_id = "note_id",
			text = "Blah" },

	NewNotes =
		[ Note | notes_fixture () ],

	AfterState =
		BeforeState#workspace_state {
			notes = NewNotes },

	?EXPECT,

		em:strict (Em, random, random_id, [ ],
			{ return, "note_id" }),

		em:strict (Em, data, write,
			[	match_str ("workspaces/workspace_0/notes"),
				NewNotes ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (

			{ reply, { ok, Note }, AfterState },

			workspace_server:handle_call (
				{ add_note, "write_user", "Blah" },
				from,
				BeforeState)),

	?VERIFY.

handle_call_get_notes_permission_denied_test () ->

	State = state_fixture (),

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ reply, permission_denied, State },

			workspace_server:handle_call (
				{ get_notes, "none_user" },
				from,
				State)),

	?VERIFY.

handle_call_get_notes_success_test () ->

	State = state_fixture (),
	Notes = notes_fixture (),

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ reply, { ok, Notes }, State },

			workspace_server:handle_call (
				{ get_notes, "read_user" },
				from,
				State)),

	?VERIFY.

handle_call_get_note_permission_denied_test () ->

	State = state_fixture (),

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ reply, permission_denied, State },

			workspace_server:handle_call (
				{ get_note, "none_user", "note_0" },
				from,
				State)),

	?VERIFY.

handle_call_get_note_permission_not_found_test () ->

	State = state_fixture (),

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ reply, not_found, State },

			workspace_server:handle_call (
				{ get_note, "read_user", "note_x" },
				from,
				State)),

	?VERIFY.

handle_call_get_note_success_test () ->

	State = state_fixture (),
	Note = note_0_fixture (),

	?EXPECT,

	?REPLAY,

	?assertEqual (

		{ reply, { ok, Note }, State },

		workspace_server:handle_call (
			{ get_note, "read_user", "note_0" },
			from,
			State)),

	?VERIFY.

handle_call_set_note_permission_denied_test () ->

	State = state_fixture (),

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ reply, permission_denied, State },

			workspace_server:handle_call (
				{ set_note, "read_user", "note_0", "New text" },
				from,
				State)),

	?VERIFY.

handle_call_set_note_not_found_test () ->

	State = state_fixture (),

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ reply, not_found, State },

			workspace_server:handle_call (
				{ set_note, "write_user", "note_x", "New text" },
				from,
				State)),

	?VERIFY.

handle_call_set_note_ok_test () ->

	State = state_fixture (),

	NewNote =
		#workspace_note {
			note_id = "note_0",
			text = "New text" },

	NewNotes =
		[ NewNote ],

	NewState =
		State#workspace_state {
			notes = NewNotes },

	?EXPECT,

		em:strict (Em, data, write,
			[	match_str ("workspaces/workspace_0/notes"),
				NewNotes ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (

			{ reply, { ok, NewNote }, NewState },

			workspace_server:handle_call (
				{ set_note, "write_user", "note_0", "New text" },
				from,
				State)),

	?VERIFY.

handle_call_delete_note_permission_denied_test () ->

	State = state_fixture (),

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ reply, permission_denied, State },

			workspace_server:handle_call (
				{ delete_note, "read_user", "note_0" },
				from,
				State)),

	?VERIFY.

handle_call_delete_note_not_found_test () ->

	State = state_fixture (),

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ reply, not_found, State },

			workspace_server:handle_call (
				{ delete_note, "write_user", "note_x" },
				from,
				State)),

	?VERIFY.

handle_call_delete_note_ok_test () ->

	State = state_fixture (),

	Note = note_0_fixture (),

	NewNotes = [ ],

	NewState =
		State#workspace_state {
			notes = NewNotes },

	?EXPECT,

		em:strict (Em, data, write,
			[	match_str ("workspaces/workspace_0/notes"),
				NewNotes ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (

			{ reply, { ok, Note }, NewState },

			workspace_server:handle_call (
				{ delete_note, "write_user", "note_0" },
				from,
				State)),

	?VERIFY.

handle_call_test () ->

	State = state_fixture (),

	Message = some_nonsense,

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ stop, { unknown_call, Message }, State },

			workspace_server:handle_call (
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

			{ stop, { unknown_cast, Message }, State },

			workspace_server:handle_cast (
				Message,
				State)),

	?VERIFY.

handle_info_test () ->

	State = state_fixture (),

	Message = some_nonsense,

	?EXPECT,

	?REPLAY,

		?assertEqual (

			{ stop, { unknown_info, Message }, State },

			workspace_server:handle_info (
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

			workspace_server:terminate (
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

			workspace_server:code_change (
				OldVersion,
				State,
				Extra)),

	?VERIFY.
