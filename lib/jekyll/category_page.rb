module Jekyll

  class CategoryPage < Page

    def initialize(site, base, dir, name, info={})
      @site = site
      @base = base
      @dir  = dir
      @template_name = name
      @name = "index#{File.extname(name)}"
      @category, @posts = info.delete(:category), info.delete(:posts)

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), @template_name)

      self.data['category'] = @category
      self.data['posts'] = @posts
      if self.data['title']
        self.data['title'] = {
          'cat' => @category,
          'category' => @category,
        }.inject(self.data['title']) do |result, token|
          result.gsub(/%#{Regexp.escape token.first}%/, token.last.to_s)
        end
      end
    end

    def dir
      File.dirname(url)
    end

    def template
      case self.site.category_permalink_style
      when :pretty
        "/:category/"
      when :none
        "/:category:output_ext"
      else
        self.site.category_permalink_style.to_s
      end
    end

    def url
      @url ||= {
        "category"   => @category.downcase.gsub(/[^a-zA-Z0-9\.\-]/, '-'),
        "output_ext" => self.output_ext,
      }.inject(template) { |result, token|
        result.gsub(/:#{token.first}/, token.last)
      }.gsub(/\/\//, "/")
    end

    # Write the generated post file to the destination directory.
    #   +dest+ is the String path to the destination dir
    #
    # Returns nothing
    def write(dest)
      FileUtils.mkdir_p(File.join(dest, dir))

      # The url needs to be unescaped in order to preserve the correct filename
      path = File.join(dest, CGI.unescape(self.url))

      if template[/\.html$/].nil?
        FileUtils.mkdir_p(path)
        path = File.join(path, "index.html")
      end

      File.open(path, 'w') do |f|
        f.write(self.output)
      end
    end
  end

end
