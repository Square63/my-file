class FilesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:show]

  def show
    @upload = Upload.find params[:id]

    head(:x_accel_redirect    => @upload.url,
         :content_type        => @upload.content_type,
         :content_disposition => "attachment; filename=\"#{@upload.name}\"")
  end

  def create
    @upload = Upload.new file_params
    @upload.user = current_user
    @upload.save

    render text: {url: file_path(@upload)}.to_json
  end

  def nginx
    raise params.inspect
    params[:file] = {
      name: "something"
    }
    create
  end

  private

  def file_params
    params.require(:file).permit(:name, :content_type, :path, :md5, :size)
  end

end
