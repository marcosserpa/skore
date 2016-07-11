require 'sinatra'
require 'net/http'
require 'nokogiri'
require 'iso8601'
require 'json'
require 'pry'

class InfoApi < Sinatra::Base

  # get '/' do
  #   erb :index
  # end

  get '/info' do
    return [404, {}, "<h1>Not Found</h1>"] if !params['link']

    @link = params[:link]
    parsed = InfoApi.parse_html
    content = InfoApi.get_content(parsed)

    content_type :json
    [200, content.to_json]
  end

  class << self

    def parse_html
      uri = URI(@link)
      page = Net::HTTP.get(uri)
      parsed = Nokogiri::HTML(page)
    end

    def get_content(parsed)
      title = parsed.document.title
      description = parsed.document.search("meta[name='description']").first['content']

      # Regex to match YouTube URLs
      regex = /^(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})/

      content = {
        title: title,
        description: description,
        # image: ''
      }

      if @link.match regex
        duration = parsed.document.search("meta[itemprop='duration']").first['content']
        parsed_time = ISO8601::Duration.new(duration)

        content.merge! duration: "#{ parsed_time.hours.atom.round(0) } Hours, #{ parsed_time.minutes.atom.round(0) } Minutes, #{ parsed_time.seconds.atom.round(0) } Seconds"
      end

      content
    end

  end
end