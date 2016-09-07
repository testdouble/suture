require "suture"

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
    Item.all.each do |item|
      Suture.create :gilded_rose,
        :old => lambda { |item|
          item.update_quality!
          item
        },
        :args => [item] #, # Uncomment to record calls to db/suture.sqlite3:
        # :record_calls => true
    end
    redirect_to items_path
  end

  def destroy
    Item.destroy(params[:id])
    redirect_to items_path
  end
end
