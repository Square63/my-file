class ItemPresenter < Presenter
  MAX_DEPTH = 1

  def initialize(item)
    super(item)
  end

  def self.model_name
    ActiveModel::Name.new Item
  end

  def parent
    parent_item = super
    ItemPresenterFactory.for(parent_item) if parent_item
  end

  def view_id
    ["item", self.to_param].join("-")
  end

  def to_partial_path
    "items/item"
  end

  def to_model
    self
  end

  def show_path(options = {})
    raise "Override show_path"
  end

  def image_icon(options = {})
    raise "Override image_icon"
  end

  def image_link
    link_to image_icon, show_path
  end

  def name_link
    link_to name, show_path
  end

  def as_search_json(options = {})
    level = options[:level].to_i
    return if level > MAX_DEPTH

    h = {
      id: to_param,
      name: name,
      icon: image_icon,
      url: show_path,
      type: type,
      html: render(partial: "items/autocomplete", locals: {item: self}),
    }

    h[:parent] = parent.as_search_json(level: level.next) if parent
    h[:url] = parent.show_path(anchor: to_param) if is_a?(FilePresenter)

    h
  end
end
