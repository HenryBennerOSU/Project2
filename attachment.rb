#class to represent an attachment
class Attachment

  #create the getter and setter methods for each variable
  attr_accessor :attachmentId, :fileName, :fileType, :fileSize

  def initialize(attachmentId, fileName, fileType, fileSize)
    #needs to run before the object itself exists so you have to call it on the class.
    self.class.validate(fileName, fileType, fileSize)

    #initalize the instance variables
    @attachmentId = attachmentId
    @fileName = fileName
    @fileType = fileType
    @fileSize = fileSize
  end


  #checks to see if an input matches the filename
  def matchesFileName?(string)
    @fileName.downcase.include?(string.downcase)
  end

  #checks to see if fileName, fileType, and fileSize are not nim and not just whitespace and if they are, raise an error
  def self.validate(fileName, fileType, fileSize)
    raise ArgumentError, "File name is required" if fileName.nil? || fileName.strip.empty?
    raise ArgumentError, "File type is required" if fileType.nil? || fileType.strip.empty?
    raise ArgumentError, "File size must be greater than 0" unless fileSize.to_i > 0
  end

  #goes through all te attachments and see if any match the query input 
  def self.searchByFileName(allAttachments, string)
    allAttachments.select { |a| a.matchesFileName?(string) }
  end
end
