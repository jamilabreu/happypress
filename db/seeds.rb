require 'open-uri'

catch :done do
	5000.downto(1).each do |number|
		puts number
		forum_url = "http://en.forums.wordpress.com/"
		forum_url += "page/#{number}" unless number == 1

		page = Nokogiri::HTML(open(forum_url))
		page.search("tbody#latest tr").reverse_each do |row|
			conversation_title = row.search("td[1] a").text
			conversation_url = row.search("td[1] a @href").to_s
			conversation_count = row.search("td[2]").text.to_i
			conversation = Conversation.find_or_create_by(url: conversation_url) do |f|
				f.title = conversation_title
			end

			if conversation.posts.length == conversation_count
				throw :done
			else
				begin
					post_page = Nokogiri::HTML(open(conversation_url))
					post_page.search("ol#thread/li").each_with_index do |post, index|
						post_element_id = post.search("@id").to_s
						post_entry_id = post_element_id.split("-")[1].to_i
						post_url = index == 0 ? conversation_url : conversation_url + "?replies##{post_element_id}"
						post_created_at = Chronic.parse(post.search(".threadauthor time @datetime").to_s)
						post_body = post.search(".post").to_s
						user_image = post.search(".threadauthor img @src")
						user_username = post.search(".threadauthor strong").text
						user_blog_url = post.search(".threadauthor strong a @href")
						user_title = post.search(".threadauthor .authortitle a").text
						user_profile_url = post.search(".threadauthor .authortitle a @href")

						user = User.find_or_create_by(username: user_username) do |f|
							f.image = user_image.to_s
							f.title = user_title.to_s
							f.blog_url = user_blog_url.to_s
							f.profile_url = user_profile_url.to_s
						end

						post = conversation.posts.find_or_create_by(entry_id: post_entry_id) do |f|
							f.entry_id = post_entry_id
							f.url = post_url
							f.body = post_body
							f.user_id = user.id
							f.created_at = post_created_at
						end
					end
				rescue
				end
			end
		end
	end
end