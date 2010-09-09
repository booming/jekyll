module Jekyll

  class LiquidLayoutRender < LayoutRender
    safe true
    priority :high

    def do_pre_transform(content, payload, site)
      do_layout(content, payload, site)
    end

    def do_layout(content, payload, site)
      info = { :filters => [Jekyll::Filters], :registers => { :site => site } }
      Liquid::Template.parse(content).render(payload, info)
    end

    def matches(ext)
      # For now, we're safe to use this renderer for anything other than HAML.
      ext !=~ /haml/i
    end
  end

end
