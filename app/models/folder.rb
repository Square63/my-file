class Folder < ActiveRecord::Base
  obfuscate_id :spin => 31010149

  before_save :set_name

  validates_presence_of :user

  belongs_to :user
  belongs_to :parent, class_name: "Folder"
  has_many :folders, foreign_key: :parent_id
  has_many :uploads

  def find_uniq_name(counter = 1, batch_size=30)
    names = (counter..counter+batch_size).collect {|i| [name, i].join(' ')}
    previous_names = self.class.where(parent_id: parent_id).where(name: names).collect(&:name)
    (names - previous_names).first || find_uniq_name(counter + batch_size)
  end

  def set_name
    self.name = "Folder" if self.name.blank?
    self.name = find_uniq_name
  end

end
