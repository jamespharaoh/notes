-module (notes_test).

-export ([
	match_str/1 ]).

match_str (String) ->

	fun (Arg) ->
		lists:flatten (Arg) == lists:flatten (String)
		end.
