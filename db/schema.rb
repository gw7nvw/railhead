# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170702052612) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "areas", force: true do |t|
    t.string  "name"
    t.text    "notes"
    t.spatial "boundary", limit: {:srid=>4326, :type=>"polygon"}
  end

  create_table "collections", force: true do |t|
    t.string   "source_description"
    t.integer  "source_id"
    t.datetime "date"
    t.float    "x"
    t.float    "y"
    t.integer  "altitude"
    t.integer  "projection_id"
    t.string   "no_plants_sampled"
    t.string   "no_collected"
    t.integer  "current_stock"
    t.boolean  "is_seeds",                                                 default: true
    t.boolean  "is_cuttings",                                              default: false
    t.integer  "team_lead_id"
    t.string   "team_members"
    t.string   "species_code"
    t.string   "storage"
    t.text     "notes"
    t.boolean  "is_active",                                                default: true
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "location",           limit: {:srid=>4326, :type=>"point"}
  end

  add_index "collections", ["source_id"], :name => "index_collections_on_source_id"

  create_table "destinations", force: true do |t|
    t.string   "name"
    t.string   "owner"
    t.string   "legal_status"
    t.integer  "contact_person_id"
    t.string   "property_address1"
    t.string   "property_address2"
    t.string   "property_address3"
    t.float    "x"
    t.float    "y"
    t.integer  "projection_id"
    t.integer  "altitude"
    t.text     "notes"
    t.boolean  "is_active",                                                 default: true
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "location",          limit: {:srid=>4326, :type=>"point"}
    t.spatial  "boundary",          limit: {:srid=>4326, :type=>"polygon"}
  end

  create_table "maplayers", force: true do |t|
    t.string   "name"
    t.string   "baseurl"
    t.string   "basemap"
    t.integer  "maxzoom"
    t.integer  "minzoom"
    t.string   "imagetype"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nztcs", force: true do |t|
    t.string "name_and_authority"
    t.string "umbrella_category"
    t.string "conservation_status"
    t.string "trend"
    t.string "qualifiers"
  end

  add_index "nztcs", ["name_and_authority"], :name => "index_nztcs_on_name_and_authority", :unique => true

  create_table "people", force: true do |t|
    t.string   "username"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "mobile"
    t.string   "homephone"
    t.string   "address1"
    t.string   "address2"
    t.string   "address3"
    t.string   "postcode"
    t.boolean  "is_member",         default: false
    t.boolean  "is_active",         default: false
    t.boolean  "is_source",         default: false
    t.boolean  "is_destination",    default: false
    t.boolean  "is_admin",          default: false
    t.boolean  "is_user",           default: false
    t.boolean  "is_modifier",       default: false
    t.string   "password_digest"
    t.string   "remember_token"
    t.string   "activation_digest"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plantings", force: true do |t|
    t.string   "seedling_code"
    t.string   "planting_code"
    t.integer  "destination_id"
    t.string   "dest_description"
    t.float    "x"
    t.float    "y"
    t.integer  "altitude"
    t.integer  "projection_id"
    t.datetime "date_planted"
    t.integer  "number_planted"
    t.datetime "date_checked"
    t.integer  "number_survived"
    t.text     "notes"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "location",         limit: {:srid=>4326, :type=>"point"}
  end

  add_index "plantings", ["destination_id"], :name => "index_plantings_on_destination_id"

  create_table "projections", force: true do |t|
    t.string   "name"
    t.string   "proj4"
    t.string   "wkt"
    t.integer  "epsg"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "seedlings", force: true do |t|
    t.string   "seedling_code"
    t.string   "seed_code"
    t.datetime "date_potted"
    t.integer  "number_potted"
    t.integer  "number_died"
    t.integer  "current_stock"
    t.text     "notes"
    t.boolean  "is_active",     default: true
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "seedlings", ["seedling_code"], :name => "index_seedlings_on_seedling_code", :unique => true

  create_table "seeds", force: true do |t|
    t.integer  "collection_id"
    t.string   "seed_code"
    t.datetime "date_sown"
    t.integer  "number_sown"
    t.boolean  "is_active",     default: true
    t.text     "notes"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "seeds", ["collection_id"], :name => "index_seeds_on_collection_id"
  add_index "seeds", ["seed_code"], :name => "index_seeds_on_seed_code", :unique => true

  create_table "sources", force: true do |t|
    t.string   "name"
    t.text     "notes"
    t.integer  "contact_person_id"
    t.string   "property_address1"
    t.string   "property_address2"
    t.string   "property_address3"
    t.float    "x"
    t.float    "y"
    t.integer  "projection_id"
    t.integer  "altitude"
    t.boolean  "is_active",                                                 default: true
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "location",          limit: {:srid=>4326, :type=>"point"}
    t.spatial  "boundary",          limit: {:srid=>4326, :type=>"polygon"}
  end

  create_table "species", force: true do |t|
    t.string   "code"
    t.string   "genus"
    t.string   "species"
    t.string   "common_name"
    t.string   "nztcs_name"
    t.boolean  "is_active"
    t.integer  "createdBy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "species", ["code"], :name => "index_species_on_code"

  add_foreign_key "collections", "people", name: "collections_createdBy_id_fk", column: "createdBy_id"
  add_foreign_key "collections", "people", name: "collections_team_lead_id_fk", column: "team_lead_id"
  add_foreign_key "collections", "projections", name: "collections_projection_id_fk"
  add_foreign_key "collections", "sources", name: "collections_source_id_fk"

  add_foreign_key "destinations", "people", name: "destinations_contact_person_id_fk", column: "contact_person_id"
  add_foreign_key "destinations", "people", name: "destinations_createdBy_id_fk", column: "createdBy_id"
  add_foreign_key "destinations", "projections", name: "destinations_projection_id_fk"

  add_foreign_key "people", "people", name: "people_createdBy_id_fk", column: "createdBy_id"

  add_foreign_key "plantings", "destinations", name: "plantings_destination_id_fk"
  add_foreign_key "plantings", "people", name: "plantings_createdBy_id_fk", column: "createdBy_id"
  add_foreign_key "plantings", "projections", name: "plantings_projection_id_fk"
  add_foreign_key "plantings", "seedlings", name: "plantings_seedling_code_fk", column: "seedling_code", primary_key: "seedling_code"

  add_foreign_key "projections", "people", name: "projections_createdBy_id_fk", column: "createdBy_id"

  add_foreign_key "seedlings", "people", name: "seedlings_createdBy_id_fk", column: "createdBy_id"
  add_foreign_key "seedlings", "seeds", name: "seedlings_seed_code_fk", column: "seed_code", primary_key: "seed_code"

  add_foreign_key "seeds", "collections", name: "seeds_collection_id_fk"
  add_foreign_key "seeds", "people", name: "seeds_createdBy_id_fk", column: "createdBy_id"

  add_foreign_key "sources", "people", name: "sources_contact_person_id_fk", column: "contact_person_id"
  add_foreign_key "sources", "people", name: "sources_createdBy_id_fk", column: "createdBy_id"
  add_foreign_key "sources", "projections", name: "sources_projection_id_fk"

  add_foreign_key "species", "nztcs", name: "species_nztcs_name_fk", column: "nztcs_name", primary_key: "name_and_authority"
  add_foreign_key "species", "people", name: "species_createdBy_id_fk", column: "createdBy_id"

end
