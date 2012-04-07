-define (TRACE,
	io:format (
		standard_error,
		"TRACE ~w:~w~n",
		[ ?MODULE, ?LINE ])).

-define (TRACE (Arg),
	io:format (
		standard_error,
		"TRACE ~w:~w: ~p~n",
		[ ?MODULE, ?LINE, Arg ])).
