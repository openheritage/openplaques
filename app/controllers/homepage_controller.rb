class HomepageController < ApplicationController

  layout "v1"

  def index
    @plaques_count = Plaque.count
  end

end
