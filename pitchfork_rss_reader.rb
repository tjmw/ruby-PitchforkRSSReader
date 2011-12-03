require 'rubygems'

require 'net/http'
require 'uri'
require 'rss/2.0'

module PitchforkRSSReader

    class PitchforkRSSReader::NewAlbums

        BASE_URL = 'http://feeds.feedburner.com/PitchforkBestNewAlbums?format=xml'

        def initialize
            fetch_content()
            parse_rss()
            create_spotify_links()
        end

        def fetch_content
            @raw_content = Net::HTTP.get(URI.parse(BASE_URL))
        end

        def parse_rss
            @rss_content = RSS::Parser.parse(@raw_content, false)
            puts @rss_content.channel.title
            puts "#{@rss_content.items.size} items"
        end 
        
        private

        attr_reader :raw_content
        attr_reader :rss_content
    end
end
