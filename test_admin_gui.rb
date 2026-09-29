require_relative "user"
require_relative "user_manager"
require_relative "admin_gui"

manager = UserManager.new

user1 = User.new(
  "john_smith",
  "john@email.com",
  "password123"
)

user2 = User.new(
  "sara_ali",
  "sara@email.com",
  "password456"
)

user3 = User.new(
  "mike2026",
  "mike@email.com",
  "password789"
)

manager.add_user(user1)
manager.add_user(user2)
manager.add_user(user3)

AdminGUI.new(manager)

Tk.mainloop
