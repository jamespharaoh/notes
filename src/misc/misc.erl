-module (misc).

-export ([
	random_id/0,
	sha1/1 ]).

% hashes and stuff

sha1 (Text) ->

	bin_to_hex (crypto:sha (Text)).

bin_to_hex (Binary)
	when is_binary (Binary) ->

	lists:flatten (lists:map (

		fun (X) ->
			io_lib:format("~2.16.0b", [X])
			end,

		binary_to_list (Binary))).

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
