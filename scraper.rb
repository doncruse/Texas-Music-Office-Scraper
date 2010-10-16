require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'nokogiri'
# require 'active_record'

require 'database-init'

SLEEP_INTERVAL = 8
  # seconds between loading pages
  # set to 10 for production

  ## Start with Texas Music Office root document
  ## to get the current alphabetical index
  ###############

root_doc = Nokogiri::HTML(open("http://www.governor.state.tx.us/music/musicians/talent/talent/"))

urls_to_hit = Array.new
root_doc.xpath('//a').each do |one_link|
  next unless one_link['href']
  next unless one_link["href"].match(/^http:\/\/governor.state.tx.us\/music\/musicians\/talent/)
  urls_to_hit << one_link["href"]
end
urls_to_hit.uniq!

puts "Going to retrieve #{urls_to_hit.size} pages."
puts
sleep SLEEP_INTERVAL

  ## Now, for each of those pages, retrieve the page and go through
  ## the bands in the table.
  #################

urls_to_hit.each do |band_page_url|

  begin
    band_page = Nokogiri::HTML(open(band_page_url))
    next unless band_page
  rescue
    # should probably throw an error instead for debugging purposes
    next
  end
    
  band_page.xpath('//table/tr').each do |one_row|
    cells = one_row.xpath('td')
    band_name = cells[0].text.split("~")[0].strip
    band_city = cells[1].text.strip
    genres = cells[2].text.split(",").map { |x| x.gsub("^ ","").strip }
    band_contact = cells[3].text.strip
    band_links = cells[0].children.map { |x| x["href"] }.select { |x| !x.nil? }

      # Looking up by both band and city to disambiguate possible duplicates
      # But this complicates how we'd work with later updates to the data...
    unless band_in_database = Band.find_by_name_and_city(band_name, band_city)
      band_in_database = Band.create(:name => band_name, :city => band_city)
    end

    # update the contact information
    band_in_database.contact_info = band_contact
    band_in_database.save
    # For genres:
    # 1. add new genres to the database

    existing_genres = band_in_database.genres
    unless (genres.nil? or (genres.size == 0))
      genres.each do |genre|  
        unless Genre.find_by_name(genre)
          Genre.create(:name => genre)
        end
        BandGenre.create(:band_id => band_in_database.id, 
                         :genre_id => Genre.find_by_name(genre).id )
      end
    end
    
    # 2. clean out genres that have been removed from the database

    existing_genres.each do |existing|
      next if genres.include?(existing.name)
      existing.destroy
        # should be operating on the BandGenre model
    end

    # For band links, sync to the database
    existing_band_links = band_in_database.band_links

    unless band_links.nil?
      band_links.each do |new_link|
        next if existing_band_links.map(&:url).include?(new_link)
        BandLink.create(:band_id => band_in_database.id, :url => new_link)
      end
    end

    unless existing_band_links.nil?
      existing_band_links.each do |old_link|
        next if band_links.include?(old_link.url)
        old_link.destroy
      end
    end
    puts band_in_database.name

  end
  puts "===> Now sleeping..."
  sleep SLEEP_INTERVAL
  
end