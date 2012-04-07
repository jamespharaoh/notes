-module (notes_config_test).

-include ("notes_test.hrl").

% macros

-define (MOCK_MODULES,
	[ application ]).

-define (TARGET,
	notes_config).

get_test () ->

	?EXPECT,

		em:strict (Em, application, get_env,
			[ key ],
			{ return, value }),

	?REPLAY,

		?assertEqual (
			value,
			?TARGET:get (key)),

	?VERIFY.
