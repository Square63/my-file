class Folder < ActiveRecord::Base
  obfuscate_id :spin => 31010149

  validates_presence_of :user

  belongs_to :user
  belongs_to :parent, class_name: "Folder"
  has_many :uploads
end
