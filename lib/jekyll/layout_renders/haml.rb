module Jekyll
  class HamlLayoutRender < LayoutRender
    safe true
    priority :highest

    def setup
      return if @setup
      require 'haml'
      @setup = true
    rescue LoadError
      STDERR.puts 'You are missing the required library for HAML'
      STDERR.puts '  $ [sudo] gem install haml'
      raise FatalException.new('Missing dependency: haml')
    end

    def do_pre_transform(content, payload, site)
      setup
      content
    end

    def do_layout(content, payload, site)
      setup
      begin
        Haml::Engine.new(content).render(Object.new, payload)
      rescue StandardError => e
        STDERR.puts 'HAML parsing error: ' + e.message
        raise FatalException.new('HAML parsing error')
      end
    end

    def matches(ext)
      ext =~ /haml/i
    end
  end

end
