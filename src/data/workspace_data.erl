-module (workspace_data).

-export ([

	% public api

	set_owner/2,

	add_note/3,
	delete_note/3,
	get_note/3,
	get_notes/2,
	set_note/4

]).

-include ("data.hrl").

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
			workspace_server,
			[ WorkspaceId ],
			[]) of

		{ error, { already_started, Pid }} ->
			Pid;

		{ ok, Pid } ->
			Pid

	end.
