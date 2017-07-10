class SessionsController < ApplicationController

  def new
    key = OpenSSL::PKey::RSA.new(1024)
    @public_modulus  = key.public_key.n.to_s(16)
    @public_exponent = key.public_key.e.to_s(16)
    session[:key] = key.to_pem
  end

  def create
  key = OpenSSL::PKey::RSA.new(session[:key])
  if params[:session][:password] then password = key.private_decrypt(Base64.decode64(params[:session][:password])) else password=params[:session][:upassword] end

  person = Person.find_by(email: params[:session][:email].downcase)
  if !person then  person = Person.find_by(username: params[:session][:email].downcase) end

  if person && person.authenticate(password)
      if person.is_active and person.is_user then
        sign_in person
        redirect_to root_url
      else
        message  = "Account not activated."
        message += "Contact the system administrator to enable your account"
        flash[:error] = message
        render 'new'
      end
    # Sign the person in and redirect to the person's show page.
  else
      flash.now[:error] = 'Invalid username/password combination' 
      new()
      render 'new'
  end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
