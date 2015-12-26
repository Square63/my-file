class ItemPresenterFactory
  def self.for(item)
    klass = {
      "Folder" => FolderPresenter,
      "Upload" => FilePresenter,
    }[item.type]

    klass.new item
  end
end
