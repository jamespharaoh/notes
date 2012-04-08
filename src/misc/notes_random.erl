% Filename: src/misc/notes_random.erl
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

-module (notes_random).

-export ([
	random_id/0 ]).

% generate identifiers

random_id () ->

	random_str (16, list_to_tuple ("abcdefghijklmnopqrstuvwxyz")).

random_str (0, _Chars) -> [];

random_str (Len, Chars) ->

	[ random_char (Chars) | random_str (Len - 1, Chars) ].

random_char (Chars) ->

	element (
		1 + crypto:rand_uniform (0, tuple_size (Chars)),
		Chars).
