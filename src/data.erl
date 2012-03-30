-module (data).

-behaviour (gen_server).

-include ("data.hrl").

-export ([

	% public api

	start_link/0,
	stop/0,

	add_quick_note/2,
	get_quick_notes/1,

	% callbacks

	init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3 ]).

-record (state, {
	notes = [] }).

% public api

start_link () ->

	gen_server:start_link (
		{ local, data },
		?MODULE,
		[],
		[]).

stop () ->

	gen_server:stop (data).

add_quick_note (WorkspaceId, Text) ->

	gen_server:call (
		data,
		{ add_quick_note, WorkspaceId, Text }).

get_quick_notes (WorkspaceId) ->

	gen_server:call (
		data,
		{ get_quick_notes, WorkspaceId }).

% callbacks

init ([]) ->

	io:format ("Data starting~n"),

	{ ok, #state {} }.

handle_call ({ add_quick_note, WorkspaceId, Text }, _From, State0) ->

	NoteId = random_id (),

	Note = #note {
		note_id = NoteId,
		workspace_id = WorkspaceId,
		text = Text },

	{ ok, Notes0, State1 } =
		get_notes (WorkspaceId, State0),

	Notes1 = [ Note | Notes0 ],

	{ ok, State2 } =
		set_notes (WorkspaceId, Notes1, State1),

	{ reply, { ok, NoteId }, State2 };

handle_call ({ get_quick_notes, WorkspaceId }, _From, State0) ->

	{ ok, Notes, State1 } =
		get_notes (WorkspaceId, State0),

	Ret = { ok, Notes },

	{ reply, Ret, State1 };

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

% notes abstractions

get_notes (WorkspaceId, State) ->

	{ ok, Notes } =
		read_notes (WorkspaceId),

	{ ok, Notes, State }.

set_notes (WorkspaceId, Notes, State) ->

	write_notes (WorkspaceId, Notes),

	{ ok, State }.

% permanent storage

read_notes (WorkspaceId) ->

	Filename = [ "data/", WorkspaceId, "/notes" ],

	{ ok, Notes } =
		file:consult (Filename),

	{ ok, Notes }.

write_notes (WorkspaceId, Notes) ->

	Filename = [ "data/", WorkspaceId, "/notes" ],

	filelib:ensure_dir (Filename),

	{ ok, IoDevice } =
		file:open (Filename, [ write ]),

	lists:foreach (
		fun (Note) -> io:fwrite (IoDevice, "~p.~n", [ Note ]) end,
		Notes),

	file:close (IoDevice),

	ok.

% generate identifiers

random_id () ->

	random_str (16, list_to_tuple ("abcdefghijklmnopqrstuvwxyz")).

random_str (0, _Chars) -> [];

random_str (Len, Chars) ->

	[ random_char (Chars) | random_str (Len - 1, Chars) ].

random_char (Chars) ->

	element (random:uniform (tuple_size (Chars)), Chars).
