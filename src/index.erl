-module (index).

-include_lib ("nitrogen_core/include/wf.hrl").

-compile (export_all).

main () -> #template { file="./templates/page.html" }.

title () -> "Notes".

layout() ->
	#p { body = [ "Hello world" ]}.
