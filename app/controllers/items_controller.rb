class ItemsController < ApplicationController
  before_filter :get_item, only: [:show, :destroy, :update]

  def index
    @folder = current_user.folders.first || current_user.folders.create(name: "Main Folder")
    redirect_to special_folder_path(@folder)
  end

  def show
    @item = ItemPresenterFactory.for(@item)
  end

  def update
    @item.attributes = item_params
    @item.save

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @item.destroy

    respond_to do |format|
      format.js
    end
  end

  private

  def get_item
    @item ||= Item.find params[:id]
  end

  def item_params
    return {} if params[:item].blank?
    params.require(:item).permit(:name)
  end
end
