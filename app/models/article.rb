class Article < ActiveRecord::Base
	include AASM

	belongs_to :user
	validates :title, presence:true, uniqueness: true
	validates :body, presence:true, length: {minimum: 20}
	has_many :comments
	has_many :has_categories
	has_many :categories, through: :has_categories

	before_create :set_visits_count
	after_create :save_categories
	after_create :send_mail

	has_attached_file :cover, styles:{medium:"1280x720", thumb:"800x600"}
	#validates_attachment_content_type :cover, content_type:/\Aimage\/.*\Z/
	validates_attachment_content_type :cover, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

	scope :publicados, ->{ where(state: "published")}

	scope :ultimos, ->{ order("created_at DESC")}

	#es lo mismo que lo siguiente
	#def self.publicados
	#   Article.where(state:"published")
	#end	

	#Custom setter
	def categories=(value)
		@categories = value
	end

	def update_visits_count
		self.update(visits_count: self.visits_count + 1)
	end

	aasm column: "state" do
		state :in_draft, initial: true
		state :published

		event :publish do
			transitions from: :in_draft, to: :published
		end

		event :unpublish do
			transitions from: :published, to: :in_draft
		end	

	end

	private

	def send_mail
		ArticleMailer.new_article(self).deliver_later
	end

	def save_categories
		unless @articles.nil?
			@categories.each do |category_id|
				HasCategory.create(category_id: category_id, article_id: self.id)
			end
		end
	end

	def set_visits_count
		self.visits_count ||= 0
	end

end

