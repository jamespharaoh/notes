% Filename: src/misc/notes_start.erl
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

-module (notes_start).

-ifndef (TEST).

-export ([
	run/0 ]).

run () ->

	% start system

	ok = application:start (compiler),
	ok = application:start (syntax_tools),
	ok = application:start (crypto),
	ok = application:start (inets),
	ok = application:start (public_key),
	ok = application:start (ssl),
	ok = application:start (xmerl),

	% start mochiweb

	ok = application:start (mochiweb),

	% start openid

	ok = application:start (ibrowse),
	ok = application:start (openid),

	% start nitrogen

	ok = application:start (nprocreg),
	ok = application:start (sasl),
	ok = application:start (nitrogen_core),

	% start notes

	ok = application:start (notes),

	ok.

-endif.
