require 'rubygems'
require 'net/http'
require 'uri'
require 'rss/2.0'
require 'htmlentities'

module PitchforkRSSReader

    class PitchforkRSSReader::NewAlbums

        BASE_URL = 'http://feeds.feedburner.com/PitchforkBestNewAlbums?format=xml'

        attr_reader :results

        def initialize
            @results       = []

            fetch_content()
            parse_rss()
            build_results()
        end

        private

        attr_reader :raw_content
        attr_reader :rss_content

        def fetch_content
            @raw_content = Net::HTTP.get(URI.parse(BASE_URL))
        end

        def parse_rss
            @rss_content = RSS::Parser.parse(@raw_content, false)
        end 
       
        def build_results
            @rss_content.items.each do |item|
                artist, title = parse_artist_and_title(item.title)

                @results << PitchforkRSSReader::Album.new(
                    :title  => title,
                    :artist => artist
                )
            end
        end

        def parse_artist_and_title(artist_and_title)

            # strip leading/trailing whitespace
            artist_and_title.gsub!(/(^\s+|\s+$)/, '') 

            artist, title = artist_and_title.split(/\n-/)

            if artist
                artist.gsub!(/\n/, '') if artist
                artist = HTMLEntities.new.decode(artist)
            end

            if title
                title.gsub!(/\n/, '') if title
                title = HTMLEntities.new.decode(title)
            end

            return artist, title
        end

    end

    class PitchforkRSSReader::Album

        attr_reader :title
        attr_reader :artist

        def initialize(args)
            @title  = args[:title] 
            @artist = args[:artist] 
        end

    end
end
