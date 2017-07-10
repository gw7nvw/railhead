class SourcesController < ApplicationController

  before_action :signed_in_person

  def index_prep
    whereclause="true"
    if params[:filter] then
      @filter=params[:filter]
      whereclause="is_"+@filter+" is true"
    end

    @sources=Source.find_by_sql [ 'select * from sources where '+whereclause+' order by name' ]
  end
  def index
    index_prep()
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data collection_to_csv(@sources), filename: "sources-#{Date.today}.csv" }
    end

  end

  def show
    if(!(@source = Source.where(id: params[:id]).first))
      redirect_to '/'
    end
  end

  def edit
    if params[:referring] then @referring=params[:referring] end

    if(!(@source = Source.where(id: params[:id]).first))
      redirect_to '/'
    end
  end

  def new
    if params[:referring] then @referring=params[:referring] end
    @source = Source.new
  end

  def create
    if signed_in? and current_person.is_modifier then
      @source = Source.new(source_params)
      convert_location_params()
      @source.createdBy_id=current_person.id


      if @source.save
          @source.reload
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
      source = Source.find_by_id(params[:id])
      if source and source.destroy
        flash[:success] = "Source deleted, id:"+params[:id]
        index_prep()
        render 'index'
      else
        edit()
        render 'edit'
      end
    else
      if(!@source = Source.find_by_id(params[:id]))
          flash[:error] = "Source does not exist: "+@source.id.to_s

          #tried to update a nonexistant source
          render 'edit'
      end

      @source.assign_attributes(source_params)
      convert_location_params()
      @source.createdBy_id=current_person.id

      if @source.save
        flash[:success] = "Source details updated"

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
            sources = Source.all.order(:name)

            render :json => {
                 :total_count => sources.length,
                 :pos => 0,
                 :rows => sources.map do |source|
                 {
                   :id => source.id,
                   :data => [source.id,source.name,source.contact_person_id||"", source.property_address1,source.property_address2,source.property_address3,source.x,source.y,source.altitude,source.projection_id||"",source.notes,source.is_active]
                 }
                 end
            }
  end

def db_action
  if signed_in? and current_person.is_modifier then
    @mode = params["!nativeeditor_status"]
    id = params['c0']
    name = params['c1']
    contact_person_id = params['c2']
    property_address1 = params['c3']
    property_address2 = params['c4']
    property_address3 = params['c5']
    x = params['c6']
    y = params['c7']
    altitude = params['c8']
    projection_id = params['c9']
    notes = params['c10']
    is_active = params['c11']

    @id = params["gr_id"]


    
    case @mode

    when "inserted"
        source = Source.create :name => name, :contact_person_id => contact_person_id,:property_address1 => property_address1, :property_address2 => property_address2,:property_address3 => property_address3, :x => x, :y => y, :altitude => altitude, :projection_id => projection_id, :notes => notes, :is_active => is_active
       if source then
          @tid = source.id
       else
          @mode="error"
          @tid=nil
       end


    when "deleted"
        if Source.find(@id).destroy then
          @tid = @id
        else
          @mode="error"
          @tid=nil
       end

    when "updated"
        @source = Source.find(@id)
        if @source.x!=x or @source.y!=y or @source.projection_id!=projection_id then need_convert=true else need_convert=false end
        @source.name = name
        @source.contact_person_id = contact_person_id
        @source.property_address1 = property_address1
        @source.property_address2 = property_address2
        @source.property_address3 = property_address3
        @source.x = x
        @source.y = y
        @source.altitude = altitude
        @source.projection_id = projection_id
        @source.notes = notes
        @source.is_active = is_active
        if need_convert then convert_location_params() end
        if projection_id!=4326 then
          @source.x = @source.x.to_i
          @source.y = @source.y.to_i
        end
        if !@source.save then @mode="error" end

        @tid = @id
    end
  end
end

private
  def source_params
    params.require(:source).permit(:id, :name, :contact_person_id, :property_address1, :property_address2, :property_address3, :location, :x, :y, :altitude, :projection_id, :boundary, :notes, :is_active)
  end


  def convert_location_params
   if(@source.x and @source.y and @source.projection)
       if @source.projection.id!=4326 then 
           x=x.to_i
           y=y.to_i
       end
       # convert to WGS84 (EPSG4326) fro database 
       fromproj4s= @source.projection.proj4
       toproj4s=  Projection.find_by_id(4326).proj4

       fromproj=RGeo::CoordSys::Proj4.new(fromproj4s)
       toproj=RGeo::CoordSys::Proj4.new(toproj4s)

       xyarr=RGeo::CoordSys::Proj4::transform_coords(fromproj,toproj,@source.x,@source.y)

       params[:location]=xyarr[0].to_s+" "+xyarr[1].to_s
       @source.location='POINT('+params[:location]+')'

       # convert to NZTM2000 (EPSG4326) for display 
       fromproj4s= @source.projection.proj4
       toproj4s=  Projection.find_by_id(2193).proj4

       fromproj=RGeo::CoordSys::Proj4.new(fromproj4s)
       toproj=RGeo::CoordSys::Proj4.new(toproj4s)

       xyarr=RGeo::CoordSys::Proj4::transform_coords(fromproj,toproj,@source.x,@source.y)

       @source.x=xyarr[0]
       @source.y=xyarr[1]
       @source.projection_id=2193

       #if altitude is not entered, calculate it from map 
      if @source.altitude.nil? or @source.altitude == 0
         #get alt from map if it is blank or 0
         altArr=Dem30.find_by_sql ["
            select ST_Value(rast, ST_GeomFromText(?,4326))  rid
               from dem30s
               where ST_Intersects(rast,ST_GeomFromText(?,4326));",
               'POINT('+params[:location]+')',
               'POINT('+params[:location]+')']

         @source.altitude=altArr.first.try(:rid).to_i
       end
    end
  end


end
