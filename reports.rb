require "date"
require_relative "user_manager"

class  Report

	def initialize(user_manager)
		@user_manager = user_manager
	end
	
	def today 
		Date.today.strftime("%A, %B %-d, %Y")
	end

	def master_info
		#array of arrays that contain info abt each user
		m_info = []
		@user_manager.all_users.each do |user|
			if user.address.nil?
				address = "-"
			else
				address = user.address.get_full_address
			end
			m_info<<[user.user_id, user.username, user.email, address, user.posts.size]
		end
		m_info
	end

	def user_detail(uid)
		user = @user_manager.find_by_id(uid)
		
		info_array = []

		#userid, username, email, address (street, city, state)
		user_info = [user.user_id, user.username, user.email, address]
		info_array<<user_info
		user.posts.each do |post|
			info_array<<[post.postId, post.title, post.createdAt, post.updatedAt]
		end
		info_array
	end

	def post_report
		post_info = []
		@user_manager.all_users.each do |user|
			user.posts.each do |post|
				filelist = ""
				post.attachments.each do |attachment|
					filelist += attachment.fileName
					filelist += "\n"
				end
				post_info << [post.postId, post.title, post.createdAt, post.updatedAt, filelist, post.attachments.size]
			end
		end
		post_info
	end

end
