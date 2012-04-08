% Filename: src/data/notes_data_workspace.erl
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

-module (notes_data_workspace).

-export ([

	% public api

	create/3,
	get_workspace/2,
	stop/1,

	add_note/3,
	delete_note/3,
	get_note/3,
	get_notes/2,
	set_note/4

]).

-include ("notes_data.hrl").

-define (TARGET,
	notes_data_workspace_server).

-define (CALL (Message),
	notes_server:call (
		?TARGET,
		WorkspaceId,
		Message)).

% public api - general

create (WorkspaceId, UserId, Name) ->
	?CALL ({ create, UserId, Name }).

get_workspace (WorkspaceId, UserId) ->
	?CALL ({ get_workspace, UserId }).

stop (WorkspaceId) ->
	?CALL (stop).

% public api - notes

add_note (WorkspaceId, UserId, Text) ->
	?CALL ({ add_note, UserId, Text }).

delete_note (WorkspaceId, UserId, NoteId) ->
	?CALL ({ delete_note, UserId, NoteId }).

get_note (WorkspaceId, UserId, NoteId) ->
	?CALL ({ get_note, UserId, NoteId }).

get_notes (WorkspaceId, UserId) ->
	?CALL ({ get_notes, UserId }).

set_note (WorkspaceId, UserId, NoteId, Text) ->
	?CALL ({ set_note, UserId, NoteId, Text }).
