class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  has_many :items

  def main_folder
    self.items.folder.first || self.items.folder.create(name: "Main Folder")
  end
end
