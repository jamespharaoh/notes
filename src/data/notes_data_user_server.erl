% Filename: src/data/notes_data_user_server.erl
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

-module (notes_data_user_server).

-behaviour (gen_server).

-export ([

	% callbacks

	init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3 ]).

-include ("notes_data.hrl").

% callbacks

init ([ UserId ]) ->

	State0 = #user_state {
		user_id = UserId },

	{ ok, Workspaces } =
		read (State0, "workspaces"),

	State1 = State0 #user_state {
		workspaces = Workspaces },

	{ ok, State1 }.

handle_call (get_workspaces, _From, State) ->

	Workspaces =
		State #user_state.workspaces,

	Ret = { ok, Workspaces },

	{ reply, Ret, State };

handle_call ({ create_workspace, Name }, _From, State0) ->

	% create workspace

	WorkspaceId = notes_random:random_id (),

	Workspace = #user_workspace {
		workspace_id = WorkspaceId,
		name = Name },

	Workspaces = [ Workspace | State0 #user_state.workspaces ],

	% save workspaces

	write (State0, "workspaces", Workspaces),

	% return

	Ret = { ok, Workspace },

	State1 = State0 #user_state { workspaces = Workspaces },

	{ reply, Ret, State1 };

handle_call (stop, _From, State) ->

	{ stop, normal, ok, State };

handle_call (Request, _From, State) ->

	{ stop, { unknown_call, Request }, State }.

handle_cast (Message, State) ->

	{ stop, { unknown_cast, Message }, State }.

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

	[	"users/",
		notes_misc:sha1 (State #user_state.user_id),
		"/",
		Name ].
