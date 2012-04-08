% Filename: include/notes_global.hrl
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
