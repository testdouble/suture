class Item < ActiveRecord::Base
  attr_accessible :name, :sell_in, :quality

  def update_quality!
    if self.name != 'Aged Brie' && self.name != 'Backstage passes to a TAFKAL80ETC concert'
      if self.quality > 0
        if self.name != 'Sulfuras, Hand of Ragnaros'
          self.quality -= 1
        end
      end
    else
      if self.quality < 50
        self.quality += 1
        if self.name == 'Backstage passes to a TAFKAL80ETC concert'
          if self.sell_in < 11
            if self.quality < 50
              self.quality += 1
            end
          end
          if self.sell_in < 6
            if self.quality < 50
              self.quality += 1
            end
          end
        end
      end
    end
    if self.name != 'Sulfuras, Hand of Ragnaros'
      self.sell_in -= 1
    end
    if self.sell_in < 0
      if self.name != "Aged Brie"
        if self.name != 'Backstage passes to a TAFKAL80ETC concert'
          if self.quality > 0
            if self.name != 'Sulfuras, Hand of Ragnaros'
              self.quality -= 1
            end
          end
        else
          self.quality = self.quality - self.quality
        end
      else
        if self.quality < 50
          self.quality += 1
        end
      end
    end
    save!
  end
end
