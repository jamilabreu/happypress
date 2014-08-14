class Conversation < ActiveRecord::Base
	require 'open-uri'
	paginates_per 25

	has_many :posts, -> { order :created_at }, dependent: :destroy

	scope :feed, -> { joins(:posts).where("posts.created_at IN (SELECT MAX(posts.created_at) FROM posts WHERE posts.conversation_id = conversations.id)").order("posts.created_at DESC") }

	def responses
		user = posts.try(:first).try(:user)
		user ? posts.where.not(user: user).length : 0
	end

	def support_pages(q)
		search_url = "http://en.support.wordpress.com/?s=" + q
    return Nokogiri::HTML(open(search_url)).search("ul.dates > li").first(4)
	end

	def forum_pages(q)
		search_url = "http://en.forums.wordpress.com/search.php?q=" + q
    return Nokogiri::HTML(open(search_url)).search("ol.results > li").first(4)
	end
end
