class UserSweeper < ActionController::Caching::Sweeper
  observe User
  
  # создается / регистрируется новый пользователь
  def after_create(user)
  end
  
  # пользователь меняет информацию о себе
  def after_update(user)
  end
  
  # пользователь удален
  def after_destroy(user)
  end  
end