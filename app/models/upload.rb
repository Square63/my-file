class Upload < Item
  attr_accessor :path

  after_create :move_file, :increase_folder_size
  after_destroy :decrease_folder_size

  def own_file?
    !file_id?
  end

  def file_id_or_default
    file_id || id
  end

  def padded_id
    "%010d" % file_id_or_default
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
    return unless own_file?

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

  def increase_folder_size
    parent.increase_folder_size_by size
  end

  def decrease_folder_size
    parent.decrease_folder_size_by size
  end

  def copy(parent, current_user)
    upload = super(parent, current_user)
    upload.file_id = id
    upload.save
    upload
  end

end
