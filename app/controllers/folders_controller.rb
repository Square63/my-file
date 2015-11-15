class FoldersController < ApplicationController
  def index
    @folder = current_user.folders.first || current_user.folders.create(name: "Main Folder")
    redirect_to @folder
  end

  def show
    @folder = Folder.find params[:id]
  end

  def create
    @folder = Folder.new folder_params
    @folder.user = current_user
    @folder.save
  end

  private

  def folder_params
    params.require(:upload).permit(:name, :parent_id)
  end

end
