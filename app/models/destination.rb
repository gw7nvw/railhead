class Destination < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :projection
  belongs_to :createdBy, class_name: "Person"
  belongs_to :contact_person, class_name: "Person"

def address
    addr=self.property_address1
    if self.property_address2  and self.property_address2.length>0 then addr+=", "+self.property_address2 end
    if self.property_address3  and self.property_address3.length>0 then addr+=", "+self.property_address3 end
    addr
end


end
