class User < ActiveRecord::Base
	has_many :posts

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  def conversations
  	posts.map(&:conversation).uniq
  end

  def ppc
  	(posts.length.to_f / conversations.length).round(2)
  end
end
