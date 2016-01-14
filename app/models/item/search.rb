class Item < ActiveRecord::Base
  PER_PAGE = 1000

  class << self
    def default_options
      {
        with: {},
        conditions: {},
        star: true,
        page: 1,
        per_page: PER_PAGE,
        sql: {include: [:parent]},
      }
    end

    def sphinx_options(params, user)
      options = default_options
      options[:with][:user_id] = user.id

      [params[:term], options]
    end

    def perform_search(params, user)
      search *sphinx_options(params, user)
    end
  end
end
