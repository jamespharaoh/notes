-module (notes_random).

-export ([
	random_id/0 ]).

% generate identifiers

random_id () ->

	random_str (16, list_to_tuple ("abcdefghijklmnopqrstuvwxyz")).

random_str (0, _Chars) -> [];

random_str (Len, Chars) ->

	[ random_char (Chars) | random_str (Len - 1, Chars) ].

random_char (Chars) ->

	element (
		1 + crypto:rand_uniform (0, tuple_size (Chars)),
		Chars).
