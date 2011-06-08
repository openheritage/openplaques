class HomepageController < ApplicationController

  def index
    @plaques_count = Plaque.count
  end

end
