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
			fun (Note) -> #p { body = Note#note.text } end,
			Notes)
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
		layout_view_quick_notes ()).

workspace_id () ->
	wf:path_info ().
