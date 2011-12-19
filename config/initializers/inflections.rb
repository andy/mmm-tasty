# Add new inflection rules using the following format
# (all these examples are active by default):

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'fave', 'faves'
  #   inflect.plural /^(ox)$/i, '\1en'
  #   inflect.singular /^(ox)en/i, '\1'
  #   inflect.irregular 'person', 'people'
  #   inflect.uncountable %w( fish sheep )
end