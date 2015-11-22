module ApplicationHelper
  def alert_class(key)
    k = key.to_s.sub('_stay', '')

    {
      "success" => "success",
      "info" => "info",
      "notice" => "success",
      "warning" => "warning",
      "alet" => "warning",
      "danger" => "danger",
      "error" => "danger",
      "failure" => "danger",
    }[k] || "warning"
  end

  def page_title(title)
    content_for :title, title
  end

  def folder_add_button
    content_tag :div, class: "folder-add item-add" do
      link_to folders_path(parent_id: @item), method: :post, remote: true, class: "btn btn-warning btn-sm add-btn" do
        capture do
          concat content_tag(:span, nil, class: "glyphicon glyphicon-folder-open")
          concat " &nbsp;New".html_safe
        end
      end
    end
  end

  def file_add_button
    content_tag :div, class: "file-add item-add" do
      capture do
        label_tag = content_tag(:label, for: "fileupload", class: "btn btn-success btn-sm add-btn") do
          capture do
            concat content_tag(:span, nil, class: "glyphicon glyphicon-file")
            concat " Upload"
          end
        end
        concat label_tag
        concat file_field_tag(:file, id: "fileupload", name: "files[]", multiple: true, "data-url" => nginx_proxy_path(folder_id: @item.to_param))
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
        concat link_to(folder.name, special_folder_path(folder))
      end
      concat tag
    end
  end
end
