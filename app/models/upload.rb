class Upload < Item
  attr_accessor :path

  after_create :move_file
  after_destroy :delete_file

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

  def delete_file
    FileUtils.rm full_target_path
  end

  def mime_major
    content_type.to_s.split('/').first
  end

  def mime_minor
    content_type.to_s.split('/').last
  end
end
