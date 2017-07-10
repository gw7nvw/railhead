class SeedsController < ApplicationController

  before_action :signed_in_person

  def index_prep
    whereclause="true"
    if params[:filter] then
      @filter=params[:filter]
      whereclause="is_"+@filter+" is true"
    end

    @seeds=Seed.find_by_sql [ 'select * from seeds where '+whereclause+' order by seed_code DESC' ]
  end
  def index
    index_prep()
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data collection_to_csv(@seeds), filename: "seeds-#{Date.today}.csv" }
    end

  end

  def show
    if(!(@seed = Seed.where(id: params[:id]).first))
      redirect_to '/'
    else
      @collection=@seed.collection
    end
  end

  def edit
    if params[:referring] then @referring=params[:referring] end

    if(!(@seed = Seed.where(id: params[:id]).first))
      redirect_to '/'
    end
  end

  def new
    if params[:referring] then @referring=params[:referring] end
    @seed = Seed.new
  end

  def create
    if signed_in? and current_person.is_modifier then
      @seed = Seed.new(seed_params)
      @seed.createdBy_id=current_person.id
      subcode=1
      while (Seed.find_by_sql [ "select * from seeds where seed_code='"+@seed.seed_code+subcode.to_s+"'" ]).count>0
        subcode+=1
      end
      @seed.seed_code+=subcode.to_s

      if @seed.save
          @seed.reload
          if params[:referring]=='index' then
            index_prep()
            render 'index'
          else
            @collection=@seed.collection
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
      seed = Seed.find_by_id(params[:id])
      if seed and seed.destroy
        flash[:success] = "Seed deleted, id:"+params[:id]
        index_prep()
        render 'index'
      else
        edit()
        render 'edit'
      end
    else
      if(!@seed = Seed.find_by_id(params[:id]))
          flash[:error] = "Seed does not exist: "+@seed.id.to_s

          #tried to update a nonexistant seed
          render 'edit'
      end

      #regenrate id if collection has changed
      seed_code=params[:seed][:seed_code]
      if @seed.collection_id != params[:seed][:collection_id].to_i then
          seed_code=params[:seed][:collection_id]+"."
          puts(":"+seed_code+":")
          subcode=1
          while (Seed.find_by_sql [ "select * from seeds where seed_code='"+seed_code+subcode.to_s+"'" ]).count>0
            subcode+=1
          end
          seed_code+=subcode.to_s
      end

      @seed.assign_attributes(seed_params)
      @seed.seed_code=seed_code
      @seed.createdBy_id=current_person.id

      if @seed.save
        flash[:success] = "Seed details updated"

        # Handle a successful update.
        if params[:referring]=='index' then
          index_prep()
          render 'index'
        else
          @collection=@seed.collection
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
            seeds = Seed.all.order(:seed_code).reverse

            render :json => {
                 :total_count => seeds.length,
                 :pos => 0,
                 :rows => seeds.map do |seed|
                 {
                   :id => seed.id,
                   :data => [seed.seed_code,seed.collection_id||"", if seed.date_sown then seed.date_sown.strftime('%d/%m/%Y') else '' end, seed.number_sown, seed.notes, seed.is_active]
                 }
                 end
            }
  end

def db_action
  if signed_in? and current_person.is_modifier then
    @mode = params["!nativeeditor_status"]
    seed_code = params['c0']
    collection_id = params['c1']
    date_sown = params['c2']
    number_sown = params['c3']
    notes = params['c4']
    is_active = params['c5']

    @id = params["gr_id"]



    case @mode

    when "inserted"
      seed_code=collection_id.to_s+"."
      subcode=1
      while (Seed.find_by_sql [ "select * from seeds where seed_code='"+seed_code+subcode.to_s+"'" ]).count>0
        subcode+=1
      end
      seed_code+=subcode.to_s

      seed = Seed.create :seed_code => seed_code, :collection_id => collection_id,:date_sown => date_sown, :number_sown => number_sown,:notes => notes, :is_active => is_active
      if seed then
          @tid = seed.id
      else
          @mode="error"
          @tid=nil
      end

    when "deleted"
        if Seed.find(@id).destroy then
          @tid = @id
        else
          @mode="error"
          @tid=nil
        end

    when "updated"
        @seed = Seed.find(@id)
        if @seed.collection_id != collection_id.to_i then
          seed_code=collection_id.to_s+"."
          subcode=1
          while (Seed.find_by_sql [ "select * from seeds where seed_code='"+seed_code+subcode.to_s+"'" ]).count>0
            subcode+=1
          end
          seed_code+=subcode.to_s
        end
        @seed.seed_code = seed_code
        @seed.collection_id = collection_id
        @seed.date_sown = date_sown
        @seed.number_sown = number_sown
        @seed.notes = notes
        @seed.is_active = is_active
        if !@seed.save then @mode="error" end

        @tid = @id
    end
  end
end
  private
  def seed_params
    params.require(:seed).permit(:seed_code, :collection_id, :date_sown, :number_sown, :notes, :is_active)
  end


end
