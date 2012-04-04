-module (user_data).

-behaviour (gen_server).

-export ([

	% public api

	get_workspaces/1,
	create_workspace/2,

	% callbacks

	init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3 ]).

-include ("data.hrl").

-record (state, {
	user_id,
	workspaces = [] }).

% public api

get_workspaces (UserId) ->

	gen_server:call (get_pid (UserId),
		get_workspaces).

create_workspace (UserId, Name) ->

	gen_server:call (get_pid (UserId),
		{ create_workspace, Name }).

% internal api

get_pid (UserId) ->

	Name = { user, UserId },

	case gen_server:start_link (
			{ global, Name },
			?MODULE,
			[ UserId ],
			[]) of

		{ error, { already_started, Pid }} ->
			Pid;

		{ ok, Pid } ->
			Pid

	end.

% callbacks

init ([ UserId ]) ->

	State0 = #state {
		user_id = UserId },

	{ ok, Workspaces } =
		read (State0, "workspaces"),

	State1 = State0#state {
		workspaces = Workspaces },

	{ ok, State1 }.

handle_call (get_workspaces, _From, State) ->

	Workspaces =
		State#state.workspaces,

	Ret = { ok, Workspaces },

	{ reply, Ret, State };

handle_call ({ create_workspace, Name }, _From, State0) ->

	% create workspace

	WorkspaceId = misc:random_id (),

	Workspace = #user_workspace {
		workspace_id = WorkspaceId,
		name = Name },

	Workspaces = [ Workspace | State0#state.workspaces ],

	% save workspaces

	write (State0, "workspaces", Workspaces),

	% return

	Ret = { ok, Workspace },

	State1 = State0#state { workspaces = Workspaces },

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

% misc functions

read (State, Name) ->

	data:read (full_name (State, Name)).

write (State, Name, Value) ->

	data:write (full_name (State, Name), Value).

full_name (State, Name) ->

	[	"users/",
		misc:sha1 (State#state.user_id),
		"/",
		Name ].
