class Folder < Item

  def copy
    item = super
    item.size = 0
    item
  end

end
