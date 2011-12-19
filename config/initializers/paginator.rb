# модуль который расширяет любой объект и делает его доступным для использования
#  в качестве аргумента для темплейта paginator
module Paginator
  # функции которые определяются в родительском объекте: limit и offset
  def page_count
    (total.to_f / limit.to_f).ceil.to_i
  end

  def next_page
    (offset / limit) + 2
  end

  def next_page?
    offset + limit < total
  end

  def previous_page
    (offset / limit)
  end

  def previous_page?
    offset > 0
  end
end