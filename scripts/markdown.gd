class_name Markdown
extends RefCounted
## A small Markdown -> RichTextLabel BBCode converter, covering what the
## challenge readmes use: headings, paragraphs, **bold**, *italic*, `code`,
## fenced code blocks, > quotes and bullet lists.

const HEADING_COLOR := "#f0d080"
const CODE_COLOR := "#f0c070"
const BLOCK_COLOR := "#e8d8b0"


static func to_bbcode(md: String) -> String:
	var out := PackedStringArray()
	var in_code := false
	for raw in md.replace("\r", "").split("\n"):
		var line: String = raw
		if line.strip_edges().begins_with("```"):
			in_code = not in_code
			continue
		if in_code:
			out.append("[indent][code][color=%s]%s[/color][/code][/indent]" % [BLOCK_COLOR, _escape(line)])
			continue
		var trimmed := line.strip_edges()
		if trimmed.begins_with("### "):
			out.append("[font_size=20][color=%s][b]%s[/b][/color][/font_size]" % [HEADING_COLOR, _inline(trimmed.substr(4))])
		elif trimmed.begins_with("## "):
			out.append("[font_size=23][color=%s][b]%s[/b][/color][/font_size]" % [HEADING_COLOR, _inline(trimmed.substr(3))])
		elif trimmed.begins_with("# "):
			out.append("[font_size=28][color=%s][b]%s[/b][/color][/font_size]" % [HEADING_COLOR, _inline(trimmed.substr(2))])
		elif trimmed.begins_with("> "):
			out.append("[indent][i][color=#c8b898]%s[/color][/i][/indent]" % _inline(trimmed.substr(2)))
		elif trimmed.begins_with("* ") or trimmed.begins_with("- "):
			out.append("   [color=%s]•[/color] %s" % [HEADING_COLOR, _inline(trimmed.substr(2))])
		else:
			out.append(_inline(line))
	return "\n".join(out)


static func _escape(text: String) -> String:
	return text.replace("[", "[lb]")


static func _inline(text: String) -> String:
	var parts := text.split("`")
	var out := ""
	for i in parts.size():
		if i % 2 == 1:
			out += "[code][color=%s]%s[/color][/code]" % [CODE_COLOR, _escape(parts[i])]
		else:
			out += _emphasis(_escape(parts[i]))
	return out


static func _emphasis(text: String) -> String:
	var bold := RegEx.create_from_string("\\*\\*(.+?)\\*\\*")
	text = bold.sub(text, "[b]$1[/b]", true)
	var italic := RegEx.create_from_string("\\*(.+?)\\*")
	return italic.sub(text, "[i]$1[/i]", true)
