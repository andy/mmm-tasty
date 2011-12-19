class MobileSettings < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id
  validates_uniqueness_of :keyword
  validates_length_of :keyword, :within => 6..15

  def self.generate_keyword(size = 3)
    c = %w(b c d f g h j k l m n p qu r s t v w x z ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr)
    v = %w(a e i o u y)
    f, r = true, ''
    (size * 2).times do
      r << (f ? c[rand * c.size] : v[rand * v.size])
      f = !f
    end
    r
  end
end