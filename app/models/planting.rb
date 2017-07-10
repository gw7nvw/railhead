class Planting < ActiveRecord::Base
belongs_to :seedling, :primary_key => 'seedling_code', :foreign_key => 'seedling_code'
belongs_to :projection
validates :seedling, presence: true
validates :date_planted, presence: true
has_one :seed, :through => :seedling
has_one :collection, :through => :seedling
has_one :source, :through => :seedling
has_one :species, :through => :seedling
belongs_to :destination

end
