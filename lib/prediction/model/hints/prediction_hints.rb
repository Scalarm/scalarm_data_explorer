require_relative '../consts/prediction'


class PredictionHints

  @@hints = Hash[
      Prediction.category_known_number_of_categories => [ "You are probably interested in clustering because you selected category prediction" ],
      Prediction.category_unknown_number_of_categories => [ "You are probably interested in classification because you selected category prediction" ],
      Prediction.quantity => [ " You are probably interested in regression because you selected category prediction" ],
      Prediction.structure => [ " You can try with the blind choice for the begining" ],
      Prediction.anything => [ " You are probably interested in dimensionality reduction because you don't specify what to predict" ]
  ]

  def self.get_hints(prediction)
    @@hints[prediction]
  end

end