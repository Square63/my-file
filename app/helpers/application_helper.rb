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

  def folder_add_button
    content_tag :div, class: "folder-add" do
      link_to folders_path(parent_id: @folder), method: :post, remote: true, class: "btn btn-warning btn-sm add-btn" do
        capture do
          concat content_tag(:span, nil, class: "glyphicon glyphicon-folder-open")
          concat " Add"
        end
      end
    end
  end

  def file_add_button
    content_tag :div, class: "file-add" do
      capture do
        label_tag = content_tag(:label, for: "fileupload", class: "btn btn-success btn-sm add-btn") do
          capture do
            concat content_tag(:span, nil, class: "glyphicon glyphicon-file")
            concat " Add"
          end
        end
        concat label_tag
        concat file_field_tag(:file, id: "fileupload", name: "files[]", multiple: true, "data-url" => nginx_proxy_path(folder_id: @folder.to_param))
      end
    end
  end

  def folder_breadcrumbs_for(folder)
    content_tag :ol, class: "breadcrumb" do
      capture do
        concat folder_breadcrumb_for(folder)
      end
    end
  end

  def folder_breadcrumb_for(folder)
    return "" unless folder

    capture do
      concat folder_breadcrumb_for(folder.parent)
      tag = content_tag(:li) do
        concat image_tag("folder-small.png")
        concat " "
        concat link_to(folder.name, folder)
      end
      concat tag
    end
  end
end
