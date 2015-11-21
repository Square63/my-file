class FoldersController < ApplicationController
  before_filter :get_parent

  def create
    @folder = Folder.new folder_params
    @folder.user = current_user
    @folder.parent = @parent
    @folder.save

    @folder = FolderPresenter.new(@folder)

    respond_to do |format|
      format.js
    end
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
