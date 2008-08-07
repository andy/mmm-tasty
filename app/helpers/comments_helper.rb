module CommentsHelper
  def link_to_comment_author(comment, highlight = false)
    if !comment.user.nil?
      html_options = {}
      html_options[:class] = 'highlight' if highlight
      link_to_tlog(comment.user, {}, html_options )
    else
      unless comment.ext_url.blank?
        "<a href=\"#{strip_tags comment.ext_url}\" class=\"comment_author_link\" rel='nofollow'>#{strip_tags comment.ext_username}</a>"
      else
        strip_tags(comment.ext_username) || "internal error on comment id #{comment.id}"
      end
    end
  end
end