module ApplicationHelper

  def foreign_key(from_table, from_column, to_table)
    constraint_name = "fk_#{from_table}_#{from_column}"
    
    execute %{ALTER TABLE #{from_table}
              ADD CONSTRAINT #{constraint_name}
              FOREIGN KEY (#{from_column})
              REFERENCES #{to_table}(id)}
  end
  
  def drop_foreign_key(from_table, from_column, to_table)
    constraint_name = "fk_#{from_table}_#{from_column}"
    
    execute %{ALTER TABLE #{from_table}
              DROP CONSTRAINT #{constraint_name}}
  end

  def convert_location_params_global(source)
   if(source.x and source.y and source.projection)
       if source.projection.id!=4326 then
           x=x.to_i
           y=y.to_i
       end
       # convert to WGS84 (EPSG4326) fro database 
       fromproj4s= source.projection.proj4
       toproj4s=  Projection.find_by_id(4326).proj4

       fromproj=RGeo::CoordSys::Proj4.new(fromproj4s)
       toproj=RGeo::CoordSys::Proj4.new(toproj4s)

       xyarr=RGeo::CoordSys::Proj4::transform_coords(fromproj,toproj,source.x,source.y)

       locarr=xyarr[0].to_s+" "+xyarr[1].to_s
       source.location='POINT('+locarr+')'

       # convert to NZTM2000 (EPSG4326) for display 
       fromproj4s= source.projection.proj4
       toproj4s=  Projection.find_by_id(2193).proj4

       fromproj=RGeo::CoordSys::Proj4.new(fromproj4s)
       toproj=RGeo::CoordSys::Proj4.new(toproj4s)

       xyarr=RGeo::CoordSys::Proj4::transform_coords(fromproj,toproj,source.x,source.y)

       source.x=xyarr[0]
       source.y=xyarr[1]
       source.projection_id=2193

      #if altitude is not entered, calculate it from map 
      if source.altitude.nil? or source.altitude == 0
         #get alt from map if it is blank or 0
         altArr=Dem30.find_by_sql ["
            select ST_Value(rast, ST_GeomFromText(?,4326))  rid
               from dem30s
               where ST_Intersects(rast,ST_GeomFromText(?,4326));",
               'POINT('+locarr+')',
               'POINT('+locarr+')']

         source.altitude=altArr.first.try(:rid).to_i
       end
    end
    source
  end

end
