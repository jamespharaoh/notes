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

% redirect modules for testing

-ifdef (TEST).

-define (file, notes_delegate_file).
-define (filelib, notes_delegate_filelib).
-define (io, notes_delegate_io).
-define (supervisor, notes_delegate_supervisor).
-define (timer, notes_delegate_timer).

-else.

-define (file, file).
-define (filelib, filelib).
-define (io, io).
-define (supervisor, supervisor).
-define (timer, timer).

-endif.
