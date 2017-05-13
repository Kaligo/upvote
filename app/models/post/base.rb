module Post
  class Base < ActiveRecord::Base
    extend FriendlyId
    friendly_id :title, use: :slugged

    self.table_name = :posts

    scope :with_number_of_votes, -> {
      joins("LEFT JOIN votes on votes.votable_id = posts.id and votes.votable_type = 'Post::Base'")
        .select("posts.*, count(votes.id) as num_of_votes")
        .group("posts.id")
    }

    has_many :votes, class_name: ActsAsVotable::Vote, as: :votable

    belongs_to :user
    has_many :clicks, class_name: 'PostClick', foreign_key: :post_id

    validates :title, presence: true
    validates :user_id, presence: true
    validates :user, presence: true

    acts_as_votable
    acts_as_commentable
    acts_as_taggable

    scope :on_date, ->(date) { where 'posts.created_at > ? AND posts.created_at < ?', date, date + 1.day }
  end
end
