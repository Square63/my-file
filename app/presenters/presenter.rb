class Presenter < SimpleDelegator
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::JavaScriptHelper

  alias :item :__getobj__

  delegate :url_helpers, to: "Rails.application.routes"
  delegate :image_tag, to: "ActionController::Base.helpers"
  delegate :render, to: "ActionView::Base.new(Rails.configuration.paths['app/views'])"
end
