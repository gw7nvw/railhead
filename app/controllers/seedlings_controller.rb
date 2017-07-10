class SeedlingsController < ApplicationController
  before_action :signed_in_person

  def index_prep
    whereclause="true"
    if params[:filter] then
      @filter=params[:filter]
      whereclause="is_"+@filter+" is true"
    end

    @seedlings=Seedling.find_by_sql [ 'select * from seedlings where '+whereclause+' order by seedling_code DESC' ]
  end
  def index
    index_prep()
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data collection_to_csv(@seedlings), filename: "seedlings-#{Date.today}.csv" }
    end

  end

  def show
    if(!(@seedling = Seedling.where(id: params[:id]).first))
      redirect_to '/'
    else
      @collection=@seedling.collection
    end
  
  end
  def edit
    if params[:referring] then @referring=params[:referring] end

    if(!(@seedling = Seedling.where(id: params[:id]).first))
      redirect_to '/'
    end
  end

  def new
    if params[:referring] then @referring=params[:referring] end
    @seedling = Seedling.new
  end

  def create
    if signed_in? and current_person.is_modifier then
      @seedling = Seedling.new(seedling_params)
      @seedling.createdBy_id=current_person.id
      subcode=1
      while (Seedling.find_by_sql [ "select * from seedlings where seedling_code='"+@seedling.seedling_code+subcode.to_s+"'" ]).count>0
        subcode+=1
      end
      @seedling.seedling_code+=subcode.to_s

      if @seedling.save
          @seedling.reload
          if params[:referring]=='index' then
            index_prep()
            render 'index'
          else
            @collection=@seedling.collection
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
      seedling = Seedling.find_by_id(params[:id])
      if seedling and seedling.destroy
        flash[:success] = "Seedling deleted, id:"+params[:id]
        index_prep()
        render 'index'
      else
        edit()
        render 'edit'
      end
    else
      if(!@seedling = Seedling.find_by_id(params[:id]))
          flash[:error] = "Seedling does not exist: "+@seedling.id.to_s

          #tried to update a nonexistant seed
          render 'edit'
      end

      #regenrate id if collection has changed
      seedling_code=params[:seedling][:seedling_code]
      if @seedling.seed_code != params[:seedling][:seed_code] then
          seedling_code=params[:seedling][:seed_code]+"."
          subcode=1
          while (Seedling.find_by_sql [ "select * from seedlings where seedling_code='"+seedling_code+subcode.to_s+"'" ]).count>0
            subcode+=1
          end
          seedling_code+=subcode.to_s
      end

      @seedling.assign_attributes(seedling_params)
      @seedling.seedling_code=seedling_code
      @seedling.createdBy_id=current_person.id

      if @seedling.save
        flash[:success] = "Seedling details updated"

        # Handle a successful update.
        if params[:referring]=='index' then
          index_prep()
          render 'index'
        else
          @collection=@seedling.collection
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
            seedlings = Seedling.all.order(:seedling_code).reverse

            render :json => {
                 :total_count => seedlings.length,
                 :pos => 0,
                 :rows => seedlings.map do |seedling|
                 {
                   :id => seedling.id,
                   :data => [seedling.seedling_code,seedling.seed_code||"",if seedling.date_potted then seedling.date_potted.strftime('%d/%m/%Y') else '' end, seedling.number_potted, seedling.number_died, seedling.current_stock, seedling.notes, seedling.is_active]
                 }
                 end
            }
  end

def db_action
  if signed_in? and current_person.is_modifier then
    @mode = params["!nativeeditor_status"]
    seedling_code = params['c0']
    seed_code = params['c1']
    date_potted = params['c2']
    number_potted = params['c3']
    number_died = params['c4']
    current_stock = params['c5']
    notes = params['c6']
    is_active = params['c7']
    @id = params["gr_id"]



    case @mode

    when "inserted"
      seedling_code=seed_code+"."
      subcode=1
      while (Seedling.find_by_sql [ "select * from seedlings where seedling_code='"+seedling_code+subcode.to_s+"'" ]).count>0
        subcode+=1
      end
      seedling_code+=subcode.to_s

      seedling = Seedling.create :seedling_code => seedling_code, :seed_code => seed_code,:date_potted => date_potted, :number_potted => number_potted, :number_died => number_died, :current_stock => current_stock, :notes => notes, :is_active => is_active
      if seedling then
          @tid = seedling.id
      else
          @mode="error"
          @tid=nil
     end

    when "deleted"
        if Seedling.find(@id).destroy then
          @tid = @id
        else
          @mode="error"
          @tid=nil
        end

    when "updated"
        @seedling = Seedling.find(@id)
        if @seedling.seed_code != seed_code then
          seedling_code=seed_code+"."
          subcode=1
          while (Seedling.find_by_sql [ "select * from seedlings where seedling_code='"+seedling_code+subcode.to_s+"'" ]).count>0
            subcode+=1
          end
          seedling_code+=subcode.to_s
        end
        @seedling.seedling_code = seedling_code
        @seedling.seed_code = seed_code
        @seedling.date_potted = date_potted
        @seedling.number_potted = number_potted
        @seedling.number_died = number_died
        @seedling.current_stock = current_stock
        @seedling.notes = notes
        @seedling.is_active = is_active
        if !@seedling.save then @mode="error" end

        @tid = @id
    end
 end
end



  private
  def seedling_params
    params.require(:seedling).permit(:seedling_code, :seed_code, :date_potted, :number_potted, :number_died, :current_stock, :notes, :is_active)
  end


end
