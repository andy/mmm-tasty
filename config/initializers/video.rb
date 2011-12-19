module Video
  def self.detect_by_link(link)
    return 'Video::Youtube' if Video::Youtube.recognize?(link)
    return 'Video::Google' if Video::Google.recognize?(link)
    return 'Video::Rutube' if Video::Rutube.recognize?(link)
    return 'Video::Embed' if Video::Embed.recognize?(link)
    nil
  end

  # http://youtube.com/
  module Youtube
    def self.recognize?(link)
      return true if link =~ /^http:\/\/?(|ru\.|uk\.|www\.)?youtube.com\/((v\/([^&\/\?\ ]{7,20}))|(watch\?v=([^&\/\?\ ]{7,20})))/
      false
    end

    def embeddable?; true end
    def white_list?; false end

    def to_embed(options=nil)
      options ||= {}

      embed_url = to_embed_url
      return "cant embed youtube (#{self.data_part_1})" if embed_url.nil?

      if options[:no_js]
        return <<-eof
<object width="425" height="350">
  <param name="movie" value="#{embed_url}"></param>
  <param name="wmode" value="transparent"></param>
  <embed src="#{embed_url}" type="application/x-shockwave-flash" wmode="transparent" width="425" height="350"></embed>
</object>
eof
      else
        return <<-eof
      <div id='tasty_video_embed_#{self.id}'>
  		  Hello, you either have JavaScript turned off or an old version of Macromedia's Flash Player. <a href="http://www.macromedia.com/go/getflashplayer/">Get the latest flash player</a>.
      </div>
      <script type='text/javascript'>
        // <![CDATA[
        var so = new SWFObject("#{to_embed_url}", "tasty_video_embed_#{self.id}_obj", "425", "350", 7, "#FFFFFF");
        so.write("tasty_video_embed_#{self.id}");
        // ]]>
      </script>
eof
      end
    end

    def to_embed_url
      return nil unless video_id = youtube_video_id
      "http://www.youtube.com/v/#{video_id}"
    end

    def to_url
      return self.data_part_1 unless video_id = youtube_video_id
      "http://www.youtube.com/watch?v=#{video_id}"
    end

    private
      def youtube_video_id
        video_id = self.data_part_1.match(/^http:\/\/(|ru\.|uk\.|www\.)?youtube.com\/((v\/([^&\/\?\ ]{7,20}))|(watch\?v=([^&\/\?\ ]{7,20})))/i)
        return nil if video_id.nil?
        video_id[3] || video_id[6] || nil
      end
  end

  module Google
    def self.recognize?(link)
      return true if link =~ /^http:\/\/video.google.com\/videoplay\?docid=([0-9a-z\-]*)/i
      false
    end

    def embeddable?; true end
    def white_list?; false end

    def to_embed(options=nil)
      return <<-eof
<embed width='400px' height='326px' type="application/x-shockwave-flash" src="http://video.google.com/googleplayer.swf?docId=#{google_video_id}&hl=en" flashvars=""> </embed>
eof
    end

    def to_url
      self.data_part_1
    end

    private
      def google_video_id
        self.data_part_1.match(/^http:\/\/video.google.com\/videoplay\?docid=([0-9a-z\-]*)/i)[1]
      end
  end

  # http://rutube.ru/
  module Rutube
    def self.recognize?(link)
      return true if link =~ /^http:\/\/rutube.ru\/tracks\/\d+\.html\?v=([a-f0-9]{32})$/i
      false
    end

    def embeddable?; true end
    def white_list?; false end

    def to_embed(options=nil)
      embed_url = to_embed_url
      '<OBJECT width="400" height="353"><PARAM name="movie" value="' + embed_url + '" /><PARAM name="wmode" value="transparent" /><EMBED src="' + embed_url + '" type="application/x-shockwave-flash" wmode="transparent" width="400" height="353" /></OBJECT>'
    end

    def to_embed_url
      return nil unless video_id = self.data_part_1.match(/^http:\/\/rutube.ru\/tracks\/\d+\.html\?v=([a-f0-9]{32})$/i)[1]
      "http://video.rutube.ru/#{video_id}"
    end

    def to_url
      self.data_part_1
    end
  end

#  module Mailru
#    def self.recognize?(link)
#      return true if link =~
#    end
#  end

  # <embed or | <object video codes
  module Embed
    def self.recognize?(link)
      link.downcase.index('<embed ') != nil
    end

    def embeddable?; true end
    def white_list?; true end
    def to_embed(options=nil); self.data_part_1 end
    def to_url; nil end
  end

  # everything else is unsupported
  module Unknown
    def embeddable?; true end
    def white_list?; false end
    def to_embed(options=nil); 'Неизвестный или неподдерживаемый формат видео' end
    def to_url; 'unknown video' end
  end

end