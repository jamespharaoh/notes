{ application, notes, [
	{ description, "Notes"},
	{ vsn, "1" },
	{ applications, [
		kernel,
		stdlib
	] },
	{ registered, [] },
	{ mod, { notes_app, [] } },
	{ env, [
		{ bind_address, "0.0.0.0" },
		{ port, 8000 },
		{ server_name, notes },
		{ document_root, "./static" }
	] },
	{ modules, [
		notes_app,
		notes_sup
	] }
] }.
