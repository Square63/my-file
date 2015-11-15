module ApplicationHelper
  def upload_icon(upload)
    path = "/assets/file_types"
    mime_minor = upload.mime_minor.present? && upload.mime_minor || "default"
    image = File.join path, [mime_minor, "png"].join('.')
    content_tag :img, nil, src: image, class: "backup_picture"
  end

end
