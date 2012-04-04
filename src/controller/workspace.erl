-module (workspace).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("data.hrl").

-compile (export_all).

main () ->
	#template { file = "./templates/page.html" }.

title () ->
	"Notes".

layout () ->

	case wf:user () of

		undefined ->

			wf:redirect ("/");

		_ ->

			[	#h1 { text = "Workspace" },

				layout_add_quick_note (),

				#panel {
					id = quick_notes,
					body = layout_view_quick_notes () }
			]
		end.

layout_add_quick_note () ->

	[	#hr { },

		#h2 {
			text = "Add a quick note" },

		#textarea {
			id = add_quick_text },

		#button {
			id = add_quick_ok,
			text = "Add",
			postback = add_quick_ok }
	].

layout_view_quick_notes () ->

	case workspace_data:get_notes (
			workspace_id (),
			wf:user ()) of

		permission_denied ->

			wf:redirect ("/");

		{ ok, Notes } ->

			[	#hr { },

				#h2 {
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

	[	#textarea {
			id = TextId,
			text = Note#workspace_note.text },

		#button {
			text = "Ok",
			postback = {
				edit_quick_ok,
				Note#workspace_note.note_id,
				PanelId,
				TextId } }
	].

event (add_quick_ok) ->

	Text =
		wf:q (add_quick_text),

	workspace_data:add_note (
		workspace_id (),
		wf:user (),
		Text),

	wf:update (
		quick_notes,
		layout_view_quick_notes ());

event ({ start_edit, PanelId, NoteId }) ->

	{ ok, Note } =
		workspace_data:get_note (
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
		workspace_data:delete_note (
			workspace_id (),
			wf:user (),
			NoteId),

	wf:remove (PanelId);

event ({ edit_quick_ok, NoteId, PanelId, TextId }) ->

	Text = wf:q (TextId),

	{ ok, Note } =
		workspace_data:set_note (
			workspace_id (),
			wf:user (),
			NoteId,
			Text),

	wf:update (
		PanelId,
		layout_view_quick_note (Note, PanelId)).

workspace_id () ->
	wf:path_info ().
