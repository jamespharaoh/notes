-module (notes_delegate_timer).

-ifndef (TEST).

-export ([
	sleep/1 ]).

sleep (Millis) ->

	timer:sleep (Millis).

-endif.
