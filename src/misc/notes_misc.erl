-module (notes_misc).

-export ([
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
