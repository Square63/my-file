class FilesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:show]

  def index
    @uploads = current_user.uploads
  end

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

  def nginx_proxy
    file = Tempfile.new("nginx_proxy")
    file.binmode
    file.write request.env["rack.input"].read
    file.close

    params[:file] = {
      name: request.env["HTTP_CONTENT_DISPOSITION"][/"(.+)"/, 1],
      path: file.path,
      content_type: request.env["CONTENT_TYPE"],
      size: request.env["CONTENT_LENGTH"],
    }

    create
  end

  private

  def file_params
    params.require(:file).permit(:name, :content_type, :path, :md5, :size)
  end

end
