module WhiteListHelper
  VALID_FLASH_PARAMS = %w(movie allowfullscreen allowscriptaccess wmode flashvars)

  def white_list_html_with_rescue(html, options = {})
    begin
      white_list_html(html, options)
    rescue Exception => ex
      logger.error "> Failed to render the following content"
      logger.error html
      logger.error "> Exception was: #{ex.message}"
      
      "внутреняя ошибка сервера"
    end
  end

  def white_list_html(html, options = {})
    html.gsub!('&amp;', '&')
    html.gsub!('amp;', '')
    
    flash_width = options[:flash_width] || 400
    
    doc = Hpricot(simple_tasty_format(html), :xhtml_strict => true)

    # Делаем сканирование элементов
    allowed_tags = %w(a b i img p strong ul ol li h1 h2 h3 h4 h5 h6 div object param)
    allowed_attributes = %w(class id href alt src width height border tag name value)
    valid_links = /^http(s?):\/\//
    
    doc = Hpricot(sanitize(doc.to_html, :tags => allowed_tags, :attributes => allowed_attributes), :xhtml_strict => true)

    # Удаляем пустые параграфы
    (doc/"//p[text()='']").remove
    
    (doc/"//p").each do |paragraph|
      paragraph.children.select {|e| e.text?}.each do |text|
        new_text = auto_link(text.to_html).
        # [andrewzotov] -> ссылка на пользователя
        # link_to_user здесь не работает, потому что lameditize вызвыается из моделей
        gsub(/(\[([a-z0-9_-]{2,20})\])/) do
          user = User.find_by_url($2)
          user ? "<a href='#{host_for_tlog(user.url)}' class='entry_tlog_link'>#{user.url}</a>" : $1
        end.
        gsub(/(\n+)/, "<br/>")
        text.swap(new_text) unless new_text.blank?        
      end
    end
    
    (doc/"//object").each do |flash|

      width  = flash.attributes['width'].to_i
      height = flash.attributes['height'].to_i
      src    = flash.attributes['src']
      
      if width > flash_width
        height = (width / flash_width) * height
        width = flash_width
      end

      embed_params = {'allowfullscreen' => "true", "allowscriptaccess" => "always"}
      # processing params
      (flash/"//param").each do |param|
        if VALID_FLASH_PARAMS.include?(param.attributes['name'].downcase)
          embed_params[param.attributes['name'].downcase] = param.attributes['value']
        end
      end      
      src ||= embed_params["movie"]

      if allowed_flash_domain?(src)
        text = <<-HTML
          <object width="#{width}" height="#{height}">
            %s
            <embed src="#{src}" type="application/x-shockwave-flash" %s width="#{width}" height="#{height}"></embed>
          </object>
        HTML
        text = text % [embed_params.map{|name, value| "<param name='#{name}' value='#{value}'></param>"}.join,
                       embed_params.except('movie').map{|name, value| "#{name}='#{value}'"}.join(" ")]

        if flash.css_path.include?(" p ") || flash.css_path.include?("p:")
          flash.swap(text)
        else
          flash.swap("<p>#{text}</p>")
        end
      else
        flash.innerHTML = '<p>К сожалению, с этого домена нельзя размещать видео или флеш</p>'
        # flash.swap("")
      end
    end
    
    html = auto_link(doc.to_html.gsub(/<p>\s*?<\/p>/mi, ''))
  
    # logger.debug html
  
    html    
  end

  def allowed_flash_domain?(url)
    domain = URI.parse(url).try(:host).to_s.split(".").reverse[0,2].reverse.join(".") rescue nil
    return false unless domain
    
    flash_whitelist_file = File.join(RAILS_ROOT, 'config', 'flash_whitelist.yml')
    flash_whitelist = YAML.parse_file(flash_whitelist_file).children.map(&:value)
    flash_whitelist.is_a?(Array) && flash_whitelist.include?(domain)
  end

end