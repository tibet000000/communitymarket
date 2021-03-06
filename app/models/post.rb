class Post < ActiveRecord::Base
  
  #after_create :to_facebook
  # before_save :set_default_completed_false
  attr_accessible :borrow, :description, :post_category_id, :school_id, :premium, :price, :cash, :email, :tier_id, :title, :user_id, :assignments_attributes,:assets_attributes, :image, :tag_tokens, :stripe_card_token,:post_to_facebook, :lump_sum, :other, :hourly_rate
  has_many :assets, :as => :imageable, :dependent => :destroy
  belongs_to :post_category
  belongs_to :tier
  belongs_to :user
  belongs_to :school
  has_many :assignments, :dependent => :destroy
  has_many :groups, :through => :assignments
  has_many :taggings
  has_many :tags, :through=> :taggings
  # validates :description , :title, :email, :presence => true
  #validates_email :email
  # validates_uniqueness_of :email
  validates :title, :presence => true
  accepts_nested_attributes_for :assets#, :reject_if => lambda { |t| t[:post_image].nil?}, :allow_destroy => true
  accepts_nested_attributes_for :assignments, :allow_destroy => true
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :tags
  attr_reader :tag_tokens
  attr_accessor :stripe_card_token
  
  
  
  def self.searchable_columns
    wanted_columns = ['title', 'created_at', 'price']
    self.column_names.select{ |column| wanted_columns.include?(column) }
  end
  def self.translated_searchable_columns
    columns = self.searchable_columns
    result = columns.map{ |column| [Group.human_attribute_name(column.to_sym), column] }
    result
  end
  
  def set_default_completed_false
    self.completed ||= false
  end
  
  
  def after_sign_in_post_to_facebook
    options = { 
        :message     => self.title,
        :description => self.description,
        :link        => "http://www.peopleandstuff.com/posts/"+self.id.to_s, 
        :picture     => "" 
      }
    self.user.facebook.put_object(self.user.uid, 'links',options)
  end
  
  
  def update_token(auth_hash)
    user = self.user
    user.token = auth_hash["credentials"]["token"]
    user.save
  end
  
  def to_facebook

    if self.post_to_facebook == true  
      if self.user.oauth_token == nil
        return
      end
      options = { 
          :message     => self.title,
          :description => self.description,
          :link        => "http://www.peopleandstuff.com/posts/"+self.id.to_s, 
          :picture     => "#{self.assets.empty?  ? '/assets/small.png': self.assets.first.image.url(:thumb)}" 
        }
      self.user.facebook.put_object(self.user.uid, 'links',options)
    end

  end
  
  def tag_tokens=(tokens)
    self.tag_ids = Tag.ids_from_tokens(tokens)
  end
  
  def self.from_groups_user_is_member_of(groups)
    posts = Array.new
    groups.each do |group|
      posts << group.posts
    end
    return posts
  end
  
  def deactivate!
    self.active = false
    self.save!
  end
  def activate!
    self.active = true
    self.save!
  end
  
  def complete!
    self.completed = true
    self.save!
  end
  def uncomplete!
    self.completed = false
    self.save!
  end
  
  def for_sale?
    return self.post_category_id == 1
  end
  
  def assign_to!(group)
    assignments.create!(group_id: group.id)
  end
  
  def tag_to(tag)
    taggings.create!(tag_id: tag.id)
  end
  
  def save_customer(user)
    if valid?
      customer = Stripe::Customer.create( :description => user.email, :card => stripe_card_token)
      user.stripe_customer_id = customer.id
      user.save!
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Fuck, Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  end
end
