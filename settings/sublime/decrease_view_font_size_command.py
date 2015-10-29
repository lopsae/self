import sublime
import sublime_plugin


class DecreaseViewFontSizeCommand(sublime_plugin.ApplicationCommand):
	def run(self):
		view_settings = sublime.active_window().active_view().settings()
		current_size = view_settings.get("font_size")
		if current_size > 1:
			view_settings.set("font_size", current_size-1)