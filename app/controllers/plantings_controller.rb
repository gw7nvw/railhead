class PlantingsController < ApplicationController
  before_action :signed_in_person

  def index_prep
    whereclause="true"
    if params[:filter] then
      @filter=params[:filter]
      whereclause="is_"+@filter+" is true"
    end

    @plantings=Planting.find_by_sql [ 'select * from plantings where '+whereclause+' order by planting_code DESC' ]
  end
  def index
    index_prep()
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data collection_to_csv(@plantings), filename: "plantings-#{Date.today}.csv" }
    end

  end

  def show
    if(!(@planting = Planting.where(id: params[:id]).first))
      redirect_to '/'
    else
      @collection=@planting.collection
    end
    if(@planting.location==nil and @planting.x and @planting.y and @planting.projection) then
        convert_location_params()
    end

  end
  def edit
    if params[:referring] then @referring=params[:referring] end

    if(!(@planting = Planting.where(id: params[:id]).first))
      redirect_to '/'
    end
    if(@planting.location==nil and @planting.x and @planting.y and @planting.projection) then
        convert_location_params()
    end

  end

  def new
    if params[:referring] then @referring=params[:referring] end
    @planting = Planting.new
  end
  def create
    if signed_in? and current_person.is_modifier then
      @planting = Planting.new(planting_params)
      convert_location_params()
      @planting.createdBy_id=current_person.id
      subcode=1
      while (Planting.find_by_sql [ "select * from plantings where planting_code='"+@planting.planting_code+subcode.to_s+"'" ]).count>0
        subcode+=1
      end
      @planting.planting_code+=subcode.to_s

      if @planting.save
          @planting.reload
          if params[:referring]=='index' then
            index_prep()
            render 'index'
          else
            @collection=@planting.collection
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
      planting = Planting.find_by_id(params[:id])
      if planting and planting.destroy
        flash[:success] = "Planting deleted, id:"+params[:id]
        index_prep()
        render 'index'
      else
        edit()
        render 'edit'
      end
    else
      if(!@planting = Planting.find_by_id(params[:id]))
          flash[:error] = "Planting does not exist: "+@planting.id.to_s

          #tried to update a nonexistant planting
          render 'edit'
      end

      #regenrate id if collection has changed
      planting_code=params[:planting][:planting_code]
      if @planting.seedling_code != params[:planting][:seedling_code] then
          planting_code=params[:planting][:seedling_code]+"."
          subcode=1
          while (Planting.find_by_sql [ "select * from plantings where planting_code='"+planting_code+subcode.to_s+"'" ]).count>0
            subcode+=1
          end
          planting_code+=subcode.to_s
      end

      @planting.assign_attributes(planting_params)      
      convert_location_params()
      @planting.planting_code=planting_code
      @planting.createdBy_id=current_person.id

      if @planting.save
        flash[:success] = "Planting details updated"

        # Handle a successful update.
        if params[:referring]=='index' then
          index_prep()
          render 'index'
        else
          @collection=@planting.collection
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
            plantings = Planting.all.order(:planting_code).reverse

            render :json => {
                 :total_count => plantings.length,
                 :pos => 0,
                 :rows => plantings.map do |planting|
                 {
                   :id => planting.id,
                   :data => [planting.planting_code,planting.seedling_code||"",planting.destination_id||"",planting.dest_description,planting.x,planting.y,planting.altitude,planting.projection_id||"",if planting.date_planted then planting.date_planted.strftime('%d/%m/%Y') else '' end, planting.number_planted, if planting.date_checked then planting.date_checked.strftime('%d/%m/%Y') else '' end, planting.number_survived, planting.notes]
                 }
                 end
            }
  end
