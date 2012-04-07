-module (notes_global_test).

-include ("notes_test.hrl").

% macros

-define (MOCK_MODULES,
	[ ]).

-define (TARGET,
	notes_global).

registered_names_test () ->

	?assertEqual (
		global:registered_names (),
		?TARGET:registered_names ()).
