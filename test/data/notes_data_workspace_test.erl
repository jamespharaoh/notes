-module (notes_data_workspace_test).

-include ("notes_test.hrl").

% macros

-define (MOCK_MODULES,
	[ notes_server ]).

-define (TARGET,
	notes_data_workspace).

-define (SERVER,
	notes_data_workspace_server).

% init tests

create_test () ->
	?NOTES_SERVER_TEST (create, [ "owner id", "workspace name" ]).

get_workspace_test () ->
	?NOTES_SERVER_TEST (get_workspace, [ "user id" ]).

stop_test () ->
	?NOTES_SERVER_TEST (stop, [ ]).

% public api - notes

add_note_test () ->
	?NOTES_SERVER_TEST (add_note, [ "user id", "text" ]).

delete_note_test () ->
	?NOTES_SERVER_TEST (delete_note, [ "user id", "note id" ]).

get_note_test () ->
	?NOTES_SERVER_TEST (get_note, [ "user id", "note id" ]).

get_notes_test () ->
	?NOTES_SERVER_TEST (get_notes, [ "user id" ]).

set_note_test () ->
	?NOTES_SERVER_TEST (set_note, [ "user id", "note id", "text" ]).
