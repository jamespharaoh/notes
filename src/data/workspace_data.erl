-module (workspace_data).

-behaviour (gen_server).

-export ([

	% public api

	set_owner/2,

	add_note/3,
	delete_note/3,
	get_note/3,
	get_notes/2,
	set_note/4,

	% callbacks

	init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3 ]).

-include ("data.hrl").

-record (state, {
	workspace_id,
	perms = [],
	notes = [] }).

-ifdef (TEST).
-include_lib ("eunit/include/eunit.hrl").
-endif.

% public api - general

set_owner (WorkspaceId, UserId) ->

	gen_server:call (get_pid (WorkspaceId),
		{ set_owner, UserId }).

% public api - notes

add_note (WorkspaceId, UserId, Text) ->

	gen_server:call (get_pid (WorkspaceId),
		{ add_note, UserId, Text }).

delete_note (WorkspaceId, UserId, NoteId) ->

	gen_server:call (get_pid (WorkspaceId),
		{ delete_note, UserId, NoteId }).

get_note (WorkspaceId, UserId, NoteId) ->

	gen_server:call (get_pid (WorkspaceId),
		{ get_note, UserId, NoteId }).

get_notes (WorkspaceId, UserId) ->

	gen_server:call (get_pid (WorkspaceId),
		{ get_notes, UserId }).

set_note (WorkspaceId, UserId, NoteId, Text) ->

	gen_server:call (get_pid (WorkspaceId),
		{ set_note, UserId, NoteId, Text }).

% internal api

get_pid (WorkspaceId) ->

	Name = { workspace, WorkspaceId },

	case gen_server:start_link (
			{ global, Name },
			?MODULE,
			[ WorkspaceId ],
			[]) of

		{ error, { already_started, Pid }} ->
			Pid;

		{ ok, Pid } ->
			Pid

	end.

init ([ WorkspaceId ]) ->

	io:format ("Data starting~n"),

	State0 = #state {
		workspace_id = WorkspaceId },

	{ ok, Notes } =
		read (State0, "notes"),

	{ ok, Perms } =
		read (State0, "perms"),

	State1 = State0#state {
		notes = Notes,
		perms = Perms },

	{ ok, State1 }.

handle_call ({ set_owner, UserId }, _From, State0) ->

	% check for existing perms

	case State0#state.perms of

		[] ->

			% set new perms

			Perms = [
				#workspace_perm {
					user_id = UserId,
					roles = [ owner ] }],

			% save perms

			write (State0, "perms", Perms),

			% return

			State1 =
				State0#state {
					perms = Perms },

			Ret = ok,

			{ reply, Ret, State1 };

		[ _ | _ ] ->

			Ret = already_exists,

			{ reply, Ret, State0 }

		end;

