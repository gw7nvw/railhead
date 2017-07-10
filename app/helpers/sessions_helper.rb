module SessionsHelper

  def sign_in(person)
    remember_token = Person.new_token
    cookies[:remember_token] = {value: remember_token, expires: 1.month.from_now.utc}
    person.update_attribute(:remember_token, Person.digest(remember_token))
    self.current_person = person
    session[:person_id]=person.id
  end

  def sign_out
    current_person.update_attribute(:remember_token,
                                  Person.digest(Person.new_token))
    cookies.delete(:remember_token)
    self.current_person = nil
    session[:person_id]=nil
    
  end

  def signed_in?
    !current_person.nil?
  end


  def current_person=(person)
    @current_person = person
  end

  def current_person
    remember_token = Person.digest(cookies[:remember_token])
    @current_person ||= Person.find_by(remember_token: remember_token)
  end
end
