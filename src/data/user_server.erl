-module (user_server).

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

	WorkspaceId = random:random_id (),

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

	data:read (full_name (State, Name)).

write (State, Name, Value) ->

	data:write (full_name (State, Name), Value).

full_name (State, Name) ->

	[	"users/",
		misc:sha1 (State #user_state.user_id),
		"/",
		Name ].
