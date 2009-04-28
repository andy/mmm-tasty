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
    
    doc = Hpricot(simple_tasty_format(html), :fixup_tags => true)

    # Делаем сканирование элементов
    allowed_tags = %w(a b i br img p strong em ul ol li h1 h2 h3 h4 h5 h6 div object param)
    allowed_attributes = %w(class id href alt src width height border tag name value)
    
    doc = Hpricot(sanitize(doc.to_html, :tags => allowed_tags, :attributes => allowed_attributes), :fixup_tags => true)

    # Удаляем пустые параграфы
    # (doc/"//p[text()='']").remove    
    
    (doc/"//p").each do |paragraph|
      next if paragraph.children.blank?

      paragraph.children.select { |e| e.text? }.each do |text|
        new_text = auto_link(text.to_html).
        # [andy] -> ссылка на пользователя
        gsub(/(\[([a-z0-9_-]{2,20})\])/) do
          user = User.find_by_url($2)
          user ? "<a href='#{host_for_tlog(user.url)}' class='entry_tlog_link'>#{user.url}</a>" : $1
        end
        text.swap(new_text) unless new_text.blank?        
      end
    end
    
    (doc/"//object").each do |flash|
      
      width  = flash.attributes['width'].to_i || flash_width
      height = flash.attributes['height'].to_i || flash_width
      src    = flash.attributes['src']
      
      if width > flash_width
        height = ((flash_width / width.to_f) * height.to_f).to_i
        width = flash_width
      end

      embed_params = {'allowfullscreen' => 'true', 'allowscriptaccess' => 'never'}
      # processing params
      (flash/"//param").each do |param|
        if VALID_FLASH_PARAMS.include?(param.attributes['name'].downcase)
          embed_params[param.attributes['name'].downcase] = param.attributes['value']
        end
      end      
      src ||= embed_params["movie"]

      if allowed_flash_domain?(src)
        text = "<object width='#{width}' height='#{height}'>#{embed_params.map{|name, value| "<param name='#{name}' value='#{value}'></param>"}.join}<embed src='#{src}' type='application/x-shockwave-flash' #{embed_params.except('movie').map{|name, value| "#{name}='#{value}'"}.join(" ")} width='#{width}' height='#{height}'></embed></object>"

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