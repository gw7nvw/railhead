class SpeciesController < ApplicationController
  before_action :signed_in_person, except: [:index, :show]

  def index_prep
    whereclause="true"
    if params[:filter] then 
      @filter=params[:filter] 
      whereclause="is_"+@filter+" is true" 
    end

    @species=Species.find_by_sql [ 'select * from species where '+whereclause+' order by genus, species' ]
  end
  def index
    index_prep()
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data collection_to_csv(@species), filename: "species-#{Date.today}.csv" }
    end

  end

  def show
    if(!(@species = Species.where(id: params[:id]).first)) 
      redirect_to '/'
    end

    @areas=Area.all
  end

  def new
    if params[:referring] then @referring=params[:referring] end
    @species = Species.new
    @species.is_active=true
  end

 def create
  if signed_in? and current_person.is_modifier then
    @species = Species.new(species_params)
    if @species.nztcs_name=="" then @species.nztcs_name=nil end
    @species.createdBy_id=current_person.id

    if @species.save
      @species.reload
        if params[:referring]=='index' then
          index_prep()
          render 'index'
        else
          @areas=Area.all
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

   if !@species then @species = Species.where(id: params[:id]).first end
 #   if((@person.id!=@current_person.id) and (!@current_person.is_admin))
 #       redirect_to '/people/'+@person.id
 #   end
end

def update
 if signed_in? and current_person.is_modifier then
   if params[:delete] then
      species = Species.find_by_id(params[:id])
      if species and species.destroy
        flash[:success] = "Species deleted, id:"+params[:id]
        index_prep()
        render 'index'
      else
        edit()
        render 'edit'
      end
    else

      @species = Species.find_by_id(params[:id])
      @species.assign_attributes(species_params)
      if @species.nztcs_name=="" then @species.nztcs_name=nil end
      @species.createdBy_id=current_person.id

      if @species.save 
        flash[:success] = "Species details updated"
  
        # Handle a successful update.
        if params[:referring]=='index' then
          index_prep()
          render 'index'
        else
          @areas=Area.all
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
            species = Species.all.order(:code)

            render :json => {
                 :total_count => species.length,
                 :pos => 0,
                 :rows => species.map do |s|
                 {
                   :id => s.id,
                   :data => [s.id,s.code,s.genus,s.species,s.common_name,s.nztcs_name,s.is_active]
                 }
                 end
            }
  end

def db_action
  if signed_in? and current_person.is_modifier then
    @mode = params["!nativeeditor_status"]
    id = params['c0']
    code = params['c1']
    genus = params['c2']
    species = params['c3']
    common_name = params['c4']
    nztcs_name = params['c5']
    is_active = params['c6']

    @id = params["gr_id"]



    case @mode

    when "inserted"
        species = Species.create :code => code, :species => species,:genus => genus, :common_name => common_name, :is_active => is_active
       if species then
          @tid = species.id
      else
          @mode="error"
          @tid=nil
       end


    when "deleted"
        if Species.find(@id).destroy then
          @tid = @id
        else
          @mode="error"
          @tid=nil
       end

    when "updated"
        @species = Species.find(@id)
        @species.code = code
        @species.genus = genus
        @species.species = species
        @species.common_name = common_name
        @species.is_active = is_active
        if !@species.save then @mode="error" end

        @tid = @id
    end
  end
end

  private

    def species_params
      params.require(:species).permit(:code, :genus, :species, :common_name, :nztcs_name, :is_active)
    end


    # Before filters

end
