import sublime
import sublime_plugin


class ResetViewFontSizeCommand(sublime_plugin.ApplicationCommand):
	def run(self):
		user_settings = sublime.load_settings('Preferences.sublime-settings')
		view_settings = sublime.active_window().active_view().settings()

		default_size = user_settings.get('font_size')
		view_settings.set('font_size', default_size)