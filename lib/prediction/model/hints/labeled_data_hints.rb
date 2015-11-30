require_relative '../consts/labeled_data'


class LabeledDataHints

  @@hints = Hash[
      LabeledData.yes => [ "You are probably interested in classification because you have labels in source data" ],
      LabeledData.no => [ "You are probably interested in clustering because you don't have labels in source data" ],
      LabeledData.no_info => [ "You should check Prediction suggestion" ]
  ]

  def self.get_hints(labeled_data)
    @@hints[labeled_data]
  end

end