class SidebarElement < ActiveRecord::Base
  belongs_to :section, :class_name => 'SidebarSection', :foreign_key => 'sidebar_section_id'
  validates_length_of :content, :within => 1..8192

  acts_as_list :scope => :sidebar_section

  TYPES = {
    'link' => 'SidebarLinkElement',
    'default' => 'SidebarElement'
  }

  def type_short; 'default' end
  def template_path
    "settings/sidebar/elements/#{type_short}"
  end
end


class SidebarLinkElement < SidebarElement
  validates_format_of :content, :with => Format::LINK, :message => 'неопознанный формат ссылки'
  before_validation :make_link_from_content_if_present

  def type_short; 'link' end

  private
    def make_link_from_content_if_present
      self.content = make_a_link_from_content(self.content)
      true
    end

    def make_a_link_from_content(data)
      return data if data.blank?
      return data if data.strip =~ Format::LINK
      data = 'http://' + data.strip if data.strip.split(/(:|\/)/)[0] =~ Format::DOMAIN
      data
    end
end
