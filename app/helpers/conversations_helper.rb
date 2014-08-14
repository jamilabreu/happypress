module ConversationsHelper
	def item_class(conversation)
		string = ''
		string += 'active' if conversation == @conversation
		string += ' unanswered' if conversation.responses == 0
		string += ' he' if conversation.posts.map(&:user).include? User.find_by(username: "abreujamil")
		return string
	end

	def search_query(conversation)
		query = params[:q].present? ? params[:q] : conversation.title
		(query.downcase.parameterize.split("-") - Post::STOP_WORDS).join(" ").parameterize
	end
end
