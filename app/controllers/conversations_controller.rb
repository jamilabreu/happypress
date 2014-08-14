class ConversationsController < ApplicationController
  def index
    @feed = Conversation.feed.page(params[:page])
  	@conversation = @feed.first
  	@posts = @conversation.posts
  end

  def show
  	@conversation = Conversation.find(params[:id])
  end

  def create_post
  	@conversation = Conversation.find(params[:id])

  	mechanize = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
  	@page = mechanize.get(@conversation.url) do |page|
  	  # Click the login link
  	  @login_page = mechanize.click(page.link_with(text: /log in/))

  	  # Submit the login form
  	  @post_page = @login_page.form_with(action: 'https://wordpress.com/wp-login.php') do |f|
  	  	f.log = ENV["wordpress_username"]
  	  	f.pwd = ENV["wordpress_password"]
  	  end.click_button

  	  # Submit the post
  	  @submit_page = @post_page.form_with(action: 'http://en.forums.wordpress.com/bb-post.php') do |f|
  	  	f.post_content = params[:body]
  	  end.click_button

      # Subscribe to conversation
      @subscribe_page = mechanize.click(@submit_page.link_with(text: /Subscribe to Topic/))
  	end
  end
end
