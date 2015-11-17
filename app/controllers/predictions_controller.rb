class PredictionsController < ApplicationController
  def index
    render :index, layout: false
  end
def show

end
  def evaluate
    Rails.logger.debug("NEXT PHASE")
    Rails.logger.debug(params)

  end
end