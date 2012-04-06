-module (notes_app_test).

-include_lib ("eunit/include/eunit.hrl").

-include ("data.hrl").

% macros

-define (EXPECT,
	Em = em:new (),
	em:nothing (Em, notes_supervisor)).

-define (REPLAY,
	em:replay (Em)).

-define (VERIFY,
	em:verify (Em)).

-define (TARGET,
	notes_data_workspace_server).

% fixtures

start_test () ->

	StartType = start_type,
	StartArgs = start_args,

	?EXPECT,

		em:strict (Em, notes_supervisor, start_link,
			[ ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			notes_app:start (
				StartType,
				StartArgs)),

	?VERIFY.

stop_test () ->

	State = state,

	?EXPECT,

	?REPLAY,

		?assertEqual (
			ok,
			notes_app:stop (State)),

	?VERIFY.
