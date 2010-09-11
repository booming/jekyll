module Jekyll

  class Archive < Page

    def initialize(site, base, dir, name, posts={})
      @site = site
      @base = base
      @dir  = dir
      # Store the name of the template (e.g archive_yearly.ext)
      @template_name = name
      # We want to change the output name to index.ext
      @name = "index#{File.extname(name)}"
      @posts = process_posts(posts)

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), @template_name)

      # Make data available to the page.
      self.data['posts'] = @posts || []
      year, month, day = dir.split('/')
      self.data['year'] = year.to_i
      self.data['month'] = month.to_i if month
      self.data['day'] = day.to_i if day
      # If we read in a title from the YAML block then it via gsub to replace
      # any dates.
      if self.data['title']
        self.data['title'] = {
          'year' => year,
          'month' => month,
          'str_month' => (month and Date::MONTHNAMES[month]),
          'day' => day,
          'str_day' => (day and Date::DAYNAMES[day])
        }.inject(self.data['title']) do |result, token|
          result.gsub(/%#{Regexp.escape token.first}%/, token.last.to_s)
        end
      end
    end

    private
    def process_posts(posts)
      posts.values.map { |p| p.is_a?(Hash) ? p.values : p }.flatten
    end
  end

end
