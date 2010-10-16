# A scraper for Texas music

The Texas Music Office is a part of the Texas Governor's office responsible for promoting the music industry in Texas.

As part of its mission, the office has create an [online directory of Texas bands](http://www.governor.state.tx.us/music/musicians/talent/talent/).

## Have you already scraped the site?

Yes.  The raw scrape produced by my first run of this scraper on October 15, 2010 is included as the file "music.db".

## How is the data organized?

It's a SQLite3 file, with tables created in a Rails-friendly format.

Bands have their name, each URL they have given (such as a myspace page or facebook page), their contact information (a phone number), and the genres that they chose to list.

There are 8255 bands listed, with 11,680 URLs, falling into 263 genres.

I stored the genre information in the classic way that tags are stored.  There is a separate database table for "Genre" and for "BandGenres".  Each different genre name has a unique entry in the Genre table, and each band in that genre has an entry in BandGenre that connects the dots between the band and that genre.  This permits easy searching by Genre, and (like tags) it would permit a user to rapidly tunnel down by Genre.

The genres are a bit confused taxonomically, and a few of them have been cut off mid-word by how the Music Office formatted them.  (For example, "Progressi" appears for one band instead of "Progressive".)

To search by city, you search within the Band table.  There is not (yet) any table that tries to map these city names to more meaningful geolocations.  (And there are 597 different city names in this database.)

## How to use from the command line

If you want to use the data from the command line, make sure you have a working version of Ruby and of the ActiveRecord and SQLite3 gems.  (ActiveRecord is included with Rails.)

Open a terminal window and navigate to the directory holding the files in this repository.  Then:

	irb
	>> require 'database-init'
	>> Band.first
	
And you should see the first listed band.

If you know how to do basic Ruby queries, you can do other queries, such as:

*To see all bands with the genre 'blues'*

	>> Genre.find_by_name("Blues").bands

*To see all bands who list 'Austin' as their city*

	>> Band.find_all_by_city("Austin")

## How to re-run the scraper

You can just run the scraper from the command line:

	ruby scraper.rb
	
That preserves the existing item ids, which is what you want to do if you have built other resources on top of this data.

If you prefer to start with a completely clean database, just delete the music.db database file and run the scraper again.

# Room for improvement

The genres are a bit of a mess in their raw state.

I think it would be useful to take genres such as "Country/Western" and split the entry into those two *separate* genres.  That would avoid getting divergent results for "Country" and "Country/Western."

I also think that an adjustment should be made for the genre names that were clipped off by the formatting of the Music Office's website.  This may require a table of corrections; I don't know an algorithmic way to fix this.

