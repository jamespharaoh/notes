% Filename: src/misc/notes_file.erl
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

-module (notes_file).

-export ([
	delete_dir/1 ]).

-include_lib ("kernel/include/file.hrl").

delete_dir (Path) ->

	delete_dir ([ Path ], undefined).

delete_dir ([ Path | Rest ], Prefix) ->

	FullPath =
		case Prefix of
			undefined -> Path;
			_ -> [ Prefix, "/", Path ]
			end,

	case file:read_link_info (FullPath) of

		{ error, enoent } ->

			ok;

		{ ok, FileInfo } ->

			case FileInfo #file_info.type of

				regular ->

					file:delete (FullPath),

					delete_dir (Rest, Prefix);

				directory ->

					{ ok, Filenames } =
						file:list_dir (FullPath),

					delete_dir (Filenames, FullPath),

					file:del_dir (FullPath),

					delete_dir (Rest, Prefix)

				end
		end;

delete_dir ([], _Prefix) ->

	ok.
