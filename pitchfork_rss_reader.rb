require 'rubygems'
require 'net/http'
require 'uri'
require 'rss/2.0'
require 'htmlentities'

module PitchforkRSSReader

    class PitchforkRSSReader::Base

        attr_reader :items

        def initialize
            @items = []

            fetch_content()
            parse_rss()
            build_items()
        end

        private

        attr_reader :raw_content
        attr_reader :rss_content
        attr_reader :feed_url

        def fetch_content
            @raw_content = Net::HTTP.get(URI.parse(@feed_url))
        end

        def parse_rss
            @rss_content = RSS::Parser.parse(@raw_content, false)
        end 
      
        def decode(encoded)
            HTMLEntities.new.decode(encoded)
        end 

    end

    class PitchforkRSSReader::BestNewAlbums < PitchforkRSSReader::Base

        def initialize
            @feed_url = 'http://feeds.feedburner.com/PitchforkBestNewAlbums?format=xml'
            super
        end

        private

        def parse_artist_and_title(artist_and_title)
            artist_and_title.gsub!(/(^\s+|\s+$)/, '') 
            artist, title = artist_and_title.split(/\n-/)
            
            if artist
                artist = decode(artist)
                artist.gsub!(/\n/, '')
            end

            if title
                title = decode(title)
                title.gsub!(/\n/, '')
            end

            return artist, title
        end

        def build_items
            @rss_content.items.each do |item|
                artist, title = parse_artist_and_title(item.title)

                @items << PitchforkRSSReader::Item::Album.new(
                    :title  => title,
                    :artist => artist
                )
            end
        end

    end

    class PitchforkRSSReader::BestNewTracks < PitchforkRSSReader::Base

        def initialize
            @feed_url = 'http://feeds.feedburner.com/PitchforkBestNewTracks?format=xml'
            super
        end

        private

        def parse_artist_and_title(artist_and_title)
            artist, title = artist_and_title.split(/\s*-\s*/)

            if artist
                artist = decode(artist)
                artist.gsub!(/\n/, '')
            end

            if title
                title = decode(title)
                title.gsub!(/["\n]/, '')
            end

            return artist, title
        end

        def build_items
            @rss_content.items.each do |item|
                artist, title = parse_artist_and_title(item.title)

                @items << PitchforkRSSReader::Item::Track.new(
                    :title  => title,
                    :artist => artist
                )
            end
        end

    end

    class PitchforkRSSReader::Item

        attr_reader :title
        attr_reader :artist

        def initialize(args)
            @title  = args[:title] 
            @artist = args[:artist] 
        end

    end

    class PitchforkRSSReader::Item::Album < PitchforkRSSReader::Item

    end

    class PitchforkRSSReader::Item::Track < PitchforkRSSReader::Item

    end

end
