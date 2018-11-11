class QualityUpdater
  def update(item)
    updater_for(item).update(item)
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

  def updater_for(item)
    pair = UPDATERS.detect { |re, _| re =~ item.name }
    pair ? pair[1] : standard_updater
  end

  def standard_updater
    @standard_handler ||= StandardQualityUpdater.new
  end
end
