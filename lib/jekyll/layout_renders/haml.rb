module Jekyll
  class HamlLayoutRender < LayoutRender
    safe true
    priority :highest

    def do_pre_transform(content, payload, site)
      content
    end

    def do_layout(content, payload, site)
      # Try running the payload through hashie.
      begin
        payload = Hashie::Mash.new(payload)
      rescue
      end

      begin
        Haml::Engine.new(content, engine_options).render(Jekyll::HamlHelpers, payload)
      rescue StandardError => e
        STDERR.puts 'HAML parsing error: ' + e.message
        raise FatalException.new('HAML parsing error')
      end
    end

    def matches(ext)
      ext =~ /haml/i && @config['haml']
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
