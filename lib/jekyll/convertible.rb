# Convertible provides methods for converting a pagelike item
# from a certain type of markup into actual content
#
# Requires
#   self.site -> Jekyll::Site
#   self.content
#   self.content=
#   self.data=
#   self.ext=
#   self.output=
module Jekyll
  module Convertible
    # Return the contents as a string
    def to_s
      self.content || ''
    end

    # Read the YAML frontmatter
    #   +base+ is the String path to the dir containing the file
    #   +name+ is the String filename of the file
    #
    # Returns nothing
    def read_yaml(base, name)
      self.content = File.read(File.join(base, name))

      if self.content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
        self.content = self.content[($1.size + $2.size)..-1]

        self.data = YAML.load($1)
      end

      self.data ||= {}
    end

    # Transform the contents based on the content type.
    #
    # Returns nothing
    def transform(payload=nil)
      self.content = converter.convert(self.content, payload)
    end

    # Determine the extension depending on content_type
    #
    # Returns the extensions for the output file
    def output_ext
      converter.output_ext(self.ext)
    end

    # Determine which converter to use based on this convertible's
    # extension
    def converter
      @converter ||= self.site.converters.find { |c| c.matches(self.ext) }
    end

    def layout_renderer(ext=self.ext)
      @renderer ||= {}
      @renderer[ext] ||= self.site.layout_renders.find { |c| c.matches(ext) }
    end

    # Add any necessary layouts to this convertible document
    #   +layouts+ is a Hash of {"name" => "layout"}
    #   +site_payload+ is the site payload hash
    #
    # Returns nothing
    def do_layout(payload, layouts)
      payload['pygments_prefix'] = converter.pygments_prefix
      payload['pygments_suffix'] = converter.pygments_suffix

      self.content = layout_renderer.do_pre_transform(self.content, payload, self.site)
      self.transform(payload)
      self.output = self.content
      layout = layouts[self.data['layout']]
      while layout
        payload = payload.deep_merge({
          "content" => self.output,
          "page" => layout.data
        })
        self.output = layout_renderer(layout.ext).do_layout(layout.content, payload, self.site)
        layout = layouts[layout.data['layout']]
      end
    end
  end
end
