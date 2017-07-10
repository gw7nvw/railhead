class MapsController < ApplicationController

def layerswitcher
  @maplayers=Maplayer.all
end

def print
  @papersize=Papersize.all
end

def legend
  load_styles()
  @projections=Projection.all.order(:name)
  if params[:projection] then @projection=params[:projection] else @projection="2193" end

end

def styles
  load_styles()
  respond_to do |format|
      format.js do
      end
  end

end

def load_styles
  if params[:category] then @cat=params[:category] else @cat="routetype" end
  case @cat 

   when "alpinesummer"
     #@items=River.all.order(:difficulty)
   else 
     #@items=Routetype.all.order(:difficulty)
   end
end

end
