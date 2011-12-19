class Settings::SidebarController < ApplicationController
  before_filter :require_current_user
  before_filter :current_user_eq_current_site
  before_filter :require_confirmed_current_user
  before_filter :preload_section, :preload_element

  before_filter :require_section, :only => [:section_toggle_is_open, :section_destroy, :section_update, :element]
  before_filter :require_element, :only => [:element_delete, :element_update]

  helper :settings
  layout "settings"

  cache_sweeper :sidebar_sweeper, :exclude => [:index]

  def index
    @tlog_settings = current_user.tlog_settings
  end

  # добавляем новую секцию
  def section
    render :nothing => true and return unless request.post?

    @section = SidebarSection.create :name => params[:section][:name], :user => current_user
    respond_to do |wants|
      wants.html {
        if @section.valid?
          flash[:good] = 'Новая секция была успешно добавлена'
        else
          flash[:bad] = "Не удалось добавить новую секцию из-за ошибки: #{@section.errors.on(:name)}"
        end
        redirect_to :action => :index
      }
      wants.js # render section.rjs
    end
  end

  # переключяем флаг закрыта/открыта
  def section_toggle_is_open
    render :nothing => true and return unless request.post?
    @section.toggle!(:is_open)
  end

  # удаляем секцию со всем содержимым
  def section_destroy
    render :nothing => true and return unless request.post?
    @section.destroy
  end

  # обновляем содержимое секции
  def section_update
    render :nothing => true and return unless request.post?
    @section.name = params[:section][:name]
    @section.save
    respond_to do |wants|
      wants.html {
        if @section.valid?
          flash[:good] = 'Имя раздела было изменено'
        else
          flash[:bad] = "Не удалось изменить имя раздела из-за ошибки: #{@section.errors.on(:name)}"
        end
        redirect_to :action => :index
      }
      wants.js # render section_update.rjs
    end
  end

  # переключяем один из чек-боксов. Для вызова этой функции в шаблонах есть специальная
  #  функция sidebar_check_box, которая вызывается примерно следующим образом:
  #    <%= sidebar_check_box :is_open %>
  def toggle_checkbox
    render :nothing => true and return unless request.post?
    @name = params[:name] if %w(is_open hide_tags hide_search hide_calendar hide_messages).include?(params[:name])
    render :text => 'oops, invalid keyword' and return unless @name
    @tlog_settings = current_user.tlog_settings
    @tlog_settings.toggle!("sidebar_#{@name}")
  end

  def element
    require 'pp'
    klass = SidebarElement::TYPES[params[:element][:type]] || SidebarElement::TYPES['default']
    pp @section
    @element = klass.constantize.create :content => params[:element][:content], :section => @section

    pp @element
    respond_to do |wants|
      wants.html {
        if @element.valid?
          flash[:good] = 'Новый элемент был успешно добавлен'
        else
          flash[:bad] = "Не удалось добавить элемент из-за ошибки: #{@element.errors.on(:content)}"
        end
        redirect_to :action => :index
      }
      wants.js # render element.rjs
    end
  end

  def element_delete
    @element.destroy
  end

  def element_update
    render :nothing => true and return unless request.post?
    @element.content = params[:element][:content]
    @element.save

    respond_to do |wants|
      wants.html {
        if @element.valid?
          flash[:good] = 'Элемент был успешно изменен'
        else
          flash[:bad] = "Не удалось значение из-за ошибки: #{@element.errors.on(:content)}"
        end
        redirect_to :action => :index
      }
      wants.js # render element_update.rjs
    end
  end

  # Parameters: {"action"=>"sort", "controller"=>"settings/sidebar", "elements_sidebar_section_15"=>["17", "18", "19"]}
  def sort
    sections = params.select { |key, value| key.starts_with?('elements_sidebar_section_') }
    sections.each do |i|
      section_id = i.first.match('\d+')[0].to_i
      section = SidebarSection.find_by_id_and_user_id(section_id, current_user.id)
      i.last.each_with_index do |element_id, position|
        section.connection.update("UPDATE sidebar_elements SET position = #{position.to_i + 1} WHERE id = #{element_id.to_i} AND sidebar_section_id = #{section_id}")
      end if section
    end
    render :nothing => true
  end

  private
    def preload_section
      @section = SidebarSection.find_by_id_and_user_id(params[:section_id], current_user.id) if params[:section_id]
    end

    def preload_element
      return true unless params[:element_id]
      @element = SidebarElement.find params[:element_id]
      @element.section.user_id == current_user.id
    end

    def require_section
      render :text => ':section_id missing' and return false unless @section
    end

    def require_element
      render :text => ':element_id missing' and return false unless @element
    end
end
