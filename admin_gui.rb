require 'tk'
require_relative 'user_manager'

class AdminGUI

  def initialize(user_manager)
    @user_manager = user_manager

    @root = TkRoot.new
    @root.title = "UserHub - Administrator Dashboard"
    @root.geometry("600x500")

    create_dashboard
  end

  def create_dashboard
    gui = self

    TkLabel.new(@root) do
      text "Administrator Dashboard"
      font "Arial 20 bold"
      pack(pady: 20)
    end

    @stats_label = TkLabel.new(
      @root,
      "text" => statistics_text,
      "font" => "Arial 12"
    )

    @stats_label.pack("pady" => 10)

    TkButton.new(@root) do
      text "Manage Users"
      width 25
      command proc { gui.show_users }
      pack(pady: 5)
    end

    TkButton.new(@root) do
      text "Search Users"
      width 25
      command proc { gui.search_users }
      pack(pady: 5)
    end

    TkButton.new(@root) do
      text "Delete User"
      width 25
      command proc { gui.delete_user }
      pack(pady: 5)
    end

    TkButton.new(@root) do
      text "Refresh Dashboard"
      width 25
      command proc { gui.refresh_dashboard }
      pack(pady: 5)
    end

    TkButton.new(@root) do
      text "Logout"
      width 25
      command proc { gui.logout }
      pack(pady: 20)
    end
  end

  def statistics_text
    "Total Users: #{@user_manager.total_users}\n" \
    "Active Users: #{@user_manager.total_active_users}\n" \
    "Deleted Accounts: #{@user_manager.total_deleted_users}"
  end

  def refresh_dashboard
    @stats_label.text = statistics_text
  end

  def show_users
    gui = self

    window = TkToplevel.new(@root)
    window.title = "Manage Users"
    window.geometry("700x400")

    TkLabel.new(window) do
      text "All Users"
      font "Arial 16 bold"
      pack(pady: 10)
    end

    users = @user_manager.all_users

    if users.empty?
      TkLabel.new(window) do
        text "No users registered."
        pack(pady: 20)
      end
      return
    end

    users.each do |user|
      status = user.deleted? ? "Deleted" : "Active"

      TkLabel.new(window) do
        text "ID: #{user.user_id} | Username: #{user.username} | Email: #{user.email} | Status: #{status}"
        pack(pady: 3)
      end
    end
  end

  def search_users
    gui = self

    window = TkToplevel.new(@root)
    window.title = "Search Users"
    window.geometry("600x500")

    TkLabel.new(window) do
      text "Search Users"
      font "Arial 16 bold"
      pack(pady: 10)
    end

    TkLabel.new(window) do
      text "Enter search value:"
      pack(pady: 5)
    end

    search_entry = TkEntry.new(window) do
      width 40
      pack(pady: 5)
    end

    TkButton.new(window) do
      text "Search by User ID"
      command proc {
        user_id = search_entry.get.to_i
        results = gui.user_manager_find_by_id(user_id)
        gui.display_search_results(window, results)
      }
      pack(pady: 5)
    end

    TkButton.new(window) do
      text "Search by Username"
      command proc {
        results = gui.user_manager_find_by_username(search_entry.get)
        gui.display_search_results(window, results)
      }
      pack(pady: 5)
    end

    TkButton.new(window) do
      text "Search by Email"
      command proc {
        results = gui.user_manager_find_by_email(search_entry.get)
        gui.display_search_results(window, results)
      }
      pack(pady: 5)
    end
  end

  def user_manager_find_by_id(user_id)
    @user_manager.find_by_id(user_id)
  end

  def user_manager_find_by_username(username)
    @user_manager.find_by_username(username)
  end

  def user_manager_find_by_email(email)
    @user_manager.find_by_email(email)
  end

  def display_search_results(window, results)
    results = [results] unless results.is_a?(Array)

    if results.empty? || results.first.nil?
      TkLabel.new(window) do
        text "No users found."
        pack(pady: 10)
      end
      return
    end

    TkLabel.new(window) do
      text "Search Results:"
      font "Arial 12 bold"
      pack(pady: 10)
    end

    results.each do |user|
      status = user.deleted? ? "Deleted" : "Active"

      TkLabel.new(window) do
        text "ID: #{user.user_id} | Username: #{user.username} | Email: #{user.email} | Status: #{status}"
        pack(pady: 3)
      end
    end
  end

  def delete_user
    gui = self

    window = TkToplevel.new(@root)
    window.title = "Delete User"
    window.geometry("400x250")

    TkLabel.new(window) do
      text "Delete User"
      font "Arial 16 bold"
      pack(pady: 15)
    end

    TkLabel.new(window) do
      text "Enter User ID:"
      pack(pady: 5)
    end

    id_entry = TkEntry.new(window) do
      width 20
      pack(pady: 5)
    end

    TkButton.new(window) do
      text "Delete"
      command proc {
        user_id = id_entry.get.to_i
        success = gui.delete_user_from_manager(user_id)

        if success
          Tk.messageBox(
            "type" => "ok",
            "title" => "Success",
            "message" => "User #{user_id} was deleted."
          )

          gui.refresh_dashboard
          window.destroy
        else
          Tk.messageBox(
            "type" => "ok",
            "title" => "Error",
            "message" => "User #{user_id} was not found or is already deleted."
          )
        end
      }
      pack(pady: 15)
    end
  end

  def delete_user_from_manager(user_id)
    @user_manager.delete_user(user_id)
  end

  def logout
    @root.destroy
  end

end
