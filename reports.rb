require "date"
require_relative "UserManager"

module Report
	#text version to export to txt file
	report_text = ""

	def master_info
		report_text = "MASTER REPORT\n"
		#array of arrays that contain info abt each user
		m_info = [["User ID", "Username", "Email", "Address", "Number of Posts"]]
		User.get_all_users.each do |user|
			m_info<<[user.user_id, user.username, user.email, user.address, user.posts.size]
		end
		m_info
	end

	def user_detail(uid)
		user = User.get_user(uid)
		
		info_array = []

		#userid, username, email, address (street, city, state)
		user_info = [user.user_id, user.username, user.email, user.address]
		info_array<<user_info
		user.posts.each do |post|
			info_array<<[post_id, title, created_at, updated_at]
		end
		info_array
	end

	def post_report
		post_info = []
		User.gte_all_users.each do |user|
			user.posts.each do |post|
				post_info << [post.post_id, post.title, post.created_at, post.updated_at, po# ATTACHMENTS #ATTACHMENT NUMBER]
			end
		end
		post_info
	end

end
