class FilePresenter < ItemPresenter
  def file_icon_path_for(name)
    File.join "/assets/images/file_types", [name, "png"].join('.')
  end

  def file_icon_or_default_path_for(name)
    image = file_icon_path_for(name)
    image = file_icon_path_for("default") unless File.exists?(File.join(Rails.root, "public", image))
    image
  end

  def image_icon(options = {})
    options[:class] = [options[:class], "image_icon"].compact.join(' ')
    options[:src] = image_full_path
    content_tag :img, nil, options
  end

  def image_full_path
    file_icon_or_default_path_for(self.mime_minor)
  end

  def show_path(options = {})
    url_helpers.download_path(item, options)
  end
end
