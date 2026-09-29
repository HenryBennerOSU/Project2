require "tk"
require_relative "address"
require_relative "user"
require_relative "admin_gui"
require_relative "post"
require_relative "attachment"
require_relative "user_manager"
require_relative "reports"
require_relative "reports_gui"
require_relative "user_gui.rb"

user_manager = UserManager.new

user_gui = UserGUI.new(user_manager)

admin_gui = AdminGUI.new(user_manager, user_gui.root)

Tk.mainloop
