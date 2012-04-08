% Filename: src/misc/notes_store.erl
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

-module (notes_store).

-export ([
	read/1,
	write/2,
	delete_all/0 ]).

-include ("notes_global.hrl").

-ifdef (TEST).
-define (DIR, "test").
-else.
-define (DIR, "data").
-endif.

full_path (Path) ->
	[ ?DIR, "/", Path ].

% public api

read (Path) ->

	FullPath = full_path (Path),

	% read records

	case ?file:consult (FullPath) of

		{ ok, Records } ->

			% return

			{ ok, Records };

		{ error, enoent } ->

			% not found, return empty

			{ ok, [] }

	end.

write (Path, Records) ->

	FullPath = full_path (Path),

	% make sure directory exists

	ok =
		?filelib:ensure_dir (FullPath),

	% open file

	{ ok, IoDevice } =
		?file:open (FullPath, [ write ]),

	% write records

	lists:foreach (

		fun (Record) ->

			ok =
				?io:fwrite (
					IoDevice,
					"~p.~n",
					[ Record ])

			end,

		Records),

	% close file

	ok =
		?file:close (IoDevice),

	% return

	ok.

delete_all () ->

	notes_file:delete_dir (?DIR).
