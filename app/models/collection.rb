class Collection < ActiveRecord::Base

#  validates :date, presence: true
  validates :species_code, presence: true
  validates :id, uniqueness: { :allow_blank => true }
  belongs_to :projection
  belongs_to :createdBy, class_name: "Person"
  belongs_to :team_lead, class_name: "Person"
  belongs_to :species, :foreign_key => 'species_code', :primary_key => 'code'
  belongs_to :source
  has_many :seeds, class_name: "Seed", foreign_key: "collection_id", primary_key: "id"

def name
  name=self.id.to_s+" (collected: "+if self.date then self.date.strftime('%d/%m/%Y') else '' end+")"
end
def description
  name=self.id.to_s+" ("+if self.date then self.date.strftime('%d/%m/%Y') else '' end+" - "+self.species.code+" - "+(if self.source then self.source.name else self.source_description end)+")"
end

def source_name
  if self.source then self.source.name else self.source_description end
end
end
