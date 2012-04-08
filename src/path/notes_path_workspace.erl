% Filename: src/path/notes_path_workspace.erl
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

-module (notes_path_workspace).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_data.hrl").

-compile (export_all).

main () ->

	case wf:user () of

		undefined ->

			wf:redirect ("/");

		_ ->

			% load workspace

			{ ok, Workspace } =
				notes_data_workspace:get_workspace (
					workspace_id (),
					wf:user ()),

			wf:state (workspace, Workspace),

			% load notes

			{ ok, Notes } =
				notes_data_workspace:get_notes (
					workspace_id (),
					wf:user ()),

			wf:state (notes, Notes),

			% render page

			#template { file = "./templates/page.html" }

		end.

title () ->

	Workspace =
		wf:state (workspace),

	[ Workspace #workspace.name, " - Notes workspace" ].

layout () ->

	[	#h1 { text = "Workspace" },

		layout_add_quick_note (),

		#panel {
			id = quick_notes,
			body = layout_view_quick_notes () }
	].

layout_add_quick_note () ->

	[	#h2 {
			text = "Add a quick note" },

		#p { body = [

			#textarea {
				id = add_quick_text }
		] },

		#p { body = [

			#button {
				id = add_quick_ok,
				text = "Add note",
				postback = add_quick_ok }
		] }
	].

layout_view_quick_notes () ->

	case notes_data_workspace:get_notes (
			workspace_id (),
			wf:user ()) of

		permission_denied ->

			wf:redirect ("/");

		{ ok, Notes } ->

			[	#h2 {
					text = "Quick notes waiting to be processed" },

				lists:map (
					fun layout_one_quick_note/1,
					Notes)
			]

		end.

layout_one_quick_note (Note) ->

	PanelId = wf:temp_id (),

	#panel {
		id = PanelId,
		body = [ layout_view_quick_note (Note, PanelId) ] }.

layout_view_quick_note (Note, PanelId) ->

	#p { body = [

		#literal { text = Note#workspace_note.text },

		#literal { text = " " },

		#link {
			text = "edit",
			postback = {
				start_edit,
				PanelId,
				Note#workspace_note.note_id } },

		#literal { text = " " },

		#link {
			text = "delete",
			postback = {
				delete,
				Note#workspace_note.note_id,
				PanelId } }
	] }.

layout_edit_quick_note (Note, PanelId) ->

	TextId = wf:temp_id (),

	#p { body = [

		#textarea {
			id = TextId,
			text = Note#workspace_note.text },

		" ",

		#button {
			text = "Ok",
			postback = {
				edit_quick_ok,
				Note#workspace_note.note_id,
				PanelId,
				TextId } }
	] }.

event (add_quick_ok) ->

	Text =
		wf:q (add_quick_text),

	notes_data_workspace:add_note (
		workspace_id (),
		wf:user (),
		Text),

	wf:update (
		quick_notes,
		layout_view_quick_notes ());

event ({ start_edit, PanelId, NoteId }) ->

	{ ok, Note } =
		notes_data_workspace:get_note (
			workspace_id (),
			wf:user (),
			NoteId),

	wf:update (
		PanelId,
		layout_edit_quick_note (
			Note,
			PanelId));

event ({ delete, NoteId, PanelId }) ->

	{ ok, _Note } =
		notes_data_workspace:delete_note (
			workspace_id (),
			wf:user (),
			NoteId),

	wf:remove (PanelId);

event ({ edit_quick_ok, NoteId, PanelId, TextId }) ->

	Text = wf:q (TextId),

	{ ok, Note } =
		notes_data_workspace:set_note (
			workspace_id (),
			wf:user (),
			NoteId,
			Text),

	wf:update (
		PanelId,
		layout_view_quick_note (Note, PanelId)).

workspace_id () ->
	wf:path_info ().
