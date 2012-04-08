% Filename: test/misc/notes_test_server.erl
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

-module (notes_test_server).

-behaviour (gen_server).

-export ([

	% public api

	start_link/2,
	stop/1,

	% callbacks

	init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3 ]).

% public api

start_link (Name, Target) ->

	gen_server:start_link (
		Name,
		?MODULE,
		[ Target ],
		[]).

stop (Pid) ->

	gen_server:call (
		Pid,
		stop).

% callbacks

init ([ Target ]) ->

	{ ok, Target }.

handle_call (stop, _From, Target) ->

	{ stop, normal, ok, Target };

handle_call (Request, From, Target) ->

	Target:handle_call (Request, From, Target).

handle_cast (Message, Target) ->

	Target:handle_cast (Message).

handle_info (Info, Target) ->

	Target:handle_info (Info).

terminate (_Reason, _Target) ->

	ok.

code_change (_OldVersion, Target, _Extra) ->

	{ ok, Target }.
