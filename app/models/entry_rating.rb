class EntryRating < ActiveRecord::Base
  belongs_to :entry

  RATINGS = {
    :great => { :select => 'Великолепное (+5 и круче)', :header => 'Самое прекрасное!!!@#$%!', :filter => 'entry_ratings.value >= 5', :order => 1 },
    :good => { :select => 'Интересное (+2 и выше)', :header => 'Интересное на тейсти', :filter => 'entry_ratings.value >= 2', :order => 2 },
    :everything => { :select => 'Всё подряд (-5 и больше)', :header => 'Всё подряд на тейсти', :filter => 'entry_ratings.value >= -5', :order => 3 }
  }
  RATINGS_FOR_SELECT = RATINGS.sort_by { |obj| obj[1][:order] }.map { |k,v| [v[:select], k.to_s] }

  validates_presence_of :user_id
  validates_presence_of :entry_id
  validates_presence_of :entry_type
end