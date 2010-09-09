module Jekyll

  class HamlConverter < Converter
    safe true
    priority :lowest

    def setup
      return if @setup
      require 'haml'
      @setup = true
    rescue LoadError
      STDERR.puts 'You are missing the required library for HAML'
      STDERR.puts '  $ [sudo] gem install haml'
      raise FatalException.new("Missing dependency: haml")
    end

    def matches(ext)
      ext =~ /haml/i && @config['haml']
    end

    def output_ext(ext)
      '.html'
    end

    def convert(content, payload=nil)
      setup
      begin
        haml_engine = Haml::Engine.new(content, engine_options)
        payload = {} unless payload

        payload.merge!(:testing => 'woohoo')

        haml_engine.render(Object.new, payload)
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
