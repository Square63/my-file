class FolderPresenter < ItemPresenter
  def items
    @items ||= super.includes(:parent).ordered.map do |item|
      ItemPresenterFactory.for(item)
    end
  end

  def image_icon(options = {})
    options[:class] = [options[:class], "image_icon"].compact.join(' ')
    options[:src] = image_full_path
    content_tag :img, nil, options
  end

  def image_full_path
    "/assets/images/folder.png"
  end

  def show_path(options = {})
    url_helpers.special_folder_path(item, options)
  end
end
