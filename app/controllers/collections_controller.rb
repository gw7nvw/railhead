class CollectionsController < ApplicationController

  before_action :signed_in_person

  def editgrid

  end


  def index_prep
    whereclause="is_active is true"
    if params[:filter] then
      @filter=params[:filter]
      if @filter=="active" then 
        whereclause="true"
      else
        whereclause="is_"+@filter+" is true"
      end
    end

    @collections=Collection.find_by_sql [ 'select * from collections where '+whereclause+' order by id DESC' ]
  end

  def index
    index_prep() 
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data collection_to_csv(@collections), filename: "collections-#{Date.today}.csv" }
    end
  end

  def show
    if(!(@collection = Collection.where(id: params[:id]).first))
      redirect_to '/'
    else

      if(@collection.location==nil and @collection.x and @collection.y and @collection.projection) then
        convert_location_params()      
      end
    end 
  end

  def edit
    if params[:referring] then @referring=params[:referring] end

    if(!(@collection = Collection.where(id: params[:id]).first))
      redirect_to '/'
    end
    if(@collection.location==nil and @collection.x and @collection.y and @collection.projection) then
      convert_location_params()      
    end
  end

  def new
    if params[:referring] then @referring=params[:referring] end
    @collection = Collection.new
  end

  def create
    if signed_in? and current_person.is_modifier then
      @collection = Collection.new(collection_params)
      #autoassign id (postgres cannot cope with mix of manual and autoassigned)
      if !@collection.id then
        cids=Collection.find_by_sql "SELECT max(id) as id FROM collections;"
        if cids then cid=cids.first.id end
        if cid then @collection.id=cid+1 end
      end
      convert_location_params()
      @collection.createdBy_id=current_person.id


      if @collection.save
          @collection.reload
          if params[:referring]=='index' then
            index_prep()
            render 'index'
          else
            render 'show'
          end

      else
          render 'new'
      end
    else
      redirect_to '/'
    end
 
  end


def update
  if signed_in? and current_person.is_modifier then
    if params[:delete] then
      collection = Collection.find_by_id(params[:id])
      if collection and collection.destroy
        flash[:success] = "Collection deleted, id:"+params[:id]
        index_prep()
        render 'index'
      else
        edit()
        render 'edit'
      end
    else
      if(!@collection = Collection.find_by_id(params[:id]))
          flash[:error] = "Collection does not exist: "+@collection.id.to_s

          #tried to update a nonexistant collection
          render 'edit'
      end

      @collection.assign_attributes(collection_params)
      convert_location_params()
      @collection.createdBy_id=current_person.id

      if @collection.save
        flash[:success] = "Collection details updated"

        # Handle a successful update.
        if params[:referring]=='index' then
          index_prep()
          render 'index'
        else
          render 'show'
        end
      else
        render 'edit'
      end
    end
  else
    redirect_to '/'
  end
end

#editgrid handlers

  def data
            collections = Collection.all.order(:id).reverse

            render :json => {
                 :total_count => collections.length,
                 :pos => 0,
                 :rows => collections.map do |collection|
                 {
                   :id => collection.id,
                   :data => [collection.id,if collection.date then collection.date.strftime('%d/%m/%Y') else '' end, collection.species_code||"", collection.source_id||0, collection.source_description, collection.x, collection.y, collection.altitude, collection.projection_id||0, collection.no_plants_sampled, collection.no_collected, collection.current_stock, collection.is_seeds, collection.is_cuttings, collection.team_lead_id||0, collection.team_members, collection.storage, collection.notes, collection.is_active]
                 }
                 end
            }
  end

