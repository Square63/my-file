class UploadsController < ApplicationController
  before_filter :get_folder, only: [:create, :nginx_proxy]
  skip_before_filter :authenticate_user!, only: [:show]

  def show
    @upload = Upload.find params[:id]

    head(:x_accel_redirect    => @upload.url,
         :content_type        => @upload.content_type,
         :content_disposition => "attachment; filename=\"#{@upload.name}\"")
  end

  def create
    @upload = @folder.uploads.new upload_params
    @upload.user = current_user
    @upload.save

    @upload = FilePresenter.new(@upload)

    render @upload
  end

  def nginx_proxy
    name = request.env["HTTP_CONTENT_DISPOSITION"][/"(.+)"/, 1]
    file = File.open(File.join("tmp", request.env["HTTP_SESSION_ID"]), "ab")
    file.write request.env["rack.input"].read
    file.close

    total, size = request.env["HTTP_CONTENT_RANGE"].to_s[/\d+\/\d+/].to_s.split("/")
    return render(text: request.env["HTTP_CONTENT_RANGE"]).split(/\s+/).last if total && size && total.to_i + 1 != size.to_i

    params[:upload] = {
      name: name,
      path: file.path,
      content_type: request.env["CONTENT_TYPE"],
      size: File.size(file.path),
    }

    create
  end

  private

  def upload_params
    params.require(:upload).permit(:name, :content_type, :path, :md5, :size)
  end

  def get_folder
    @folder = Folder.find params[:folder_id]
  end

end
