#gem 'tk', '0.5.1'
require 'tk'
require_relative 'user'
require_relative 'address'
require_relative 'post_gui'
require_relative "user_manager"

class UserGUI
	attr_accessor :root
  def initialize(user_manager)
	  @user = nil
	  @user_manager = user_manager

    @root = TkRoot.new do
      title "UserHub"
      geometry "500x500"
    end

    TkLabel.new(@root) do
      text "UserHub"
      pack
    end

    register_action = proc { registration_window }
    login_action = proc { login_window }
    profile_action = proc { profile_window }
    address_action = proc { address_window }
    logout_action = proc { logout_user }
    delete_action = proc { delete_user }
    posts_action = proc { posts_window }

    TkButton.new(@root) do
      text "Register"
      command register_action
      pack
    end

    TkButton.new(@root) do
      text "Login"
      command login_action
      pack
    end

    TkButton.new(@root) do
      text "Post"
      command posts_action
      pack
    end

    TkButton.new(@root) do
      text "Edit Profile"
      command profile_action
      pack
    end

    TkButton.new(@root) do
      text "Edit Address"
      command address_action
      pack
    end

    TkButton.new(@root) do
      text "Logout"
      command logout_action
      pack
    end

    TkButton.new(@root) do
      text "Delete Account"
      command delete_action
      pack
    end
  end

  def registration_window
    window = TkToplevel.new(@root)
    window.title = "Register"

    TkLabel.new(window) do
      text "Username"
      pack
    end

    username_entry = TkEntry.new(window)
    username_entry.pack

    TkLabel.new(window) do
      text "Email"
      pack
    end

    email_entry = TkEntry.new(window)
    email_entry.pack

    TkLabel.new(window) do
      text "Password"
      pack
    end

    password_entry = TkEntry.new(window)
    password_entry.pack

    TkLabel.new(window) do
      text "Profile Picture Path"
      pack
    end

    picture_entry = TkEntry.new(window)
    picture_entry.pack

    create_action = proc do
      new_user = User.new(
        username_entry.get,
        email_entry.get,
        password_entry.get
      )

      if new_user.valid?
        new_user.profile_picture = picture_entry.get
        @user = new_user

        puts "Account created."
        puts "User ID: #{@user.user_id}"
        puts "Username: #{@user.username}"
	
	#also adds new user to user management array of users
	@user_manager.add_user(new_user)

        window.destroy
      else
        puts "Invalid registration."
        puts "Username must have at least 3 characters."
        puts "Email must be valid."
        puts "Password must have at least 6 characters."
      end
    end

    TkButton.new(window) do
      text "Create Account"
      command create_action
      pack
    end
  end

  def login_window
    if @user.nil?
      puts "Create an account first."
      return
    end

    window = TkToplevel.new(@root)
    window.title = "Login"

    TkLabel.new(window) do
      text "Email"
      pack
    end

    email_entry = TkEntry.new(window)
    email_entry.pack

    TkLabel.new(window) do
      text "Password"
      pack
    end

    password_entry = TkEntry.new(window)
    password_entry.pack

    login_action = proc do
      if @user.login(email_entry.get, password_entry.get)
        puts "Login successful."
        window.destroy
      else
        puts "Invalid email or password."
      end
    end

    TkButton.new(window) do
      text "Login"
      command login_action
      pack
    end
  end

  def profile_window
    if @user.nil?
      puts "Create an account first."
      return
    end

    window = TkToplevel.new(@root)
    window.title = "User Profile"

    TkLabel.new(window) do
      text "Username"
      pack
    end

    username_entry = TkEntry.new(window)
    username_entry.insert(0, @user.username)
    username_entry.pack

    TkLabel.new(window) do
      text "Email"
      pack
    end

    email_entry = TkEntry.new(window)
    email_entry.insert(0, @user.email)
    email_entry.pack

    TkLabel.new(window) do
      text "Profile Picture Path"
      pack
    end

    picture_entry = TkEntry.new(window)
    picture_entry.insert(0, @user.profile_picture)
    picture_entry.pack

    save_action = proc do
      old_username = @user.username
      old_email = @user.email

      @user.update_profile(
        username_entry.get,
        email_entry.get
      )

      if @user.valid_username? && @user.valid_email?
        @user.profile_picture = picture_entry.get
        puts "Profile updated."
        window.destroy
      else
        @user.update_profile(old_username, old_email)
        puts "Invalid username or email."
      end
    end

    TkButton.new(window) do
      text "Save Profile"
      command save_action
      pack
    end
  end

  def address_window
    if @user.nil?
      puts "Create an account first."
      return
    end

    window = TkToplevel.new(@root)
    window.title = "Address"

    TkLabel.new(window) do
      text "Street"
      pack
    end

    street_entry = TkEntry.new(window)
    street_entry.pack

    TkLabel.new(window) do
      text "City"
      pack
    end

    city_entry = TkEntry.new(window)
    city_entry.pack

    TkLabel.new(window) do
      text "State"
      pack
    end

    state_entry = TkEntry.new(window)
    state_entry.pack

    TkLabel.new(window) do
      text "Zip Code"
      pack
    end

    zip_entry = TkEntry.new(window)
    zip_entry.pack

    save_address_action = proc do
      address = Address.new(
        street_entry.get,
        city_entry.get,
        state_entry.get,
        zip_entry.get
      )

      if address.valid?
        @user.set_address(address)
        puts "Address saved."
        puts @user.address.get_full_address
        window.destroy
      else
        puts "All address fields are required."
      end
    end

    TkButton.new(window) do
      text "Save Address"
      command save_address_action
      pack
    end
  end

  def logout_user
    if @user.nil?
      puts "No user exists."
    else
      @user.logout
      puts "Logged out."
    end
  end

  def delete_user
    if @user.nil?
      puts "No user exists."
    else
      @user.delete_account
      puts "Account marked for deletion."
    end
  end

  def run
    Tk.mainloop
  end
end

def posts_window
  if @user.nil?
    puts "Create an account first."
    return
  end

  unless @user.logged_in?
    puts "Login first."
    return
  end

  window = TkToplevel.new(@root)
  window.title = "Posts"
  window.geometry("500x400")

  PostGUI.new(window, @user)
end

#UserGUI.new.run
