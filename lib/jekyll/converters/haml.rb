module Jekyll

  class HamlConverter < Converter
    safe true
    priority :lowest

    def matches(ext)
      ext =~ /haml/i && @config['haml']
    end

    def output_ext(ext)
      '.html'
    end

    def convert(content, payload=nil)
      # Try running payload through hashie.
      begin
        payload = Hashie::Mash.new(payload)
      rescue
      end

      begin
        haml_engine = Haml::Engine.new(content, engine_options)
        payload ||= {}
        haml_engine.render(Jekyll::HamlHelpers, payload)
      rescue StandardError => e
        STDERR.puts 'HAML parsing error: ' + e.message
        raise FatalException
      end
    end

    private
    def engine_options
      if @config['haml'].is_a?(Hash)
        # Convert the keys to symbols, for HAML.
        # This means we don't have to store them in YAML like format ::html5.
        @config['haml'].inject({}) do |result, (k,v)|
          result[k.to_sym] = v
        result
        end
      else
        {}
     end
    end
  end

end
