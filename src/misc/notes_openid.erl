% Filename: src/misc/notes_openid.erl
%
% Copyright 2012 James Pharaoh <james@phsys.co.uk>
%
%    Licensed under the Apache License, Version 2.0 (the "License");
%    you may not use this file except in compliance with the License.
%    You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%    Unless required by applicable law or agreed to in writing, software
%    distributed under the License is distributed on an "AS IS" BASIS,
%    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%    See the License for the specific language governing permissions and
%    limitations under the License

-module (notes_openid).

-export ([
	prepare/3,
	verify/3 ]).

prepare (SessionId, OpenIdUrl, SomeOption) ->

	gen_server:call (
		openid,
		{ prepare, SessionId, OpenIdUrl, SomeOption }).

verify (SessionId, ReturnTo, Params) ->

	gen_server:call (
		openid,
		{ verify, SessionId, ReturnTo, Params }).
