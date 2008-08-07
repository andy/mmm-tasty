module AdminHelper
  #
  # <%= menu_item "Тип тлога", :blah, %w(blah index gah)
  # <%= menu_item
  def menu_item(name, url, selected_action = nil, &block)
    link_options = {}
    action = url.to_s.split('/').last
    url = admin_url(:action => url.to_s) unless url.to_s.starts_with?('http://')
    selected_action = action if selected_action.nil?

    selected_action = selected_action.to_a unless selected_action.is_a?(Array)
    link_options[:class] = 'selected' if selected_action.include?(params[:action]) || selected_action.include?([params[:controller], params[:action]].join('/'))

    if block_given?
      content = capture(&block)
      concat(content_tag(:li, link_to(name, url, link_options) + content_tag(:ul, content)), block.binding)
    else
      content_tag :li, link_to(name, url, link_options)
    end
  end
end
