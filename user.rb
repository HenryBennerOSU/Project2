require 'openssl'
require 'securerandom'
require_relative 'address'

class User
  @@next_user_id = 1

  attr_reader :user_id, :posts
  attr_accessor :username, :email, :address, :profile_picture

  def initialize(username, email, password)
    @user_id = @@next_user_id
    @@next_user_id += 1

    @username = username
    @email = email

    @password_valid = password.length >= 6

    @salt = SecureRandom.hex(16)
    @password = hash_password(password)

    @address = nil
    @profile_picture = ""
    @posts = []

    @logged_in = false
    @deleted = false
  end

  def valid_username?
    @username.length >= 3
  end

  def valid_email?
    /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/ === @email
  end

  def valid_password?
    @password_valid
  end

  def valid?
    valid_username? &&
      valid_email? &&
      valid_password?
  end

  def login(email, password)
    entered_password = hash_password(password)

    if @email == email &&
       @password == entered_password &&
       !@deleted

      @logged_in = true
      true
    else
      false
    end
  end

  def logout
    @logged_in = false
  end

  def logged_in?
    @logged_in
  end

  def update_profile(username, email)
    @username = username
    @email = email
  end

  def update_password(password)
    if password.length < 6
      return false
    end

    @salt = SecureRandom.hex(16)
    @password = hash_password(password)
    @password_valid = true

    true
  end

  def set_address(address)
    @address = address
  end

  def delete_account
    @deleted = true
    @logged_in = false
  end

  def deleted?
    @deleted
  end

  def create_post(post)
    @posts << post
  end

  def update_post(post)
    index = @posts.index do |current_post|
      current_post.post_id == post.post_id
    end

    @posts[index] = post unless index.nil?
  end

  def delete_post(post_id)
    @posts.reject! do |post|
      post.post_id == post_id
    end
  end

  def total_posts
    @posts.length
  end

  private

  def hash_password(password)
    OpenSSL::PKCS5.pbkdf2_hmac(
      password,
      @salt,
      100_000,
      32,
      "sha256"
    ).unpack1("H*")
  end
end
