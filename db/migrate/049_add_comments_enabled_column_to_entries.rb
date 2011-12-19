class AddCommentsEnabledColumnToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :comments_enabled, :boolean, :null => false, :default => true

    # до этого у нас настройки показывать или не показывать комментарии брались из user.settings[:comments_enabled]
    # в предыдущей миграции этот флаг переехал в таблицу `tlog_settings' и его значение было скопировано из user.settings
    #  для каждого пользователя индивидуально. Это добавило свой минус: чтобы отобразить запись на главной странице, нам
    #  нужно залезть в таблицу tlog_settings для каждого пользователя, а она  не подгружается автоматически. Это означает
    #  еще больше селектов.
    # А теперь, когда мы сделали индивидуальное поле у каждой записи, мы можем избежать обращения к tlog_settings, но сейчас
    #  нам нужно правильно скопировать значения
    # Мы должны поставить comments_enabled = true лишь для тех записей которые находятся в тлоге с включенной возможностью комментировать

    # находим все тлоги с включенными комментариями и выставляем comments_enabled = true для каждой записи в этом тлоге
    #  это все можно сделать одним селектом, но я тупой и не знаю как это можно такую штуку написать
    TlogSettings.find(:all, :conditions => 'comments_enabled = 1').each do |tlog|
      Entry.update_all('comments_enabled = 1', "user_id = #{tlog.user_id}")
    end
  end

  def self.down
    remove_column :entries, :comments_enabled
  end
end
