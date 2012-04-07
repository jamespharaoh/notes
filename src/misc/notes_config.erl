-module (notes_config).

-export ([
	get/1 ]).

get (Key) ->
	application:get_env (Key).
