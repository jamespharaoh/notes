-module (notes_app_test).

-include_lib ("eunit/include/eunit.hrl").

-include ("notes_data.hrl").
-include ("notes_global.hrl").
-include ("notes_test.hrl").

% macros

-define (MOCK_MODULES, [
	notes_supervisor ]).

-define (TARGET,
	notes_data_workspace_server).

% fixtures

start_test () ->

	StartType = start_type,
	StartArgs = start_args,

	?EXPECT,

		?expect (notes_supervisor, start_link,
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
