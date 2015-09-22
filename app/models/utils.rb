module Utils

  def self.require_plugin(chart_id)
    path = Rails.root.join('app','visualisation_methods',"#{chart_id}","plugin")
    require(path)
  end

  def self.generate_content_with_plugin(chart_id, experiment, params)
    handler = chart_id.camelize.constantize.new
    handler.experiment = experiment
    handler.parameters = params
    handler.handler
  end


end