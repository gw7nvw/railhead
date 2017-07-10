class AreasController < ApplicationController

  before_action :signed_in_person, except: [:index, :show]


  def index_prep
    whereclause="true"
    if params[:filter] then
      @filter=params[:filter]
      whereclause="is_"+@filter+" is true"
    end

    @areas=Area.find_by_sql [ 'select * from areas where '+whereclause+' order by name' ]
  end

  def index
    index_prep()
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data collection_to_csv(@areas), filename: "areas-#{Date.today}.csv" }
    end

  end

  def show
    if(!(@area = Area.where(id: params[:id]).first))
      redirect_to '/'
    end

  end

  def edit
    if params[:referring] then @referring=params[:referring] end

    if(!(@area = Area.where(id: params[:id]).first))
      redirect_to '/'
    end
  end

  def new
    if params[:referring] then @referring=params[:referring] end
    @area = Area.new
  end

  def create
    if signed_in? and current_person.is_modifier then
      @area = Area.new(area_params)

      if @area.save
          @area.reload
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
      area = Area.find_by_id(params[:id])
      if area and area.destroy
        flash[:success] = "Area deleted, id:"+params[:id]
        index_prep()
        render 'index'
      else
        edit()
        render 'edit'
      end
    else
      if(!@area = Area.find_by_id(params[:id]))
          flash[:error] = "Area does not exist: "+@area.id.to_s

          #tried to update a nonexistant area
          render 'edit'
      end

      @area.assign_attributes(area_params)

      if @area.save
        flash[:success] = "Area details updated"

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
            areas = Area.all.order(:name)

            render :json => {
                 :total_count => areas.length,
                 :pos => 0,
                 :rows => areas.map do |area|
                 {
                   :id => area.id,
                   :data => [area.id,area.name,area.notes]
                 }
                 end
            }
  end

def db_action
  if signed_in? and current_person.is_modifier then
    @mode = params["!nativeeditor_status"]
    id = params['c0']
    name = params['c1']
    notes = params['c2']

    @id = params["gr_id"]


    
    case @mode

    when "inserted"
        area = Area.create :name => name, :notes => notes
       if area then
          @tid = area.id
       else
          @mode="error"
          @tid=nil
       end


    when "deleted"
        if Area.find(@id).destroy then
          @tid = @id
        else
          @mode="error"
          @tid=nil
       end

    when "updated"
        @area = Area.find(@id)
        @area.name = name
        @area.notes = notes
        if !@area.save then @mode="error" end

        @tid = @id
    end
  end
end

private
  def area_params
    params.require(:area).permit(:id, :name, :boundary, :notes)
  end
end

