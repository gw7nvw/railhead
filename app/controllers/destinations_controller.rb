class DestinationsController < ApplicationController

  before_action :signed_in_person

  def index_prep
    whereclause="true"
    if params[:filter] then
      @filter=params[:filter]
      whereclause="is_"+@filter+" is true"
    end

    @destinations=Destination.find_by_sql [ 'select * from destinations where '+whereclause+' order by name' ]
  end
  def index
    index_prep()
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data collection_to_csv(@destinations), filename: "destinations-#{Date.today}.csv" }
    end

  end

  def show
    if(!(@destination = Destination.where(id: params[:id]).first))
      redirect_to '/'
    end
  end

  def edit
    if params[:referring] then @referring=params[:referring] end

    if(!(@destination = Destination.where(id: params[:id]).first))
      redirect_to '/'
    end
  end

  def new
    if params[:referring] then @referring=params[:referring] end
    @destination = Destination.new
  end

  def create
    if signed_in? and current_person.is_modifier then
      @destination = Destination.new(destination_params)
      convert_location_params()
      @destination.createdBy_id=current_person.id


      if @destination.save
          @destination.reload
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
      destination = Destination.find_by_id(params[:id])
      if destination and destination.destroy
        flash[:success] = "Destination deleted, id:"+params[:id]
        index_prep()
        render 'index'
      else
        edit()
        render 'edit'
      end
    else
      if(!@destination = Destination.find_by_id(params[:id]))
          flash[:error] = "Destination does not exist: "+@destination.id.to_s

          #tried to update a nonexistant destination
          render 'edit'
      end

      @destination.assign_attributes(destination_params)
      convert_location_params()
      @destination.createdBy_id=current_person.id

      if @destination.save
        flash[:success] = "Destination details updated"

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
            destinations = Destination.all.order(:name)

            render :json => {
                 :total_count => destinations.length,
                 :pos => 0,
                 :rows => destinations.map do |destination|
                 {
                   :id => destination.id,
                   :data => [destination.id,destination.name,destination.owner,destination.legal_status,destination.contact_person_id||"", destination.property_address1,destination.property_address2,destination.property_address3,destination.x,destination.y,destination.altitude,destination.projection_id||"",destination.notes,destination.is_active]
                 }
                 end
            }
  end
def db_action
  if signed_in? and current_person.is_modifier then
    @mode = params["!nativeeditor_status"]
    id = params['c0']
    name = params['c1']
    owner = params['c2']
    legal_status = params['c3']
    contact_person_id = params['c4']
    property_address1 = params['c5']
    property_address2 = params['c6']
    property_address3 = params['c7']
    x = params['c8']
    y = params['c9']
    altitude = params['c10']
    projection_id = params['c11']
    notes = params['c12']
    is_active = params['c13']

    @id = params["gr_id"]



    case @mode

    when "inserted"
        destination = Destination.create :name => name, :owner => owner, :legal_status => legal_status, :contact_person_id => contact_person_id,:property_address1 => property_address1, :property_address2 => property_address2,:property_address3 => property_address3, :x => x, :y => y, :altitude => altitude, :projection_id => projection_id, :notes => notes, :is_active => is_active
       if destination then
          @tid = destination.id
       else
          @mode="error"
          @tid=nil
       end


    when "deleted"
        if Destination.find(@id).destroy then
          @tid = @id
        else
          @mode="error"
          @tid=nil
       end

    when "updated"
        @destination = Destination.find(@id)
        if @destination.x!=x or @destination.y!=y or @destination.projection_id!=projection_id then need_convert=true else need_convert=false end
        @destination.name = name
        @destination.owner = owner
        @destination.legal_status = legal_status
        @destination.contact_person_id = contact_person_id
        @destination.property_address1 = property_address1
        @destination.property_address2 = property_address2
        @destination.property_address3 = property_address3
        if x!="" then @destination.x = x else @destination.x = nil end
        if y!="" then @destination.y = y else @destination.y = nil end
        @destination.altitude = altitude
        @destination.projection_id = projection_id
        @destination.notes = notes
        @destination.is_active = is_active
        if need_convert then convert_location_params() end
        if projection_id!=4326 and @destination.x and @destination.y then
          @destination.x = @destination.x.to_i
          @destination.y = @destination.y.to_i
        end
        if !@destination.save then @mode="error" end
        @tid = @id
    end
  end
end

private
  def destination_params
    params.require(:destination).permit(:id, :name, :owner, :legal_status, :contact_person_id, :property_address1, :property_address2, :property_address3, :location, :x, :y, :altitude, :projection_id, :boundary, :notes, :is_active)
  end

  def convert_location_params
   if(@destination.x and @destination.y and @destination.projection)
       if @destination.projection.id!=4326 then
           x=x.to_i
           y=y.to_i
       end
       # convert to WGS84 (EPSG4326) fro database 
       fromproj4s= @destination.projection.proj4
       toproj4s=  Projection.find_by_id(4326).proj4

       fromproj=RGeo::CoordSys::Proj4.new(fromproj4s)
       toproj=RGeo::CoordSys::Proj4.new(toproj4s)

       xyarr=RGeo::CoordSys::Proj4::transform_coords(fromproj,toproj,@destination.x,@destination.y)

       params[:location]=xyarr[0].to_s+" "+xyarr[1].to_s
       @destination.location='POINT('+params[:location]+')'

       # convert to NZTM2000 (EPSG4326) for display 
       fromproj4s= @destination.projection.proj4
       toproj4s=  Projection.find_by_id(2193).proj4

       fromproj=RGeo::CoordSys::Proj4.new(fromproj4s)
       toproj=RGeo::CoordSys::Proj4.new(toproj4s)

       xyarr=RGeo::CoordSys::Proj4::transform_coords(fromproj,toproj,@destination.x,@destination.y)

       @destination.x=xyarr[0]
       @destination.y=xyarr[1]
       @destination.projection_id=2193

       #if altitude is not entered, calculate it from map 
      if @destination.altitude.nil? or @destination.altitude== 0
         #get alt from map if it is blank or 0
         altArr=Dem30.find_by_sql ["
            select ST_Value(rast, ST_GeomFromText(?,4326))  rid
               from dem30s
               where ST_Intersects(rast,ST_GeomFromText(?,4326));",
               'POINT('+params[:location]+')',
               'POINT('+params[:location]+')']

         @destination.altitude=altArr.first.try(:rid).to_i
       end
    else
       @destination.location=nil
    end
  end

end
