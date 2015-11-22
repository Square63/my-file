class Item < ActiveRecord::Base
  obfuscate_id :spin => 31010149

  validates_presence_of :user_id, :type

  belongs_to :user
  before_save :set_name, :set_position
  belongs_to :parent, class_name: "Item"
  has_many :items, foreign_key: :parent_id
  has_many :folders, -> { folder }, foreign_key: :parent_id
  has_many :uploads, -> { upload }, foreign_key: :parent_id

  scope :folder, -> { where(type: "Folder") }
  scope :upload, -> { where(type: "Upload") }
  scope :ordered, -> { order("position ASC") }

  def name=(new_name)
    self[:name] = CGI.unescape new_name.to_s
  end

  def find_uniq_name(counter = 1, batch_size=30)
    names = (counter..counter+batch_size).collect {|i| [name, i].join(' ')}
    names.unshift(name) if counter == 1
    previous_names = self.class.where(parent_id: parent_id, type: type).where(name: names).collect(&:name)
    (names - previous_names).first || find_uniq_name(counter + batch_size)
  end

  def find_next_position
    self.class.where(parent_id: parent_id).maximum(:position).to_i.next
  end

  def set_name
    self.name = self.type.titleize if self.name.blank?
    self.name = find_uniq_name if self.name_changed?
  end

  def set_position
    self.position = find_next_position if self.position.to_i.zero?
  end
end
