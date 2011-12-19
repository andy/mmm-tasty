class EntryTagsController < ApplicationController
  before_filter :require_entry, :require_current_site, :current_user_eq_current_site

  # добавляем тег к записи
  def create
    old_tags = @entry.tags.dup
    @entry.tag_list.add(params[:tag_list].split(','))
    @entry.update_tags
    new_tags = @entry.tags - old_tags

    render :update do |page|
      page.replace_html "emd_#{@entry.id}", :partial => 'tlog/metadata', :locals => { :entry => @entry }
      new_tags.each do |tag|
        page.visual_effect :highlight, "t#{tag.id}e#{@entry.id}", :duration => 0.3
      end
      page[@entry.dom_id(:input)].value = ''
    end
  end

  # удаляем тег из этой записи
  def destroy
    tag = Tag.find(params[:id])
    if tag && @entry.tag_list.remove(tag.name) && @entry.update_tags
      # обновляем вручную, потому что иначе придется делать @entry.save, а это слишком накладно
      # @entry.connection.update("UPDATE #{@entry.class.table_name} SET #{@entry.class.cached_tag_list_column_name} = '#{@entry.tag_list.to_s.sequelize}' WHERE id = #{@entry.id}")
      render :update do |page|
        page.visual_effect :fade, "t#{tag.id}e#{@entry.id}", :duration => 1.0
        page.visual_effect :fade, "t#{tag.id}e#{@entry.id}_c", :duration => 1.0
      end
    else
      render :nothing => true
    end
  end

  private
    def require_entry
      @entry = Entry.find_by_id_and_user_id params[:entry_id], current_site.id
    end
end