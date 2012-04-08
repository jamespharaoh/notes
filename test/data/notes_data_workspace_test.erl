% Filename: test/data/notes_data_workspace_test.erl
%
% Copyright 2012 James Pharaoh <james@phsys.co.uk>
%
%    Licensed under the Apache License, Version 2.0 (the "License");
%    you may not use this file except in compliance with the License.
%    You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%    Unless required by applicable law or agreed to in writing, software
%    distributed under the License is distributed on an "AS IS" BASIS,
%    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%    See the License for the specific language governing permissions and
%    limitations under the License

-module (notes_data_workspace_test).

-include ("notes_global.hrl").
-include ("notes_test.hrl").

% macros

-define (MOCK_MODULES, [
	notes_server ]).

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
