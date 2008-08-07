class CommentSweeper < ActionController::Caching::Sweeper
  observe Comment
  
  # создается новая статья
  def after_create(comment)
  end
  
  # пользователь меняет информацию о себе
  def after_update(comment)
  end
  
  # пользователь удален
  def after_destroy(comment)
  end
  
end