def db_action
  if signed_in? and current_person.is_modifier then
    @mode = params["!nativeeditor_status"]
    planting_code = params['c0']
    seedling_code = params['c1']
    destination_id = params['c2']
    dest_description = params['c3']
    x = params['c4']
    y = params['c5']
    altitude = params['c6']
    projection_id = params['c7']
    date_planted = params['c8']
    number_planted = params['c9']
    date_checked = params['c10']
    number_survived = params['c11']
    notes = params['c12']

    @id = params["gr_id"]



    case @mode

    when "inserted"
      planting_code=seedling_code+"."
      subcode=1
      while (Planting.find_by_sql [ "select * from plantings where planting_code='"+planting_code+subcode.to_s+"'" ]).count>0
        subcode+=1
      end
      planting_code+=subcode.to_s

      planting = Planting.create :planting_code => planting_code, :seedling_code => seedling_code,:destination_id => destination_id, :dest_description => dest_description, :x => x, :y => y, :altitude => altitude, :projection_id => projection_id, :date_planted => date_planted, :number_planted => number_planted, :date_checked => date_checked, :number_survived => number_survived, :notes => notes
      if planting then
          @tid = planting.id
      else
          @mode="error"
          @tid=nil
     end

    when "deleted"
        if Planting.find(@id).destroy then
          @tid = @id
        else
          @mode="error"
          @tid=nil
        end

    when "updated"
        @planting = Planting.find(@id)
        if @planting.x!=x or @planting.y!=y or @planting.projection_id!=projection_id then need_convert=true else need_convert=false end

        if @planting.seedling_code != seedling_code then
          planting_code=seedling_code+"."
          subcode=1
          while (Planting.find_by_sql [ "select * from plantings where planting_code='"+planting_code+subcode.to_s+"'" ]).count>0
            subcode+=1
          end
          planting_code+=subcode.to_s
        end
        @planting.planting_code = planting_code
        @planting.seedling_code = seedling_code
        @planting.destination_id = destination_id
        @planting.dest_description = dest_description
        @planting.x = x
        @planting.y = y
        @planting.altitude = altitude
        @planting.projection_id = projection_id
        @planting.number_planted = number_planted
        @planting.date_checked = date_checked
        @planting.number_survived = number_survived
        @planting.notes = notes
        if need_convert then convert_location_params() end
        if projection_id!=4326 then
          @planting.x = @planting.x.to_i
          @planting.y = @planting.y.to_i
        end

        if !@planting.save then @mode="error" end

        @tid = @id
    end
 end
end



  private
  def planting_params
    params.require(:planting).permit(:planting_code, :seedling_code, :destination_id, :dest_description, :date_planted, :number_planted, :date_checked, :number_survived, :notes, :x, :y, :location, :projection_id, :altitude)
  end

  def convert_location_params
   if(@planting.x and @planting.y and @planting.projection)
       if @planting.projection.id!=4326 then
           x=x.to_i
           y=y.to_i
       end
       # convert to WGS84 (EPSG4326) fro database 
       fromproj4s= @planting.projection.proj4
       toproj4s=  Projection.find_by_id(4326).proj4

       fromproj=RGeo::CoordSys::Proj4.new(fromproj4s)
       toproj=RGeo::CoordSys::Proj4.new(toproj4s)

       xyarr=RGeo::CoordSys::Proj4::transform_coords(fromproj,toproj,@planting.x,@planting.y)

       params[:location]=xyarr[0].to_s+" "+xyarr[1].to_s
       @planting.location='POINT('+params[:location]+')'

       # convert to NZTM2000 (EPSG4326) for display 
       fromproj4s= @planting.projection.proj4
       toproj4s=  Projection.find_by_id(2193).proj4

       fromproj=RGeo::CoordSys::Proj4.new(fromproj4s)
       toproj=RGeo::CoordSys::Proj4.new(toproj4s)

       xyarr=RGeo::CoordSys::Proj4::transform_coords(fromproj,toproj,@planting.x,@planting.y)

       @planting.x=xyarr[0]
       @planting.y=xyarr[1]
       @planting.projection_id=2193
       #if altitude is not entered, calculate it from map 
      if !@planting.altitude or @planting.altitude.to_i == 0 then
         #get alt from map if it is blank or 0
         altArr=Dem30.find_by_sql ["
            select ST_Value(rast, ST_GeomFromText(?,4326))  rid
               from dem30s
               where ST_Intersects(rast,ST_GeomFromText(?,4326));",
               'POINT('+params[:location]+')',
               'POINT('+params[:location]+')']

         @planting.altitude=altArr.first.try(:rid).to_i
       end
    end
  end

end
