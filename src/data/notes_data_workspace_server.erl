-module (notes_data_workspace_server).

-behaviour (gen_server).

-export ([

	% callbacks

	init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3 ]).

-include ("data.hrl").

-ifdef (TEST).
-include_lib ("eunit/include/eunit.hrl").
-endif.

% gen_server api

init ([ WorkspaceId ]) ->

	State0 = #workspace_state {
		workspace_id = WorkspaceId },

	{ ok, Workspaces } =
		read (State0, "workspace"),

	Workspace =
		case Workspaces of
			[] -> undefined;
			[ Something ] -> Something
			end,

	{ ok, Notes } =
		read (State0, "notes"),

	{ ok, Perms } =
		read (State0, "perms"),

	State1 = State0#workspace_state {
		workspace = Workspace,
		notes = Notes,
		perms = Perms },

	{ ok, State1 }.

handle_call (stop, _From, State) ->

	{ stop, normal, ok, State };

handle_call ({ create, UserId, Name }, _From, State0) ->

	% check for existing workspace

	case State0 #workspace_state.workspace of

		undefined ->

			% create workspace

			Workspace = #workspace {
				workspace_id = State0 #workspace_state.workspace_id,
				name = Name },

			% create permissions

			Perms = [
				#workspace_perm {
					user_id = UserId,
					roles = [ owner ] }],

			% save changed stuff

			write (State0, "workspace", [ Workspace ]),

			write (State0, "perms", Perms),

			% return

			State1 =
				State0 #workspace_state {
					workspace = Workspace,
					perms = Perms },

			Ret = ok,

			{ reply, Ret, State1 };

		_ ->

			Ret = already_exists,

			{ reply, Ret, State0 }

		end;

handle_call ({ get_workspace, UserId }, _From, State) ->

	% check permissions

	case check_perms (State, UserId, [ owner, read ]) of

		false ->

			% return error

			Ret = permission_denied,

			{ reply, Ret, State };

		true ->

			% return workspace

			Ret = { ok, State #workspace_state.workspace  },

			{ reply, Ret, State }

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
				note_id = notes_random:random_id (),
				text = Text },

			Notes = [ Note | State0#workspace_state.notes ],

			% save notes

			write (State0, "notes", Notes),

			% return

			Ret = { ok, Note },

			State1 = State0#workspace_state { notes = Notes },

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

			Ret = { ok, State#workspace_state.notes },

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
					State#workspace_state.notes) of

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
					State0#workspace_state.notes) of

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
							State0#workspace_state.notes,
							Note1),

					% save notes

					write (State0, "notes", Notes),

					% return

					Ret = { ok, Note1 },

					State1 = State0#workspace_state { notes = Notes },

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
					State0#workspace_state.notes) of

				false ->

					% return error

					Ret = not_found,

					{ reply, Ret, State0 };

				{ value, Note, Notes } ->

					% save notes

					write (State0, "notes", Notes),

					% return

					Ret = { ok, Note },

					State1 = State0#workspace_state { notes = Notes },

					{ reply, Ret, State1 }

				end
		end;

handle_call (Request, _From, State) ->

	{ stop, { unknown_call, Request }, State }.

handle_cast (Request, State) ->

	{ stop, { unknown_cast, Request }, State }.

handle_info (Info, State) ->

	{ stop, { unknown_info, Info }, State }.

terminate (_Reason, _State) ->

	ok.

code_change (_OldVersion, State, _Extra) ->

	{ ok, State }.

% misc functions

read (State, Name) ->

	notes_store:read (full_name (State, Name)).

write (State, Name, Value) ->

	notes_store:write (full_name (State, Name), Value).

full_name (State, Name) ->

	[	"workspaces/",
		State#workspace_state.workspace_id,
		"/",
		Name ].

get_roles (State, UserId) ->

	case lists:keyfind (
			UserId,
			#workspace_perm.user_id,
			State#workspace_state.perms) of

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

	State = #workspace_state {
		workspace_id = "abc" },

	?assertEqual (
		"workspaces/abc/name",
		lists:flatten (full_name (State, "name"))).

get_roles_test () ->

	State = #workspace_state {
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

	State = #workspace_state {
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
