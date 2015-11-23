require_relative '../consts/prediction'


class PredictionHints

  @@hints = Hash[
      Prediction.categoryWithKnownNumberOfCategories => [ "[Prediction][Category] You are probably interested in clustering" ],
      Prediction.categoryWithUnknownNumberOfCategories => [ "[Prediction][Category] You are probably interested in classification" ],
      Prediction.quantity => [ "[Prediction][Quantity] You are probably interested in regression" ],
      Prediction.structure => [ "[Prediction][Structure] You can try with the blind choice for the begining" ],
      Prediction.noInfo => [ "[Prediction][NoInfo] You are probably interested in dimensionality reduction" ]
  ]

  def self.getHints(prediction)
    @@hints[prediction]
  end

end


########################################################################################################################
raise "Wrong prediction on category with known number of categories" unless PredictionHints.getHints(Prediction.categoryWithKnownNumberOfCategories) == [ "[Prediction][Category] You are probably interested in clustering" ]
raise "Wrong prediction on category with unknown number of categories" unless PredictionHints.getHints(Prediction.categoryWithUnknownNumberOfCategories) == [ "[Prediction][Category] You are probably interested in classification" ]
raise "Wrong prediction on quantity" unless PredictionHints.getHints(Prediction.quantity) == [ "[Prediction][Quantity] You are probably interested in regression" ]
raise "Wrong prediction on structure" unless PredictionHints.getHints(Prediction.structure) == [ "[Prediction][Structure] You can try with the blind choice for the begining" ]
raise "Wrong prediction when predictor not specified" unless PredictionHints.getHints(Prediction.noInfo) == [ "[Prediction][NoInfo] You are probably interested in dimensionality reduction" ]



