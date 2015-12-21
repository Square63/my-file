class Item < ActiveRecord::Base
  obfuscate_id :spin => 31010149

  validates_presence_of :user_id, :type

  validate :parent_is_valid

  belongs_to :user
  before_save :set_name, :set_position
  belongs_to :parent, class_name: "Item"
  has_many :items, foreign_key: :parent_id, dependent: :destroy
  has_many :folders, -> { folder }, foreign_key: :parent_id
  has_many :uploads, -> { upload }, foreign_key: :parent_id

  scope :folder, -> { where(type: "Folder") }
  scope :upload, -> { where(type: "Upload") }
  scope :ordered, -> { order("position ASC") }

  def pathname
    Pathname.new name
  end

  def name=(new_name)
    self[:name] = CGI.unescape new_name.to_s
  end

  def name_without_extension
    pathname.basename ".*"
  end

  def extension
    ext = pathname.extname[1..-1]
    ext if ext.present?
  end

  def find_uniq_name(counter = 1, batch_size=30)
    names = (counter..counter+batch_size).collect {|i| [[name_without_extension, i].join(' '), extension].compact.join(".")}
    names.unshift(name) if counter == 1
    previous_names = self.class.where(parent_id: parent_id, type: type).where(name: names).collect(&:name)
    (names - previous_names).first || find_uniq_name(counter + batch_size)
  end

  def find_next_position
    Item.where(parent_id: parent_id).maximum(:position).to_i.next
  end

  def set_name
    self.name = self.type.titleize if self.name.blank?
    self.name = find_uniq_name if name_changed?
  end

  def set_position
    self.position = find_next_position if self.position.to_i.zero?
  end

  def increase_folder_size_by(s)
    self.update_column :size, self.size + s
    parent.increase_folder_size_by(s) if parent
  end

  def decrease_folder_size_by(s)
    self.update_column :size, self.size - s
    parent.decrease_folder_size_by(s) if parent
  end

  def copy
    item = self.class.new attributes
    item.id = item.position = nil
    item.file_id = id
    item
  end

  def copy_to(new_parent)
    new_item = self.copy
    new_item.parent = new_parent
    new_item.save

    self.items.each do |item|
      item.copy_to(new_item)
    end

    new_item
  end

  def parent_is_valid
    return unless parent

    self.errors[:parent] << "should be a folder" unless parent.is_a?(Folder)
    self.errors[:parent] << "cannot be self" if parent == self
  end

  def move_to(new_parent)
    old_parent = self.parent
    self.parent = new_parent
    self.save
    old_parent.decrease_folder_size_by self.size
    new_parent.increase_folder_size_by self.size
    self
  end

  def self.update_order(items, new_order)
    new_order = new_order.sort do |(id1, position1), (id2, position2)|
      ((position1["top"] / 50 <=> position2["top"] / 50)) * 2 + (position1["left"] <=> position2["left"])
    end

    ids = new_order.collect &:first

    deltas = items.inject({}) do |_, item|
      new_position = ids.index(item.to_param).to_i.next
      difference = new_position - item.position
      _[difference] ||= []
      _[difference] << item
      _
    end

    deltas.each do |difference, items|
      next if difference.zero?
      where(id: items.collect(&:id)).update_all("position = position + #{difference}")
    end
  end
end
