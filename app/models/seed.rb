class Seed < ActiveRecord::Base

belongs_to :collection
validates :collection, presence: true
validates :date_sown, presence: true
has_one :source, :through => :collection
has_one :species, :through => :collection
has_many :seedlings, class_name: "Seedling", foreign_key: "seed_code", primary_key: "seed_code"

def name
  name=self.seed_code+" (sown: "+if self.date_sown then self.date_sown.strftime('%d/%m/%Y') else '' end+")"
end
def description
   if self.collection then
     self.seed_code+" (sown: "+if self.date_sown then self.date_sown.strftime('%d/%m/%Y') else '' end+" - coll: "+if self.collection.date then self.collection.date.strftime('%d/%m/%Y') else '' end+" - "+self.collection.species.code+" - "+(if self.collection.source then self.collection.source.name else self.collection.source_description end)+")"
   else
     self.name
   end

end

end
