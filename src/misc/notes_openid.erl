-module (notes_openid).

-export ([
	prepare/3 ]).

prepare (SessionId, OpenIdUrl, SomeOption) ->
	gen_server:call (
		openid,
		{ prepare, SessionId, OpenIdUrl, SomeOption }).
