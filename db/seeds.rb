require 'open-uri'

1.upto(100).each do |number|
  begin
    forum_url = "http://en.forums.wordpress.com/"
    forum_url += "page/#{number}" unless number == 1
    puts forum_url

    forum = Nokogiri::HTML(open(forum_url))
    forum.search("tbody#latest tr").each do |row|
      conversation_title = row.search("td[1] a").text.to_s
      conversation_url = row.search("td[1] a @href").to_s
      conversation_count = row.search("td[2]").text.to_i
      @conversation = Conversation.find_or_create_by(url: conversation_url) do |f|
        f.title = conversation_title
      end

      unless @conversation.posts.length == conversation_count
        pagination = Nokogiri::HTML(open(@conversation.url)).search("p.pages .page-numbers:not(.next)").last
        last_page_in_conversation = pagination.blank? ? 1 : pagination.text.to_i
        last_page_in_conversation.downto(1).each do |page_number|
          conversation_page_url = @conversation.url
          conversation_page_url += "/page/#{page_number}" unless page_number == 1
          conversation_page = Nokogiri::HTML(open(conversation_page_url))

          conversation_page.search("ol#thread > li").reverse.each_with_index do |post, index|
            post_element_id = post.search("@id").to_s
            post_entry_id = post_element_id.split("-")[1].to_i
            post_url = index == 0 ? @conversation.url : @conversation.url + "?replies##{post_element_id}"
            post_created_at = Chronic.parse(post.search(".threadauthor time @datetime").to_s)
            post_body = post.search(".post").to_s
            user_image = post.search(".threadauthor img @src").to_s
            user_username = post.search(".threadauthor strong").text.to_s
            user_blog_url = post.search(".threadauthor strong a @href").to_s
            user_title = post.search(".threadauthor .authortitle a").text.to_s
            user_profile_url = post.search(".threadauthor .authortitle a @href").to_s

            @user = User.find_or_create_by(username: user_username) do |f|
              f.image = user_image
              f.title = user_title
              f.blog_url = user_blog_url
              f.profile_url = user_profile_url
            end

            unless @conversation.posts.find_by(entry_id: post_entry_id)
              @post = @conversation.posts.create(
                entry_id: post_entry_id,
                url: post_url,
                body: post_body,
                user_id: @user.id,
                created_at: post_created_at
              )
            end
          end
        end
      end
    end
  rescue
  end
end