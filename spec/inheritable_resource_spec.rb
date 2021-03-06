require "spec_helper"

module Subjoin
  class ExampleResource < Resource
    include Inheritable
    ROOT_URI="http://example.com"
  end

  class NonStandardUri < ExampleResource
    TYPE_PATH="nonstandard"
  end

  class Articles < ExampleResource
    #TYPE_PATH="articles"
  end

  class ExamplePerson < ExampleResource
    TYPE_PATH="people"
  end

end

describe Subjoin::Inheritable do
  before :each do
    allow_any_instance_of(Faraday::Connection).
      to receive(:get).and_return(double(Faraday::Response, :body => ARTICLE))
  end
  
  it "has a root uri" do
    expect(Subjoin::ExampleResource::ROOT_URI).to eq "http://example.com"
  end
  
  describe "#type_url" do
    it "is a class method" do
      expect(Subjoin::ExampleResource::type_url).to eq URI("http://example.com/exampleresource")
    end
  end
end

describe Subjoin::Document do
  describe "#new" do
    context "with a single string parameter" do
      it "maps derived types" do
        expect_any_instance_of(Faraday::Connection)
          .to receive(:get).with(URI("http://example.com/articles"), {}, Hash)
               .and_return(double(Faraday::Response, :body => ARTICLE))
        Subjoin::Document.new("articles")
      end

      it "returns objects of the right class" do
        expect_any_instance_of(Faraday::Connection).
          to receive(:get).
              and_return(double(Faraday::Response, :body => COMPOUND))

        expect(Subjoin::Document.new("articles").data.first).
          to be_an_instance_of Subjoin::Articles
      end

      it "returns included objects of the right class" do
        expect_any_instance_of(Faraday::Connection).
          to receive(:get).
              and_return(double(Faraday::Response, :body => COMPOUND))
        expect(Subjoin::Document.new("articles").data.first.
                rels["author"].first).
          to be_an_instance_of Subjoin::ExamplePerson
      end

      it "returns Resource objects when there is no mapped type" do
        expect_any_instance_of(Faraday::Connection).
          to receive(:get).
              and_return(double(Faraday::Response, :body => COMPOUND))
        expect(Subjoin::Document.new("articles").data.first.
                rels["comments"].first).
          to be_an_instance_of Subjoin::Resource
      end
    end

    context "with two string parameters" do
      it "maps derived types with the second string as an id" do
        expect_any_instance_of(Faraday::Connection)
          .to receive(:get).with(URI("http://example.com/articles/2"), {}, Hash)
               .and_return(double(Faraday::Response, :body => ARTICLE))
        Subjoin::Document.new("articles", "2")
      end
    end
  end
end

  
