class Upload < ActiveRecord::Base
  attr_accessor :path

  obfuscate_id :spin => 1021914

  validates_presence_of :folder

  belongs_to :folder

  after_create :move_file

  def name=(new_name)
    self[:name] = CGI.unescape new_name.to_s
  end

  def padded_id
    "%010d" % self.id
  end

  def hashed_padded_id
    [padded_id[0...4], padded_id[4...7], padded_id[7...10]].join("/")
  end

  def target_dir
    ["downloads", hashed_padded_id].join("/")
  end

  def target_path
    [target_dir, id].join("/")
  end

  def full_target_dir
    [Rails.root, target_dir].join("/")
  end

  def full_target_path
    [Rails.root, target_path].join("/")
  end

  def url
    ["", target_path].join("/")
  end

  def move_file
    FileUtils.mkdir_p full_target_dir
    FileUtils.mv path, full_target_path
  end

  def mime_major
    content_type.to_s.split('/').first
  end

  def mime_minor
    content_type.to_s.split('/').last
  end
end
