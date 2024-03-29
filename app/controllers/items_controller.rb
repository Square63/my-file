class ItemsController < ApplicationController
  before_filter :get_item, only: [:show, :destroy, :update, :cut, :copy]
  before_filter :get_parent, only: [:cut, :copy]
  before_filter :get_pasted_item, only: [:show]

  def index
    @folder = current_user.main_folder
    redirect_to special_folder_path(@folder)
  end

  def show
  end

  def search
    @items = Item.perform_search(params)

    render json: @items.collect {|item| ItemPresenterFactory.for(item).as_search_json }
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
    @old_parent = @item.parent
    @item.move_to @parent

    @parent = ItemPresenterFactory.for @parent
    @old_parent = ItemPresenterFactory.for @old_parent

    respond_to do |format|
      format.js
    end
  end

  def copy
    @item = @item.copy_to @parent

    @item = ItemPresenterFactory.for @item
    @parent = ItemPresenterFactory.for @parent

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

  def get_parent
    @parent ||= Item.find params[:parent_id]
  end

  def item_id(id)
    ObfuscateId.show(id, Item.obfuscate_id_spin).to_i
  end

  def item_params
    return {} if params[:item].blank?
    params.require(:item).permit(:name)
  end

  def get_pasted_item
    return unless cookies[:store]
    @pasted_items = []

    begin
      store = JSON.parse cookies[:store]

      store["item_ids"].each do |id|
        pasted_item = items.find_by_id(item_id(id))
        if pasted_item.present?
          pasted_item = ItemPresenterFactory.for pasted_item
          @pasted_items << pasted_item
        end
      end

    rescue
      cookies.delete :store
    end

  end
end
