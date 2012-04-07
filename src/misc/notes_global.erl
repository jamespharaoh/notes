-module (notes_global).

-export ([
	registered_names/0 ]).

registered_names () ->

	global:registered_names ().
