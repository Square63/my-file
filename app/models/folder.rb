class Folder < Item

  def copy(parent, current_user)
    folder = super(parent, current_user)
    folder.size = 0
    folder.save
    return folder if self.items.blank?

    self.items.each do |item|
      item.copy(folder, current_user)
    end

    folder
  end

end
