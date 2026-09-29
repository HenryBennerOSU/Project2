class UserManager

  def initialize
    @users = {}
  end

  def add_user(user)
    @users[user.user_id] = user
  end

  def all_users
    @users.values
  end

  def active_users
    @users.values.reject(&:deleted?)
  end

  def deleted_users
    @users.values.select(&:deleted?)
  end

  def find_by_id(user_id)
    @users[user_id]
  end

  def find_by_username(username)
    @users.values.select do |user|
      user.username.downcase == username.downcase
    end
  end

  def find_by_email(email)
    @users.values.select do |user|
      user.email.downcase == email.downcase
    end
  end

  def delete_user(user_id)
    user = @users[user_id]

    if user && !user.deleted?
      user.delete_account
      true
    else
      false
    end
  end

  def total_users
    @users.length
  end

  def total_active_users
    active_users.length
  end

  def total_deleted_users
    deleted_users.length
  end

end
