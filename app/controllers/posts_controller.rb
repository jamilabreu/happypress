class PostsController < ApplicationController
	def leaderboard
		@by_posts = User.select("users.*, count(posts.id) AS posts_count").preload(:posts).joins(:posts).group("users.id").order("posts_count DESC").first(20)
		@by_conversations = User.all.sort_by { |user| user.conversations.length }.reverse.first(20)
		@by_ppc = User.select {|user| user.posts.length > 40}.sort_by { |user| user.ppc }.first(20)
	end

	def clip_support_page
		@url = params[:url]
	end

	def clip_tag
		@tag = params[:tag]
	end

	def search
		@conversation = Conversation.find(params[:id])
	end
end