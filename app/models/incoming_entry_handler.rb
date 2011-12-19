class IncomingEntryHandler < ActionMailer::Base
  ATTACHMENTS = {
    :image => /^image\/(jpeg|jpg|gif|png)$/i,
    :song => /^audio\/mp3$/i
  }

  def receive(email)
    logger.warn "? Info: email object is #{email.inspect}"

    # иногда какая-то фигня с адресом... пропускаем такие письма
    unless email.to
      logger.warn "- Error: skipping email, recipient not found ('to:' empty)"
      return false
    end

    if email.to.include?("post@mmm-tasty.ru")
      keyword = email.subject.strip
    else
      keyword = email.to.first.split('@')[0] rescue nil
    end

    if keyword.nil? || !mobile_settings = MobileSettings.find_by_keyword(keyword)
      logger.warn "- Error: authentication failed for email from #{email.from.nil? ? '(nil)' : email.from.join(',')} to #{email.to.nil? ? '(nil)' : email.to.join(',')} with subject #{email.subject}"
      return false
    end


    user = mobile_settings.user
    attachments = {}
    total_attachments = 0

    logger.warn "+ Incoming email for user #{user.url}[#{user.id}]"

    if email.multipart?
      # проходимся рекурсивно и достаем части мультипарт сообщения в один массив
      parts = email.parts
      while parts.find(&:multipart?)
        parts = parts.collect {|part| part.multipart? ? part.parts : part }.flatten
      end
      # теперь находим части в формате text/html, а если таких нет - то в формате text/plain
      body_parts = parts.select {|part| part.content_type.strip.match(/text\/plain/i)} || parts.select {|part| part.content_type.strip.match(/text\/html/)}
      # все что нашли - объединяем в одну длинную строчку
      body = body_parts.collect(&:body).join("\n")
      # ок.. остались аттачи
      ATTACHMENTS.each do |kind, match|
        logger.warn ". Info: looking at attachment of type '#{kind.to_s}'..."
        attachments[kind] = email.attachments.select {|attach| attach.content_type.strip.match(match) }
        logger.warn ". Info: okay, got #{attachments[kind].size} attachments"
        total_attachments += attachments[kind].size
      end if email.has_attachments?
    else
      body = email.body
    end

    Entry.class # okay, this will pre-load the entry.rb file, since you cant know the name from TextEntry


    if total_attachments > 0
      Entry.transaction do
        attachments.each do |kind, attach_list|
          attach_list.each do |attach|
            entry = "#{kind.to_s.capitalize}Entry".constantize.new # "SongEntry".constantize.new
            entry.author = user
            # заменяем дивы на параграфы
            body = body.gsub(/<div[^>]*>/, '<p>').gsub('</div>', '</p>') unless body.blank?
            entry.data_part_2 = body
            entry.has_attachment = true
            entry.comments_enabled = user.tlog_settings.comments_enabled?
            entry.visibility = user.tlog_settings.default_visibility
            # не позволяем вот так через мыло на главную добавлять
            entry.visibility = 'public' if entry.visibility == 'voteable' || entry.visibility == 'mainpageable'
            entry.save
            if entry.valid?
              logger.warn "+ Created new #{entry.class}, id##{entry.id}"
              logger.warn "+   adding attachment..."
              attachment = Attachment.create :uploaded_data => attach, :user => user, :entry => entry
              logger.warn "+   okay, done, attachment id ##{attachment.id}"
            else
              logger.warn "- Failed to create new entry, validation errors, attachment dropped"
            end
          end
        end
      end
    else
      subject, body = body.split("\n", 2).map(&:strip)
      body, subject = subject, body if body.blank? # меняем местами если приходит одна строчка

      entry = TextEntry.new
      entry.author = user
      entry.has_attachment = false
      entry.comments_enabled = user.tlog_settings.comments_enabled?
      entry.visibility = user.tlog_settings.default_visibility
      # не позвоялем вот так через мыло на главную добавлять
      entry.visibility = 'public' if entry.visibility == 'voteable' || entry.visibility == 'mainpageable'
      entry.data_part_2 = subject
      entry.data_part_1 = body
      entry.save
      if entry.valid?
        logger.warn "+ Created new #{entry.class}, id##{entry.id}"
      else
        logger.warn "+ Failed to create new entry, validation errors"
      end
    end
    logger.warn "+ Done"
    true
  end
end