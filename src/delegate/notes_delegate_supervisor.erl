-module (notes_delegate_supervisor).

-ifndef (TEST).

-export ([
	start_link/3 ]).

start_link (Name, Module, Args) ->
	supervisor:start_link (Name, Module, Args).

-endif.