handle_call ({ add_note, UserId, Text }, _From, State0) ->

	% check permissions

	case check_perms (State0, UserId, [ owner, write ]) of

		false ->

			% return error

			Ret = permission_denied,

			{ reply, Ret, State0 };

		true ->

			% add note

			Note = #workspace_note {
				note_id = misc:random_id (),
				text = Text },

			Notes = [ Note | State0#state.notes ],

			% save notes

			write (State0, "notes", Notes),

			% return

			Ret = { ok, Note },

			State1 = State0#state { notes = Notes },

			{ reply, Ret, State1 }

		end;

handle_call ({ get_notes, UserId }, _From, State) ->

	% check permissions

	case check_perms (State, UserId, [ owner, write, read ]) of

		false ->

			% return error

			Ret = permission_denied,

			{ reply, Ret, State };

		true ->

			% return

			Ret = { ok, State#state.notes },

			{ reply, Ret, State }

		end;

handle_call ({ get_note, UserId, NoteId }, _From, State) ->

	% check permissions

	case check_perms (State, UserId, [ owner, write, read ]) of

		false ->

			% return error

			Ret = permission_denied,

			{ reply, Ret, State };

		true ->

			% find note

			case lists:keyfind (
					NoteId,
					#workspace_note.note_id,
					State#state.notes) of

				false ->

					% return error

					Ret = not_found,

					{ reply, Ret, State };

				Note ->

					% return

					Ret = { ok, Note },

					{ reply, Ret, State }

				end
		end;

handle_call ({ set_note, UserId, NoteId, Text }, _From, State0) ->

	% check permissions

	case check_perms (State0, UserId, [ owner, write ]) of

		false ->

			% return error

			Ret = permission_denied,

			{ reply, Ret, State0 };

		true ->

			% find note

			case lists:keyfind (
					NoteId,
					#workspace_note.note_id,
					State0#state.notes) of

				false ->

					% return error

					Ret = not_found,

					{ reply, Ret, State0 };

				Note0 ->

					% update note

					Note1 = Note0#workspace_note {
						text = Text },

					Notes =
						lists:keystore (
							NoteId,
							#workspace_note.note_id,
							State0#state.notes,
							Note1),

					% save notes

					write (State0, "notes", Notes),

					% return

					Ret = { ok, Note1 },

					State1 = State0#state { notes = Notes },

					{ reply, Ret, State1 }

				end
		end;

handle_call ({ delete_note, UserId, NoteId }, _From, State0) ->

	% check permissions

	case check_perms (State0, UserId, [ owner, write ]) of

		false ->

			% return error

			Ret = permission_denied,

			{ reply, Ret, State0 };

		true ->

			% find and remove note

			case lists:keytake (
					NoteId,
					#workspace_note.note_id,
					State0#state.notes) of

				false ->

					% return error

					Ret = not_found,

					{ reply, Ret, State0 };

				{ value, Note, Notes } ->

					% save notes

					write (State0, "notes", Notes),

					% return

					Ret = { ok, Note },

					State1 = State0#state { notes = Notes },

					{ reply, Ret, State1 }

				end
		end;

handle_call (_Request, _From, _State) ->

	error1.

handle_cast (_Message, _State) ->

	error2.

handle_info (_Info, _State) ->

	error3.

terminate (_Reason, _State) ->

	error4.

code_change (_OldVersion, _State, _Extra) ->

	error5.

-ifdef (TEST).

handle_call_add_note_test () ->

	State = state_fixture (),

	% permission failure

	?assertEqual (

		{ reply, permission_denied, State },

		handle_call (
			{ add_note, read_user, "Body" },
			from,
			State)).

handle_call_get_notes_test () ->

	State = state_fixture (),
	Notes = notes_fixture (),

	% permission failure

	?assertEqual (

		{ reply, permission_denied, State },

		handle_call (
			{ get_notes, none_user },
			from,
			State)),

	% success

	?assertEqual (

		{ reply, { ok, Notes }, State },

		handle_call (
			{ get_notes, read_user },
			from,
			State)).

handle_call_get_note_test () ->

	State = state_fixture (),
	Note = note_0_fixture (),

	% permission failure

	?assertEqual (

		{ reply, permission_denied, State },

		handle_call (
			{ get_note, none_user, note_0 },
			from,
			State)),

	% success

	?assertEqual (

		{ reply, { ok, Note }, State },

		handle_call (
			{ get_note, read_user, note_0 },
			from,
			State)).

handle_call_set_note_test () ->

	State = state_fixture (),

	% permission failure

	?assertEqual (

		{ reply, permission_denied, State },

		handle_call (
			{ set_note, read_user, note_0, "New text" },
			from,
			State)).

handle_call_delete_note_test () ->

	State = state_fixture (),

	% permission failure

	?assertEqual (

		{ reply, permission_denied, State },

		handle_call (
			{ delete_note, read_user, note_0 },
			from,
			State)).

state_fixture () ->

	#state {
		notes = notes_fixture (),
		perms = perms_fixture () }.

perms_fixture () ->

	[	#workspace_perm {
			user_id = read_user,
			roles = [ read ] },

		#workspace_perm {
			user_id = write_user,
			roles = [ write ] },

		#workspace_perm {
			user_id = owner_user,
			roles = [ owner ] }
	].

notes_fixture () ->

	[ note_0_fixture () ].

note_0_fixture () ->

	#workspace_note {
		note_id = note_0,
		text = "This is note 0" }.

-endif.

% misc functions

read (State, Name) ->

	data:read (full_name (State, Name)).

write (State, Name, Value) ->

	data:write (full_name (State, Name), Value).

full_name (State, Name) ->

	[	"data/workspaces/",
		State#state.workspace_id,
		"/",
		Name ].

get_roles (State, UserId) ->

	case lists:keyfind (
			UserId,
			#workspace_perm.user_id,
			State#state.perms) of

		false ->
			[];

		#workspace_perm { roles = Roles } ->
			Roles

	end.

check_perms (State, UserId, NeedRoles) ->

	HasRoles =
		get_roles (State, UserId),

	lists:any (
		fun (NeedRole) ->
			lists:member (NeedRole, HasRoles)
			end,
		NeedRoles).

-ifdef (TEST).

full_name_test () ->

	State = #state {
		workspace_id = "abc" },

	?assertEqual (
		"data/workspaces/abc/name",
		lists:flatten (full_name (State, "name"))).

get_roles_test () ->

	State = #state {
		perms = [
			#workspace_perm {
				user_id = user1,
				roles = [ a, b ] }
		] },

	?assertEqual (
		[ a, b ],
		get_roles (State, user1)),

	?assertEqual (
		[],
		get_roles (State, user2)).

check_perms_test () ->

	State = #state {
		perms = [
			#workspace_perm {
				user_id = user1,
				roles = [ a, b ] }
		] },

	% single role match

	?assertEqual (true, check_perms (State, user1, [ a ])),
	?assertEqual (false, check_perms (State, user2, [ a ])),

	% single role miss

	?assertEqual (false, check_perms (State, user1, [ c ])),
	?assertEqual (false, check_perms (State, user2, [ c ])),

	% one match one miss

	?assertEqual (true, check_perms (State, user1, [ a, c ])),
	?assertEqual (false, check_perms (State, user2, [ a, c ])),

	% no roles

	?assertEqual (false, check_perms (State, user1, [ ])),
	?assertEqual (false, check_perms (State, user2, [ ])).

-endif.
