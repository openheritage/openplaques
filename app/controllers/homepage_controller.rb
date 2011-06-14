class HomepageController < ApplicationController

  def index
    @plaques_count = Plaque.count
    @recent_plaques = Plaque.photographed.order("created_at DESC").limit(2)
  end

end
