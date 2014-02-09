class FilesController < ApplicationController

  def create
    response = params
    response["url"] = params[:file_path]
    render text: response.to_json
  end

end
