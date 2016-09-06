class ItemsController < ApplicationController
  def index
    @items = Item.all
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.create!(params[:item])
    redirect_to items_path
  end

  def update_all
    Item.all.each(&:update_quality!)
    redirect_to items_path
  end

  def destroy
    Item.destroy(params[:id])
    redirect_to items_path
  end
end
