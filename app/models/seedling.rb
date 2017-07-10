class Seedling < ActiveRecord::Base
belongs_to :seed, :primary_key => 'seed_code', :foreign_key => 'seed_code'
validates :seed, presence: true
validates :date_potted, presence: true
has_one :collection, :through => :seed
has_one :source, :through => :seed
has_one :species, :through => :seed
has_many :plantings, class_name: "Planting", foreign_key: "seedling_code", primary_key: "seedling_code"

def name
  name=self.seedling_code+" (potted: "+if self.date_potted then self.date_potted.strftime('%d/%m/%Y') else '' end+")"
end
def description
   if self.collection and self.seed and self.species then
     self.seedling_code+" (potted: "+if self.date_potted then self.date_potted.strftime('%d/%m/%Y') else '' end +" - sown: "+if self.seed.date_sown then self.seed.date_sown.strftime('%d/%m/%Y') else '' end +" - coll: "+if self.collection.date then self.collection.date.strftime('%d/%m/%Y') else '' end +" - "+self.species.code+" - "+(if self.source then self.source.name else self.collection.source_description end)+")"
   else
     self.name
   end

end

end
