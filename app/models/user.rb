class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable, :trackable, :omniauthable
  # associations
  has_one :wishlist, dependent: :destroy
  has_many :items, through: :wishlist, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :chatrooms, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :status, dependent: :destroy
  has_many :services, dependent: :destroy

  # Frienship Gem
  has_friendship

  # Taggable Gem
  acts_as_taggable_on :tags
  acts_as_taggable_on :skills, :interests # You can also configure multiple tag types per mod

  ## active storage
  has_one_attached :avatar

  INTERESTS = %w[arts music outdoors tech photography learning food family health wellness sports fitness writing language LGBTQ film sci-fi games books dance animals pets crafts fashion beauty business environment
                 dogs cats wildlife education]

  # friendship_stuff
  def strangers
    users = []
    User.all.each do |user|
      users << user if friends_with?(user) != true && self != user && friends.include?(user) != true && pending_friends.include?(user) != true && requested_friends.include?(user) != true
    end
    users
  end

  def current_user_events
    # get user
    event_ids = []
    interests_arr = ["food"]
    interests.each { |element| interests_arr << element.name }
    # get events with user interests
    interests_arr.each do |element|
      sql_query = " \
        events.name ILIKE :query \
        OR events.category ILIKE :query \
        OR events.description ILIKE :query \
      "
      @events = Event.where(sql_query, query: "%#{element}%")
      event_ids << @events.ids
    end
    # ids of users events
    event = event_ids.flatten
    return @events = Event.where(id: event)
  end
  # def users_friends
  #   friends
  # end

  # def friend_request(user)
  #   FriendRequest.create(requester: self, requested: user)
  # end

  # def accept_request(user)
  #   FriendRequest.find_by(requester: self, requested: user).destroy
  #   Friendship.create(friender: self, friended: user)
  # end
end
