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

  def folder_breadcrumbs_for(folder)
    content_tag :ol, class: "breadcrumb" do
      folder_breadcrumb_for(folder)
    end.html_safe
  end

  def folder_breadcrumb_for(folder)
    return "" unless folder
    (folder_breadcrumb_for(folder.parent) + content_tag(:li) do
      [image_tag("folder-small.png"), link_to(folder.name, folder)].join(' ').html_safe
    end).html_safe
  end
end
