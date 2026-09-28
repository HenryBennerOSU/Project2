class Post

  attr_accessor :postId, :userId,  :title, :content, :createdAt, :updatedAt
  attr_reader :attachments

  MAX_ATTACHMENTS = 5
  
  def initialize(postId, userId, title, content)
    #check to see if title and content are valid
    self.class.validate_title(title)
    self.class.validate_content(content)

    #initialize variables 
    @postId = postId
    @userId = userId
    @title = title
    @content = content
    @createdAt = Time.now
    @updatedAt = Time.now
    @attachments = []
  end

    # Updates title and/or content and only changes variables for fields that are passed in.
  def update_post(newTitle: nil, newContent: nil)

    #validates newTitle and/or newContent only if they are not nil
    self.class.validate_title(newTitle) if newTitle
    self.class.validate_content(newContent) if newContent

    #Sets title and content to the new ones if they are not nil
    @title = newTitle if newTitle
    @content = newContent if newContent

    #sets the time to right now
    @updatedAt = Time.now
  end

  
  #Adds the attachment to @attachments as long as the max number has not been reached
  def add_attachment(attachment)
    #check if attachments is >= to the max number allowed and if not, add it to the array
    if @attachments.size >= MAX_ATTACHMENTS
      raise "ERROR: Maximum number of attachments reached"
    else
      @attachments << attachment
      true
    end
  end


  #removes an attachment supplied by the user
  def remove_attachment(attachmentId)
    #goes through the array and if the id matches the one given, remove it from the array.
    @attachments.reject! { |a| a.attachmentId == attachmentId }
  end
  

  #returns the number of attachments in the array currently
  def attachment_count
    @attachments.size
  end


  #converts both to lowercase so that case sensitivity doesn't matter.
  #.include? method searches if the query is in the title regardless of other words.
  def matches_title?(query)
    @title.downcase.include?(query.downcase)
  end

  
  #checks if the title variable is empty or if it's just whitespace and if so, throws an error
  def self.validate_title(title)
    if title.nil? || title.strip.empty?
      raise ArgumentError, "ERROR: Title for post is required"
    end
  end


  #checks if the content variable is empty or if it's just whitespace and if so, throws an error
  def self.validate_content(content)
    if content.nil? || content.strip.empty?
      raise ArgumentError, "ERROR: content for post is required"
    end
  end


  #loops through every post and if the title matches, put the post in a new array and return it
  def self.search_by_title(posts, query)
    posts.select { |p| p.matches_title?(query) }
  end

  #goes through each post and adds the number of attachments they all have
  def self.total_attachments(posts)
    posts.sum { |p| p.attachment_count }
  end


  #function that sorts the posts by date then returns the most recent 5 posts.
  def self.recently_created(posts, limit = 5)
    #goes through each post and puts it in a new array by which one was posted latest.
    sorted_posts = posts.sort_by { |post| post.createdAt }
    #Reverses the array since it would have the oldest one first
    newest_first = sorted_posts.reverse
    #returns the first 5 posts in the array which are the most recent ones
    newest_first.first(limit)
  end
end
