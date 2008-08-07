module PublishHelper
  def empty_bookmarklet_url_options(options={})
    options = %w(url title c tags vis autosave).inject(options) { |opts, k| opts.update("bm[#{k}]" => nil) } if in_bookmarklet?
    options
  end

  def bookmarklet_url_options(options={})
    options = %w(url title c tags vis autosave).inject(options) { |opts, k| opts.update("bm[#{k}]" => params[:bm][k]) } if in_bookmarklet?
    options
  end
end
