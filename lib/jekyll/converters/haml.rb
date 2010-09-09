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
      ext =~ /haml/i
    end

    def output_ext(ext)
      '.html'
    end

    def convert(content, payload=nil)
      setup
      begin
        haml_engine = Haml::Engine.new(content)
        payload = {} unless payload

        payload.merge!(:testing => 'woohoo')

        haml_engine.render(Object.new, payload)
      rescue StandardError => e
        STDERR.puts 'HAML parsing error: ' + e.message
        raise FatalException
      end
    end
  end

end
