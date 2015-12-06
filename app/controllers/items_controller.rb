class ItemsController < ApplicationController
  before_filter :get_item, only: [:show, :destroy, :update, :cut, :copy]

  def index
    @folder = current_user.main_folder
    redirect_to special_folder_path(@folder)
  end

  def show
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

  def cut
    @parent = Item.find params[:item][:parent_id]
    @item.parent = @parent
    @item.save

    respond_to do |format|
      format.js
    end
  end

  def copy
    @parent = Item.find params[:item][:parent_id]
    @item = @item.copy
    @item.user = current_user
    @item.parent = @parent

    @item.save

    @item = ItemPresenterFactory.for @item

    respond_to do |format|
      format.js
    end
  end

  def reorder
    new_order = JSON.parse params[:new_order]
    ids = new_order.keys.collect {|id| item_id(id)}
    Item.update_order items.find(ids), new_order

    respond_to do |format|
      format.js
    end
  end

  private

  def items
    @items ||= current_user.items
  end

  def get_item
    @item ||= ItemPresenterFactory.for(items.find(item_id(params[:id])))
  end

  def item_id(id)
    ObfuscateId.show(id, Item.obfuscate_id_spin).to_i
  end

  def item_params
    return {} if params[:item].blank?
    params.require(:item).permit(:name)
  end
end
