module Subjoin
  # A JSON-API top level document
  class Document
    include Metable
    include Linkable

    # The document's primary data
    attr_reader :data

    # Resources included in a compound document"
    attr_reader :included

    # JSON-API version information
    attr_reader :jsonapi

    def initialize(*args)
      if args.count == 1
        spec = args[0]
        if spec.is_a?(URI)
          contents = Subjoin::get(spec)
        elsif spec.is_a?(Hash)
          contents = spec
        end
      elsif args.count == 2
        if args[0].is_a?(String) and args[1].is_a?(String)
        end
      else
        raise ArgumentError
      end

      load_meta(contents['meta'])
      load_links(contents['links'])

      if contents.has_key? "included"
        @included = Inclusions.new(
          contents['included'].map{|o| Resource.new(o, self)}
        )
      else
        @included = nil
      end
      
      if contents.has_key?("data")
        if contents["data"].is_a? Hash
          @data = [Resource.new(contents["data"], self)]
        else
          @data = contents["data"].map{|d| Resource.new(d, self)}
        end
      else
        @data = nil
      end

      if contents.has_key?("jsonapi")
        @jsonapi = JsonApi.new(contents["jsonapi"])
      else
        @jsonapi = nil
      end
    end

    # @return [Boolean] true if there is primary data
    def has_data?
      return ! @data.nil?
    end

    # @return [Boolean] true if there are included resources
    def has_included?
      return ! @included.nil?
    end

    # @return [Boolean] true if there is version information
    def has_jsonapi?
      return ! @jsonapi.nil?
    end
  end
end
                   

      
      
