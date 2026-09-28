gem 'tk', '0.5.1'
require 'tk'
require_relative 'reports'

class ReportsGUI
	def initialize
		@report = Report.new
		@report_text = ""

		@root = TkRoot.new do
			title = "Reports"
			geometry = "800x500"
		end
		
		#command definitions
		export_reports = proc{export(@report_text)}
		disp_m_report = proc{master_report}
		disp_p_report = proc{post_report}
		disp_ud_report = proc{ud_report}

		#buttons to toggle displays (3) + export (1)
		TkButton.new(@root) do
			text "Master Report"
			command disp_m_report
			pack
		end
		TkButton.new(@root) do
			text "Post Report"
			command disp_p_report
			pack
		end
		TkButton.new(@root) do
			text "User Detail Report"
			command disp_ud_report
			pack
		end
		TkButton.new(@root) do
			text "Export Reports"
			command export_reports
			pack
		end
	end

	def master_report
		clear_content
		m_info.each do |row|
			add_row row
		end	
	end

	def post_report
		clear_content
		
	end

	def ud_report
	end

		#can save report to txt files that the user chooses the path for
	def export
		#creates a text string of all info
		@report_text += "MASTER REPORT\n"
		m_info.each do |row|
			row.each do |item|
				@report_text += item 
				@report_text += "\t"
			end
			@report_text += "\n"
		end

		#user inputs path and filename
		TkLabel.new(@root) do 
			text "File Path"
			pack
		end
		path = TkEntry.new(@root)
		path.pack
		TKLabel.new(@root) do
			text "Filename"
			pack
		end
		filename = TkEntry.new(@root)
		filename.pack

		if path.nil? || path.empty?
			puts "Path was not found"
			return
		else 
			File.write(path, @report_text)
		end
		puts "Report saved to file!"
	end
