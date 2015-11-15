class FoldersController < ApplicationController
  before_filter :get_parent

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
    @folder.parent = @parent
    @folder.save

    redirect_to @folder.parent || @folder
  end

  private

  def folder_params
    return {} if params[:folder].blank?
    params.require(:folder).permit(:name, :parent_id)
  end

  def get_parent
    @parent = Folder.find params[:parent_id] if params[:parent_id].present?
  end

end
