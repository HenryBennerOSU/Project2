#gives post_gui.rb access to other files
require 'tk'
require_relative 'post'
require_relative 'attachment'

class PostGUI

  #initialize constructor
  def initialize(parent, currentUser)
    @parent = parent
    @user = currentUser

    #calls the method that builds the initial screen
    buildPostListScreen
  end

  def buildPostListScreen
    #Copy the instance variables into local variables as it was giving me issues without it
    user = @user
    gui = self

    #creates the frame of the window the .pack method makes it visible
    @frame = TkFrame.new(@parent)
    @frame.pack

    #Create a text label, have it display the number of user posts, and then make it visible
    label = TkLabel.new(@frame)
    label.text = "Your Posts (#{user.posts.size})"
    label.pack

    #Creates a list box that is scrollable and then have it stretch and fill the space of the window.
    @listbox = TkListbox.new(@frame)
    @listbox.pack('fill' => 'both', 'expand' => true)
    #calls the refresh post list which puts the users posts in the box.
    refreshPostList

    newPostBtn = TkButton.new(@frame)
    newPostBtn.text = 'New Post'
    newPostBtn.command = proc { gui.openPostForm }
    newPostBtn.pack('side' => 'left')

    #creates a new button,
    editBtn = TkButton.new(@frame)
    editBtn.text = 'Edit Selected'
    editBtn.command = proc { gui.editSelectedPost }
    editBtn.pack('side' => 'left')

    #creates a new button, call it the delete button, define what happens when it is clicked, then place it in the window
    deleteBtn = TkButton.new(@frame)
    deleteBtn.text = 'Delete Selected'
    deleteBtn.command = proc { gui.deleteSelectedPost }
    deleteBtn.pack('side' => 'left')

    #creates a new button, call it the view attachments button, define what happens when it's clicked, then place it in the window
    viewAttachBtn = TkButton.new(@frame)
    viewAttachBtn.text = 'View Attachments'
    viewAttachBtn.command = proc { gui.viewSelectedAttachments }
    viewAttachBtn.pack('side' => 'left')
  end

  #Method that gets called when something changes in the GUI
  def refreshPostList
    #clears the entire box and all items
    @listbox.delete(0, 'end')

    #loop through every post the user has, then add a new line which says the postId, title, and attachment count
    @user.posts.each { |p| @listbox.insert('end', "#{p.postId}: #{p.title} (#{p.attachment_count} files)") }
  end


  #Used for buttons that need to know which exact post was clicked
  def selectedPost
    #returns the index of the line the user clicked on, then stores it as an array
    index = @listbox.curselection.first
    
    #if the user didn't click anything, return nil so that the program doesn't crash
    return nil unless index

    #uses the index to get the actual post 
    @user.posts[index]
  end

  #function which can both edit and create a post since they use similar logic
  def openPostForm(post = nil)
    #again, copy the values into local variables
    gui = self
    existingPost = post

    #creates a whole new pop up window
    form = TkToplevel.new

    #if existingPost is true, then you need to edit the post. If it is not, then create a new post
    if existingPost
      form.title("Edit Post")
    else
      form.title("New Post")
    end

    #Creates the title label
    titleLabel = TkLabel.new(form)
    titleLabel.text = 'Title:'
    titleLabel.pack

    #creates the text box and fills it with the existing post if it exists
    titleEntry = TkEntry.new(form)
    titleEntry.pack
    titleEntry.value = existingPost.title if existingPost

    #creates the content label
    contentLabel = TkLabel.new(form)
    contentLabel.text = 'Content:'
    contentLabel.pack

    #creates the text box and fils it with the existing post if it exists
    contentBox = TkText.new(form, 'height' => 5)
    contentBox.pack
    contentBox.value = existingPost.content if existingPost

    #Creates the save button
    saveBtn = TkButton.new(form)
    saveBtn.text = 'Save'

    #defines what happens when it is clicked.
    saveBtn.command = proc {
      #when it is clicked, it calls savePost passing in what the user typed plus the existing post if it exists
      #Need to use begin, rescue bc you don't wan't it to crash if it fails
      begin
        gui.savePost(titleEntry.value, contentBox.value, existingPost)
        #closes the pop up window only if savingPost method worked correctly
        form.destroy
      rescue ArgumentError => e
        gui.showValidationError(e.message)
      end
    }
    saveBtn.pack
  end

  #The method which actually creates or updates the post object
  def savePost(title, content, existingPost = nil)
    #checks if there is an existing and if so, calls update_post
    if existingPost
      existingPost.update_post(newTitle: title, newContent: content)
    else
      #if there isn't a post, puts all the postId's into an array, find the highest one if there are posts, and then just adds 1
      newId = (@user.posts.map(&:postId).max || 0) + 1
      #appends it into the user.posts array
      @user.posts << Post.new(newId, @user.user_id, title, content)
    end
    #refresh the post list so it actually shows the changes!
    refreshPostList
  end

  #Edits a selected post
  def editSelectedPost
    #gets the selected post and then calls openPostForm
    post = selectedPost
    openPostForm(post) if post
  end

  #Deletes a selected post
  def deleteSelectedPost
    #gets the sleected post
    post = selectedPost
    #returns from the function unless post exists
    return unless post
    #deletes the post from the array then updates the post list to reflect the changes
    @user.posts.delete(post)
    refreshPostList
  end

  #Gets the selected posts' attachment
  def viewSelectedAttachments
    #gets the post which the user selected, then builds the attachment screen if the post exists
    post = selectedPost
    buildAttachmentScreen(post) if post
  end

  #Opens a new popup window for the attachments
  def buildAttachmentScreen(post)
    #copy variables into local variables
    gui = self
    currentPost = post

    #create a brand new window and name it based on the current posts' title
    win = TkToplevel.new
    win.title("Attachments for: #{currentPost.title}")

    #create a scrollable list inside the box, have it stretch to fill the entire window depending on the size,
    #then put whatever attachments the post already has inside the box
    attachList = TkListbox.new(win)
    attachList.pack('fill' => 'both', 'expand' => true)
    gui.refreshAttachmentList(currentPost, attachList)

    #create a new label called File Name then an entry box for the user to type their answer
    nameLabel = TkLabel.new(win)
    nameLabel.text = 'File Name:'
    nameLabel.pack
    nameEntry = TkEntry.new(win)
    nameEntry.pack

    #create a label for entry box for the user to type their answer
    typeLabel = TkLabel.new(win)
    typeLabel.text = 'File Type:'
    typeLabel.pack
    typeEntry = TkEntry.new(win)
    typeEntry.pack

    #Creates a label and then a entry box for the user to type their answer
    sizeLabel = TkLabel.new(win)
    sizeLabel.text = 'File Size (bytes):'
    sizeLabel.pack
    sizeEntry = TkEntry.new(win)
    sizeEntry.pack

    #create a new button called Add attachment
    addBtn = TkButton.new(win)
    addBtn.text = 'Add Attachment'

    #defines what happens when the button is clicked
    addBtn.command = proc {
      #use a begin/rescue so that the program doesn't crash if it fails.
      begin
        #passes arguments into the method which buils a new attachment and adds it to the post object.
        gui.addAttachmentToPost(currentPost, nameEntry.value, typeEntry.value, sizeEntry.value)
        #refreshes the list so that the new attachment shows up
        gui.refreshAttachmentList(currentPost, attachList)
      rescue ArgumentError => e #catches the error if the input doesn't work
        gui.showValidationError(e.message)
      rescue RuntimeError => e #catches the error when someone tries to add more than 5 posts.
        gui.showValidationError(e.message)
      end
    }
    addBtn.pack

    #creates a new button called "Remove selected"
    removeBtn = TkButton.new(win)
    removeBtn.text = 'Remove Selected'

    #defines what happens when you click the button
    removeBtn.command = proc {
      #checks which attachment is selected and nil if none are selected
      index = attachList.curselection.first

      #if the index exists, gives the id to the actual removal methods, then refreshes the list to show the updated changes
      if index
        attachmentId = currentPost.attachments[index].attachmentId
        gui.removeAttachmentFromPost(currentPost, attachmentId)
        gui.refreshAttachmentList(currentPost, attachList)
      end
    }
    removeBtn.pack
  end

  #Clears and re-adds the attachment listbox. Similar to refreshPostList
  def refreshAttachmentList(post, listbox)
    listbox.delete(0, 'end')
    post.attachments.each { |a| listbox.insert('end', "#{a.fileName} (#{a.fileType}, #{a.fileSize} bytes)") }
  end

  #
  def addAttachmentToPost(post, fileName, fileType, fileSize)
    #Searches through every attachment and adds 1 to the highest one
    newId = (post.attachments.map(&:attachmentId).max || 0) + 1
    #creates a new attachment based on the given information
    attachment = Attachment.new(newId, fileName, fileType, fileSize)
    #actualyl stores it
    post.add_attachment(attachment)
  end

  #gives the post and attachmentId to the remove_attachment post
  def removeAttachmentFromPost(post, attachmentId)
    post.remove_attachment(attachmentId)
  end

  #Opens a window which shows the actual error message received when something fails or crashes
  def showValidationError(message)
    #gets the message and stores it in a local variable
    errorMessage = message

    #creates the new window called Validation Error
    errorWindow = TkToplevel.new
    errorWindow.title("Validation Error")

    #creates a new label from errorWindow and puts the text in it. Also pad the sides so it doesn't appeared cramped
    errorLabel = TkLabel.new(errorWindow)
    errorLabel.text = errorMessage
    errorLabel.pack('padx' => 20, 'pady' => 20)

    #Create a new button called OK and when clicked, it gets rid of the pop up window.
    okBtn = TkButton.new(errorWindow)
    okBtn.text = 'OK'
    okBtn.command = proc { errorWindow.destroy }
    okBtn.pack
  end
end
