class FolderPresenter < ItemPresenter
  def items
    @items ||= super.includes(:parent).ordered.map do |item|
      ItemPresenterFactory.for(item)
    end
  end

  def image_icon
    image_tag "folder.png", class: "image_icon"
  end

  def image_full_path
    "/assets/folder.png"
  end

  def show_path
    url_helpers.special_folder_path(item)
  end
end
