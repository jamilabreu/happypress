class Post < ActiveRecord::Base
	STOP_WORDS = %W( a able add am and after again appear blog blogs by
		can cannot cant can't change changes changing com do does doesn't
		enter error first from for get had has have help home how
		i if in into is it keep make mine my need new not of on one only
		page please possible problem problems product products remove
		setting settings site sites someone that the these to today top
		want will with when why wont won't wordpress 1 2 3 4 5 6 7 8 9 10)

  belongs_to :conversation, touch: true
  belongs_to :user

  def self.get_conversations(page_number)
		forum_url = "http://en.forums.wordpress.com/"
		forum_url += "page/#{page_number}" unless page_number == 1
		puts forum_url

		forum = Nokogiri::HTML(open(forum_url))
		forum.search("tbody#latest tr").each do |row|
			conversation_title = row.search("td[1] a").text.to_s
			conversation_url = row.search("td[1] a @href").to_s
			conversation_count = row.search("td[2]").text.to_i
			@conversation = Conversation.find_or_create_by(url: conversation_url) do |f|
				f.title = conversation_title
      end
    end
  end
end
