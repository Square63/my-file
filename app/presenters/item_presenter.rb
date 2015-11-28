class ItemPresenter < SimpleDelegator
  include ActionView::Helpers::UrlHelper

  alias :item :__getobj__

  delegate :url_helpers, to: "Rails.application.routes"
  delegate :image_tag, to: "ActionController::Base.helpers"


  def initialize(item)
    super(item)
  end

  def self.model_name
    ActiveModel::Name.new Item
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

  def show_path
    raise "Override show_path"
  end

  def image_icon
    raise "Override image_icon"
  end

  def image_link
    link_to image_icon, show_path
  end

  def name_link
    link_to name, show_path
  end
end
