
require 'tk'
require_relative "user_manager"
require_relative 'reports'

class ReportsGUI
	attr_accessor :user_manager
	def initialize(user_manager, root)
		@report = Report.new(user_manager)

		@root = TkToplevel.new(root) 
		@root.title = "Reports"
		@root.geometry = "400x400"
		@user_manager = user_manager	
		
		#command definitions
		export_reports = proc{export}
		disp_m_report = proc{master_report}
		disp_p_report = proc{post_report}
		disp_ud_report = proc{ud_report}

		#buttons to toggle displays (3) + export (1)
		buttons = TkFrame.new(@root)
		buttons.pack

		TkButton.new(buttons) do
			text "Master Report"
			command disp_m_report
			pack
		end
		TkButton.new(buttons) do
			text "Post Report"
			command disp_p_report
			pack
		end
		TkButton.new(buttons) do
			text "User Detail Report"
			command disp_ud_report
			pack
		end
		TkButton.new(buttons) do
			text "Export Reports"
			command export_reports
			pack
		end
		
		@table_disp = TkFrame.new(@root)
		@table_disp.pack
	end

	def add_row(values, widths, back, fore)
    		row = TkFrame.new(@table_disp)
    		row.pack(anchor: "w")
 
    		values.each_with_index do |value, i|
      		cell_width = widths[i]
 
      			TkLabel.new(row) do
        			text value.to_s
        			width cell_width
        			justify "left"
        			background back
        			foreground fore
        			padx 6
        			pady 6
				pack(side: "left")
      			end
    		end
  	end

	def master_report
		window = TkToplevel.new(@root)
		window.title = "Master Report"
		@table_disp = TkFrame.new(window)
		@table_disp.pack

		m_info = @report.master_info
		size = [10, 15, 20, 25, 15]
		
		add_row(["MASTER REPORT"], [90], "#342344", "#eeeeee")
		add_row(["Date: #{@report.today}", "Admin: Jane"], [45,45], "#666666", "#eeeeee")
		add_row(["User ID", "Username", "Email", "Address", "Number of Posts"], size, "#661111", "#eeeeee")
		
		m_info.each_with_index do |row,i|
			if i.even?
				add_row(row, size, "#eeeeee", "#342344")
			else
				add_row(row, size, "#cccccc", "#342344")
			end
		end
	end

	def post_report
		window = TkToplevel.new(@root)
		window.title = "Post Report"
		@table_disp = TkFrame.new(window)
		@table_disp.pack
		p_info = @report.post_report
		size = [10, 30, 20, 20, 6, 6]

		add_row(["POST REPORT"], [92], "#342344", "#eeeeee")
		add_row(["Post ID", "Title", "Created Date", "Updated Date","Attachments", "\#"],  size, "#669999", "#eeeeee")
 
		tot_attach = 0

		p_info.each_with_index do |row,i|
			if i.even?
				add_row(row, size, "#eeeeee", "#342344")
			else
				add_row(row, size, "#cccccc", "#342344")
			end
			tot_attach += row[4]
		end
		add_row(["total attachments: #{tot_attach.to_s}"], [92], "#eeeeee", "#342344")
	end

	def ud_report
		#window to get user id entry from user
		window = TkToplevel.new(@root)
		window.title = "User Detail Report UID"
		
		 TkLabel.new(window) do
      			text "Enter User ID:"
      			pack
    		  end
 
    		uid_entry = TkEntry.new(window)
    		uid_entry.pack
 		
		#can display report if entry is valid
		display_action = proc do
      			uid = uid_entry.get.to_i
      			user = @user_manager.find_by_id(uid)
      			if user.nil?
        			puts "User not found. Enter a valid User ID."
      			else
				box = TkToplevel.new(@root)
				box.title = "User Detail Report"
				@table_disp = TkFrame.new(box)
				@table_disp.pack

				rows = user.posts
    				size = [14, 30, 22, 22]
 
    				add_row(["USER DETAIL REPORT"], [90], "#342343", "#eeeeee")
    				add_row(["User ID", user.user_id, "Username", user.username], [14, 30, 14, 30], "#666666", "#111111")
    				add_row(["Email", user.email], [15, 75], "#666666", "#111111")
 
    				if user.address.nil?
      					add_row(["Address", "-"], [15, 75], "#666666", "#111111")
    				else
      					add_row(["Address", "Street: #{user.address.street}", "City: #{user.address.city}", "State: #{user.address.state}"], [10, 30, 20, 20], "#eeeeee", "#342343")
    				end
 
    				add_row(["Post ID", "Title", "Created Date", "Updated Date"], size, "#669999", "#eeeeee")
  				rows.each_with_index do |row,i|
					if i.even?
						add_row(row, size, "#eeeeee", "#342344")
					else
						add_row(row, size, "#cccccc", "#342344")
					end
				end
    			add_row(["Number of Posts: #{user.posts.size}"], [90], "#669999", "#eeeeee")
      			end
		end
		
		TkButton.new(window) do
			text "Show Report"
			command display_action
			pack
		end
  	end

	
	#can save report to txt files that the user chooses the path for
	def export
		#creates a text string of all info
		report_text = "MASTER REPORT\n"
		report_text += "Date: #{@report.today}\tAdmin:Jane\n"
		temp_row = ["User ID", "Username", "Email", "Address", "Number of Posts"]
		temp_row.each do |item|
			report_text += item.to_s
			report_text += "\t"
		end
		report_text += "\n"
		@report.master_info.each do |row|
			row.each do |item|
				report_text += item.to_s 
				report_text += "\t"
			end
			report_text += "\n"
		end

		report_text += "\nPOST REPORT\n"
		total_attach = 0
		temp_row = ["Post ID", "Title", "Created Date", "Updated Date", "Attachments", "#"]
		temp_row.each do |item|
			report_text += item.to_s
			report_text += "\t"
		end
		report_text += "\n"
		@report.post_report.each do |row|
			i = 0
			row.each do |item|
				report_text += item.to_s 
				report_text += "\t"
				if i == 4
					total_attach += item
				end
				i += 1
			end
			report_text += "\n"
		end
		report_text += "Total Number of Attachments: #{total_attach}\n"

		report_text += "USER DETAIL REPORT\n"
		@user_manager.all_users.each do |user|
			temp_row = ["User ID", user.user_id.to_s, "Username", user.username]
			temp_row.each do |item|
				report_text += item.to_s
				report_text += "\t"
			end
			report_text += "\n"
			if user.address.nil?
				temp_row = ["Address", "-"]
			else
				temp_row = ["Address", "Street: #{user.address.street}", "City: #{user.address.city}","Satte: #{user.address.state}"]
			end
			temp_row.each do |item|
				report_text += item.to_s
				report_text += "\t"
			end
			report_text += "\n"
			temp_row = ["Post ID", "Title", "Created Date", "Updated Date"]
			temp_row.each do |item|
				report_text += item.to_s
				report_text += "\t"
			end
			report_text += "\n"
			user.posts.each do |post|
				temp_row = [post.postId.to_s, post.title, post.createdAt.strftime("%m/$d/%y"), post.updatedAt.strftime("%m/$d/%y")]
				temp_row.each do |item|
				report_text += item.to_s
				report_text += "\t"
				end
				report_text += "\n"
			end
			report_text += "Number of Posts: #{user.posts.size}\n"
		end

		#user inputs path and filename
		box = TkToplevel.new(@root)
		box.title = "Export"
		TkLabel.new(box) do 
			text "File Path"
			pack
		end
		path_entry = TkEntry.new(box)
		path_entry.pack
		TkLabel.new(box) do
			text "Filename"
			pack
		end
		filename_entry = TkEntry.new(box)
		filename_entry.pack

		save_action = proc do
			path = path_entry.get
			filename = filename_entry.get
			if path.nil?
				puts "Path was not found"
			else 
				File.open(File.join(path, "#{filename}.txt"), "w") do |file|
					file.puts report_text
				end
			puts "Report saved to file!"
			box.destroy
			end
		end

		TkButton.new(box) do
			text "Save Here"
			command save_action
			pack
		end
	end
end
