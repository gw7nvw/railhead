class Person < ActiveRecord::Base
  attr_accessor :remeber_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :firstname, presence: true
  validates :lastname, presence: true
  belongs_to :createdBy, class_name: "Person"

  before_save { self.email = email.downcase }
  before_save { self.username = username.downcase }
  before_create :create_remember_token
 VALID_NAME_REGEX = /\A[a-zA-Z\d\s]*\z/i
  validates :username,  length: { maximum: 50 },
                uniqueness: { case_sensitive: false, :allow_blank => true }, format: { with: VALID_NAME_REGEX }

#  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, 
#format: { with: VALID_EMAIL_REGEX },
                uniqueness: { case_sensitive: false, :allow_blank => true }
  has_secure_password
  def name
    self.firstname+" "+self.lastname
  end

  def address
    addr=self.address1
    if self.address2  and self.address2.length>0 then addr+=", "+self.address2 end
    if self.address3  and self.address3.length>0 then addr+=", "+self.address3 end
    if self.postcode  and self.postcode.length>0 then addr+=" "+self.postcode end
    addr
  end
  def address_town
    addr=""
    if self.address1  and self.address1.length>0 then addr=self.address1 end
    if self.address2  and self.address2.length>0 then addr=self.address2 end
    if self.address3  and self.address3.length>0 then addr=self.address3 end
    addr
  end

  def Person.new_token
    SecureRandom.urlsafe_base64
  end

  def Person.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
  def authenticated?(attribute, token)
     digest = send("#{attribute}_digest")
    return false if digest.nil?
    Digest::SHA1.hexdigest(token.to_s)==digest
  end

  # Activates an account.
  def activate
    update_attribute(:is_Person,    true)
  end
 # Sends activation email.
  def send_activation_email
    PersonMailer.account_activation(self).deliver
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = Person.new_token
    update_attribute(:reset_digest,  Person.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    PersonMailer.password_reset(self).deliver
  end
  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def create_activation_digest
    self.activation_token = Person.new_token
    self.activation_digest = Person.digest(activation_token)
  end

  private

    def create_remember_token
      self.remember_token = Person.digest(Person.new_token)
    end

    def downcase_email
      self.email = email.downcase
    end

end
