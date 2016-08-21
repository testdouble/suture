require "suture"

module GildedRose
  Item = Struct.new(:name, :sell_in, :quality)

  def self.update_quality(items)
    Suture.create(:gilded_rose, {
      :old => lambda { |items| old_update_quality(items); items },
      :new => lambda { |items| new_update_quality(items); items },
      :args => [items]
    })
  end

  def self.old_update_quality(items)
    items.each do |item|
      if item.name != 'Aged Brie' && item.name != 'Backstage passes to a TAFKAL80ETC concert'
        if item.quality > 0
          if item.name != 'Sulfuras, Hand of Ragnaros'
            item.quality -= 1
          end
        end
      else
        if item.quality < 50
          item.quality += 1
          if item.name == 'Backstage passes to a TAFKAL80ETC concert'
            if item.sell_in < 11
              if item.quality < 50
                item.quality += 1
              end
            end
            if item.sell_in < 6
              if item.quality < 50
                item.quality += 1
              end
            end
          end
        end
      end
      if item.name != 'Sulfuras, Hand of Ragnaros'
        item.sell_in -= 1
      end
      if item.sell_in < 0
        if item.name != "Aged Brie"
          if item.name != 'Backstage passes to a TAFKAL80ETC concert'
            if item.quality > 0
              if item.name != 'Sulfuras, Hand of Ragnaros'
                item.quality -= 1
              end
            end
          else
            item.quality = item.quality - item.quality
          end
        else
          if item.quality < 50
            item.quality += 1
          end
        end
      end
    end
  end

  def self.new_update_quality(items)
    QualityUpdater.new.update(items)
  end

  class QualityUpdater
    def update(items)
      items.each do |item|
        update_one(item)
      end
    end

    private

    class StandardQualityUpdater
      def update(item)
        update_quality(item)
        update_sell_in(item)
      end

      def update_quality(item)
        if item.sell_in <= 0
          bump(item, -2)
        else
          bump(item, -1)
        end
      end

      def update_sell_in(item)
        item.sell_in -= 1
      end

      def bump(item, amount)
        item.quality += amount
        item.quality = 50 if item.quality > 50
        item.quality = 0 if item.quality < 0
      end
    end

    class NoopQualityUpdater < StandardQualityUpdater
      def update_quality(item)
      end
      def update_sell_in(item)
      end
    end

    class BrieQualityUpdater < StandardQualityUpdater
      def update_quality(item)
        if item.sell_in <= 0
          bump(item, 2)
        else
          bump(item, 1)
        end
      end
    end

    class BackstagePassQualityUpdater < StandardQualityUpdater
      def update_quality(item)
        if item.sell_in > 10
          bump(item, 1)
        elsif item.sell_in > 5
          bump(item, 2)
        elsif item.sell_in > 0
          bump(item, 3)
        else
          item.quality = 0
        end
      end
    end

    class ConjuredItemQualityUpdater < StandardQualityUpdater
      def update_quality(item)
        if item.sell_in <= 0
          bump(item, -4)
        else
          bump(item, -2)
        end
      end
    end

    UPDATERS = [
      [/^Sulfuras, Hand of Ragnaros$/, NoopQualityUpdater.new],
      [/^Aged Brie$/, BrieQualityUpdater.new],
      [/^Backstage passes to a TAFKAL80ETC concert$/, BackstagePassQualityUpdater.new],
      [/^Conjured /, ConjuredItemQualityUpdater.new],
    ]

    def update_one(item)
      updater_for(item).update(item)
    end

    def updater_for(item)
      pair = UPDATERS.detect { |re, handler| re =~ item.name }
      handler = pair ? pair[1] : standard_updater
    end

    def standard_updater
      @standard_handler ||= StandardQualityUpdater.new
    end
  end
end
