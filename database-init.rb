require 'rubygems'
require 'sqlite3'
require 'active_record'

DB_NAME = 'music.db'
DB = SQLite3::Database.new(DB_NAME)

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => DB_NAME)

class Band < ActiveRecord::Base
  has_many :band_links
  has_and_belongs_to_many :genres, :join_table => "band_genres"
end

class Genre < ActiveRecord::Base
  has_and_belongs_to_many :bands, :join_table => "band_genres"
end

class BandGenre < ActiveRecord::Base
  # just a humble join table
end

class BandLink < ActiveRecord::Base
  belongs_to :band
  # for the possibly multiple links each band has
end  

# Migrations to create tables in what should be a Rails-friendly form

if !Band.table_exists?
  ActiveRecord::Base.connection.create_table(:bands) do |t|
    t.column :name, :string, :null => false
    t.column :city, :string
    t.column :contact_info, :string
  end
end

if !Genre.table_exists?
  ActiveRecord::Base.connection.create_table(:genres) do |t|
    t.column :name, :string, :unique => true
  end
end

if !BandGenre.table_exists?
  ActiveRecord::Base.connection.create_table(:band_genres, { :id => false}) do |t|
    t.column :band_id, :integer, :null => false
    t.column :genre_id, :integer, :null => false
  end
end

if !BandLink.table_exists?
  ActiveRecord::Base.connection.create_table(:band_links) do |t|
    t.column :band_id, :integer, :null => false
    t.column :url, :string
    t.column :service, :string
  end
end