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

  def reorder
    ids = params[:ids].split(",").collect { |id| item_id(id) }

    items.find(ids).each do |item|
      item.position = ids.index(item.id).to_i.next
      item.save if item.position_changed?
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def items
    @items ||= current_user.items
  end

  def get_item
    @item ||= items.find item_id(params[:id])
  end

  def item_id(id)
    ObfuscateId.show(id, Item.obfuscate_id_spin).to_i
  end

  def item_params
    return {} if params[:item].blank?
    params.require(:item).permit(:name)
  end
end
