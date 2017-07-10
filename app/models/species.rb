class Species < ActiveRecord::Base
  validates :genus, presence: true
  validates :species, presence: true
  validates :code, presence: true
  belongs_to :nztcs, :foreign_key => 'nztcs_name', :primary_key => 'name_and_authority'

def name
  name=self.genus+" "+self.species
end

end
