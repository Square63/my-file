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

    def sphinx_options(params)
      options = default_options

      [params[:term], options]
    end

    def perform_search(params)
      search *sphinx_options(params)
    end
  end
end
