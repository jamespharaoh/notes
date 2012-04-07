-module (notes_random_test).

-include ("notes_test.hrl").

% macros

-define (MOCK_MODULES, [
	crypto ]).

-define (TARGET,
	notes_random).

random_id_test () ->

	RandomId =
		"abcdefghijklmnop",

	?EXPECT,

		lists:foreach (
			fun (Char) ->
				?expect (crypto, rand_uniform,
					[ 0, 26 ],
					{ return, Char - $a })
				end,
			RandomId),

	?REPLAY,

		?assertEqual (
			RandomId,
			?TARGET:random_id ()),

	?VERIFY.
