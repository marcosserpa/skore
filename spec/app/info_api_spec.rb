require 'spec_helper'

RSpec.describe InfoApi do
  def app
    InfoApi
  end

  before(:each) do
    InfoApi.instance_variable_set(:@link, 'https://www.youtube.com/watch?v=i_NjJereUtc')
  end

  let(:link) { 'https://www.youtube.com/watch?v=i_NjJereUtc' }

  describe "#parse_html" do
    context "when received a link" do
      it "must parse HTML content to a Nokogiri object" do
        parsed = InfoApi.parse_html

        expect(parsed.class).to be(Nokogiri::HTML::Document)
        expect(parsed.document.title).to eql("Samba - sequência 1 - YouTube")
      end
    end
  end

  describe "#get_content" do
    context "when passed a YouTube URL" do
      it "must return it's default infos with the video's duration" do
        parsed = InfoApi.parse_html

        expect(InfoApi.get_content(parsed)).to eql({ :title => "Samba - sequência 1 - YouTube", :description => "", :duration => "0 Hours, 0 Minutes, 34 Seconds" })
      end
    end
  end

  describe "GET infos" do
    context "when a YouTube link is passed" do
      it "returns none" do
        get "/info", link: nil

        expect(last_response.body).to eql("<h1>Not Found</h1>")
        expect(last_response.status).to eql(404)
      end
    end

    context "when a YouTube link is passed" do
      it "returns none" do
        get "/info", link: link

        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql("{\"title\":\"Samba - sequência 1 - YouTube\",\"description\":\"\",\"duration\":\"0 Hours, 0 Minutes, 34 Seconds\"}")
      end
    end

    # context "when a non YouTube link is passed" do
    #   it "returns none" do
    #     get '/'
    #
    #     expect(last_response.body).to eql('[]')
    #     expect(last_response.status).to eql(200)
    #   end
    # end
  end
end