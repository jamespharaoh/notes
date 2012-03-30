-module (workspace).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("data.hrl").

-compile (export_all).

main () ->
	#template { file = "./templates/page.html" }.

title () ->
	"Notes".

layout () ->

	[	#h1 { text = "Home" },

		layout_add_quick_note (),

		#panel {
			id = quick_notes,
			body = layout_view_quick_notes () }
	].

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

	{ ok, Notes } =
		data:get_quick_notes (workspace_id ()),

	[	#hr { },

		#h2 {
			text = "Quick notes waiting to be processed" },

		lists:map (
			fun layout_one_quick_note/1,
			Notes)
	].

layout_one_quick_note (Note) ->

	PanelId = wf:temp_id (),

	#panel {
		id = PanelId,
		body = [ layout_view_quick_note (Note, PanelId) ] }.

layout_view_quick_note (Note, PanelId) ->

	#p { body = [

		#literal {
			text = Note#note.text },

		#literal {
			text = " " },

		#link {
			text = "edit",
			postback = {
				start_edit,
				PanelId,
				Note#note.note_id } }
	] }.

layout_edit_quick_note (Note, PanelId) ->

	TextId = wf:temp_id (),

	[	#textarea {
			id = TextId,
			text = Note#note.text },

		#button {
			text = "Ok",
			postback = {
				edit_quick_ok,
				Note#note.note_id,
				PanelId,
				TextId } }
	].

event (add_quick_ok) ->

	Text =
		wf:q (add_quick_text),

	data:add_quick_note (
		workspace_id (),
		Text),

	% TODO why does this not work?
	wf:flash (
		#p { body = "Quick note added" }),

	wf:update (
		quick_notes,
		layout_view_quick_notes ());

event ({ start_edit, PanelId, NoteId }) ->

	{ ok, Note } =
		data:get_quick_note (
			workspace_id (),
			NoteId),

	wf:update (
		PanelId,
		layout_edit_quick_note (
			Note,
			PanelId));

event ({ edit_quick_ok, NoteId, PanelId, TextId }) ->

	Text = wf:q (TextId),

	{ ok, Note } =
		data:set_quick_note (
			workspace_id (),
			NoteId,
			Text),

	wf:update (
		PanelId,
		layout_view_quick_note (Note, PanelId)).

workspace_id () ->
	wf:path_info ().
