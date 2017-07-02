class Movie < ActiveRecord::Base
  belongs_to :user
  has_many :movie_actors
  has_many :actors, :through => :movie_actors

  def slug
      name.downcase.gsub(" ", "-")
    end


  def self.find_by_slug(slug)
    self.all.find{|name| name.slug == slug}
  end
end
