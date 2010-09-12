module Jekyll::HamlHelpers
  extend Jekyll::Filters
  extend self

  attr_accessor :site

  def partial(template, options={})
    options[:locals] ||= {}

    path = template.to_s.split(File::SEPARATOR)
    ext = File.extname(path[-1])
    template_path = File.join(@site.source, '_includes', path)
    return '' unless File.exists?(template_path)
    contents = IO.read(template_path)

    case ext[1..ext.length]
    when 'haml', 'markdown', 'mkdn', 'md', 'textile'
      if converter = @site.converters.find { |c| c.matches(ext) }
        converters.convert(contents, options[:locals])
      else
        contents
      end
    when 'html'
      Liquid::Template.parse(contents).render(options[:locals])
    else
      contents
    end
  end
  alias :include :partial
end
