module ApplicationHelper
  def upload_icon(upload)
    content_tag :img, nil, src: upload_icon_or_default_path_for(upload.mime_minor)
  end

  def upload_icon_path_for(name)
    File.join "/assets/file_types", [name, "png"].join('.')
  end

  def upload_icon_or_default_path_for(name)
    image = upload_icon_path_for(name)
    image = upload_icon_path_for("default") unless File.exists?(File.join(Rails.root, "public", image))
    image
  end

end
