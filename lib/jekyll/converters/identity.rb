module Jekyll

  class IdentityConverter < Converter
    safe true

    priority :lowest

    def matches(ext)
      true
    end

    def output_ext(ext)
      ext
    end

    def convert(content, payload=nil)
      content
    end

  end

end
