class PeopleController < ApplicationController
  before_action :signed_in_person
  def index_prep
    whereclause="true"
    if params[:filter] then 
      @filter=params[:filter] 
      whereclause="is_"+@filter+" is true" 
    end

    @people=Person.find_by_sql [ 'select * from people where '+whereclause+' order by lastname, firstname' ]
  end
  def index
    index_prep()
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data people_to_csv(@people), filename: "people-#{Date.today}.csv" }
    end

  end

  def show
    if(!(@person = Person.where(id: params[:id]).first)) 
      redirect_to '/'
    end
  end

  def new
    if params[:referring] then @referring=params[:referring] end
    @person = Person.new
    @person.is_active=true
  end

 def create
  if signed_in? and current_person.is_modifier then
    @person = Person.new(person_params)
    @person.username=@person.username.strip
    @person.firstname=@person.firstname.strip
    @person.lastname=@person.lastname.strip
    @person.email=@person.email.strip
    @person.createdBy_id=current_person.id



    if @person.password.nil? and !@person.is_user then 
      @person.password="dummy" 
      @person.password_confirmation="dummy"
    end
    if @person.save
      @person.reload
        if params[:referring]=='index' then
          index_prep()
          render 'index'
        else
          render 'show'
        end
    else
      if params[:referring] then @referring=params[:referring] end
      render 'new'
    end
  else
    redirect_to '/'
  end
end

def edit
   if params[:referring] then @referring=params[:referring] end

   if !@person then @person = Person.where(id: params[:id]).first end
 #   if((@person.id!=@current_person.id) and (!@current_person.is_admin))
 #       redirect_to '/people/'+@person.id
 #   end
end

def update
 if signed_in? and (current_person.is_modifier or current_person.id == params[:id].to_i) then
   if params[:delete] then
      person = Person.find_by_id(params[:id])
      if person and person.destroy
        flash[:success] = "Person deleted, id:"+params[:id]
        index_prep()
        render 'index'
      else
        edit()
        render 'edit'
      end
    else

      @person = Person.find_by_id(params[:id])
      @person.assign_attributes(person_params)
      @person.firstname=@person.firstname.strip
      @person.lastname=@person.lastname.strip
      @person.username=@person.username.strip
      @person.email=@person.email.strip
      @person.createdBy_id=current_person.id

      #only allow us to change own password unless we are admin
      if @person.id != current_person.id and !current_person.is_admin then
          @person.password=nil
          @person.password_confirmation=nil
      end

      if @person.save 
        flash[:success] = "Person details updated"
  
        # Handle a successful update.
        if params[:referring]=='index' then
          index_prep()
          render 'index'
        else
          render 'show'
        end
      else
        if params[:referring] then @referring=params[:referring] end
        render 'edit'
      end
   end
  else
    redirect_to '/'
  end

end


#editgrid handlers

  def data
            people = Person.all.order(:lastname)

            render :json => {
                 :total_count => people.length,
                 :pos => 0,
                 :rows => people.map do |person|
                 {
                   :id => person.id,
                   :data => [person.id,person.username,person.firstname,person.lastname,person.email,person.mobile,person.homephone,person.address1,person.address2,person.address3,person.postcode,person.is_member,person.is_source,person.is_destination,person.is_user,person.is_modifier,person.is_admin,person.is_active]
                 }
                 end
            }
  end

def db_action
  if signed_in? and current_person.is_modifier then
    @mode = params["!nativeeditor_status"]
    id = params['c0']
    username = params['c1']
    firstname = params['c2']
    lastname = params['c3']
    email = params['c4']
    mobile = params['c5']
    homephone = params['c6']
    address1 = params['c7']
    address2 = params['c8']
    address3 = params['c9']
    postcode = params['c10']
    is_member = params['c11']
    is_source = params['c12']
    is_destination = params['c13']
    is_user = params['c14']
    is_modifier = params['c15']
    is_admin = params['c16']
    is_active = params['c17']

    @id = params["gr_id"]



    case @mode

    when "inserted"
        person = Person.create :username => username, :firstname => firstname,:lastname => lastname, :email => email, :mobile => mobile,:homephone => homephone, :address1 => address1, :address2 => address2, :address3 => address3, :postcode => postcode, :is_member => is_member, :is_source => is_source, :is_destination => is_destination, :is_user => is_user, :is_modifier => is_modifier, :is_admin => is_admin, :is_active => is_active
       if person then
          @tid = person.id
       else
          @mode-"error"
          @tid=nil
       end


    when "deleted"
        if Person.find(@id).destroy then
          @tid = @id
        else
          @mode="error"
          @tid=nil
       end

   when "updated"
        @person = Person.find(@id)
        @person.username = username
        @person.firstname = firstname
        @person.lastname = lastname
        @person.email = email
        @person.mobile = mobile
        @person.homephone = homephone
        @person.address1 =address1 
        @person.address2 = address2
        @person.address3 = address3
        @person.postcode = postcode
        @person.is_member = is_member
        @person.is_source = is_source
        @person.is_destination = is_destination
        @person.is_user = is_user
        @person.is_modifier = is_modifier
        @person.is_admin = is_admin
        @person.is_active = is_active
        if !@person.save then @mode="error" end

        @tid = @id
    end
  end
end

  def people_to_csv(items)
    require 'csv'
    csvtext=""
    if items and items.first then
      columns=[]; items.first.attributes.each_pair do |name, value| if !name.include?("password") and !name.include?("digest") and !name.include?("token") then columns << name end end
      csvtext << columns.to_csv
      items.each do |item|
         fields=[]; item.attributes.each_pair do |name, value| if !name.include?("password") and !name.include?("digest") and !name.include?("token") then fields << value end end
         csvtext << fields.to_csv
      end
   end
   csvtext
  end

  private

    def person_params
      params.require(:person).permit(:username, :firstname, :lastname, :initials, :email, :password, :password_confirmation, :mobile, :homephone, :address1, :address2, :address3, :postcode, :is_member, :is_active, :is_source, :is_destination, :is_admin, :is_user, :is_modifier)
    end


    # Before filters

end
