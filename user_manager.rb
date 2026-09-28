class UserManager

  def initialize
    @users = {}
    @deleted_users = 0
  end

  def add_user(user)
    @users[user.user_id] = user
  end

  def all_users
    @users.values
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
    if @users.key?(user_id)
      @users.delete(user_id)
      @deleted_users += 1
      true
    else
      false
    end
  end

  def total_users
    @users.length
  end

  def total_deleted_users
    @deleted_users
  end

end