def db_action
  if signed_in? and current_person.is_modifier then
    @mode = params["!nativeeditor_status"]
    id = params['c0']
    date = params['c1']
    species_code = params['c2']
    source_id = params['c3']
    source_description = params['c4']
    x = params['c5']
    y = params['c6']
    altitude = params['c7']
    projection_id = params['c8']
    no_plants_sampled = params['c9']
    no_collected = params['c10']
    current_stock = params['c11']
    is_seeds = params['c12']
    is_cuttings = params['c13']
    team_lead_id = params['c14']
    team_members = params['c15']
    storage = params['c16']
    notes = params['c17']
    is_active = params['c18']

    @id = params["gr_id"]

    case @mode
    when "inserted"
        collection = Collection.create :source_id => source_id, :source_description => source_description,:date => date, :x => x, :y => y, :altitude => altitude, :projection_id => projection_id, :no_plants_sampled => no_plants_sampled, :no_collected => no_collected, :current_stock => current_stock, :is_seeds => is_seeds, :is_cuttings => is_cuttings, :team_lead_id => team_lead_id, :team_members => team_members, :species_code => species_code, :storage => storage, :notes => notes, :is_active => is_active
       if collection then 
          @tid = collection.id
       else
          @mode="error"
          @tid=nil
       end   
  

    when "deleted"
        if Collection.find(@id).destroy then
          @tid = @id
        else
          @mode-"error"  
          @tid=nil
       end


    when "updated"
        @collection = Collection.find(@id)
        if @collection.x!=x or @collection.y!=y or @collection.projection_id!=projection_id then need_convert=true else need_convert=false end
        @collection.source_id = source_id   
        @collection.source_description = source_description
        @collection.date = date   
        if x!="" then @collection.x = x else @collection.x = nil end
        if y!="" then @collection.y = y else @collection.y = nil end
        @collection.altitude = altitude 
        @collection.projection_id = projection_id  
        @collection.no_plants_sampled = no_plants_sampled  
        @collection.no_collected = no_collected  
        @collection.current_stock = current_stock  
        @collection.is_seeds = is_seeds  
        @collection.is_cuttings = is_cuttings  
        @collection.team_lead_id = team_lead_id  
        @collection.team_members = team_members  
        @collection.species_code = species_code  
        @collection.storage = storage  
        @collection.notes = notes
        @collection.is_active = is_active
        if need_convert then convert_location_params() end
        if projection_id!=4326 and @collection.x and @collection.y then  
          @collection.x = @collection.x.to_i
          @collection.y = @collection.y.to_i
        end  
        if !@collection.save then @mode="error" end

        @tid = @id
    end
  end
end
  private
  def collection_params
    params.require(:collection).permit(:id, :source_description, :source_id, :date, :location, :x, :y, :altitude, :projection_id, :no_plants_sampled, :no_collected, :current_stock, :is_seeds, :is_cuttings, :team_lead_id, :team_members, :species_code, :storage, :notes, :is_active)
  end

  def convert_location_params
   if(@collection.x and @collection.y  and @collection.projection)

       # convert to NZTM2000 (EPSG4326) for display 
       if @collection.projection_id != 2193 then
         fromproj4s= @collection.projection.proj4
         toproj4s=  Projection.find_by_id(2193).proj4

         fromproj=RGeo::CoordSys::Proj4.new(fromproj4s)
         toproj=RGeo::CoordSys::Proj4.new(toproj4s)

         xyarr=RGeo::CoordSys::Proj4::transform_coords(fromproj,toproj,@collection.x,@collection.y)

         @collection.x=xyarr[0]
         @collection.y=xyarr[1]
         @collection.projection_id=2193
       end
       if @collection.projection_id!=4326 then 
           @collection.x=@collection.x.to_i
           @collection.y=@collection.y.to_i
       end

       # convert to WGS84 (EPSG4326) for database 
       fromproj4s= @collection.projection.proj4
       toproj4s=  Projection.find_by_id(4326).proj4

       fromproj=RGeo::CoordSys::Proj4.new(fromproj4s)
       toproj=RGeo::CoordSys::Proj4.new(toproj4s)

       xyarr=RGeo::CoordSys::Proj4::transform_coords(fromproj,toproj,@collection.x,@collection.y)

       params[:location]=xyarr[0].to_s+" "+xyarr[1].to_s
       @collection.location='POINT('+params[:location]+')'
   
      #if altitude is not entered, calculate it from map 
      if !@collection.altitude or @collection.altitude.to_i == 0 then
         #get alt from map if it is blank or 0
         altArr=Dem30.find_by_sql ["
            select ST_Value(rast, ST_GeomFromText(?,4326))  rid
               from dem30s
               where ST_Intersects(rast,ST_GeomFromText(?,4326));",
               'POINT('+params[:location]+')',
               'POINT('+params[:location]+')']

         @collection.altitude=altArr.first.try(:rid).to_i
       end
    else 
       @collection.location=nil
    end
  end


end
