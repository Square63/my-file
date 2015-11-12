module ApplicationHelper
  def upload_icon(upload)
    path = "/assets/file_types"
    image = File.join path, [upload.mime_minor, "png"].join('.')
    default_image = File.join path, "default.png"
    content_tag :img, nil, src: image, onerror: "this.src=#{default_image.inspect};"
  end

end
