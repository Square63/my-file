class FilesController < ApplicationController

  def create
    render json: params if request.post?
  end

end
