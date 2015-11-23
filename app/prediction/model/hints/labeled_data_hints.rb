require_relative '../consts/labeled_data'


class LabeledDataHints

  @@hints = Hash[
      LabeledData.yes => [ "[LabeledData][Available] You are probably interested in classification" ],
      LabeledData.no => [ "[LabeledData][NotAvailable] You are probably interested in clustering" ],
      LabeledData.noInfo => [ "[LabeledData][NoInfo] You should check [Prediction] suggestion" ]
  ]

  def self.getHints(labeledData)
    @@hints[labeledData]
  end

end


########################################################################################################################
raise "Wrong prediction on available labeled data" unless LabeledDataHints.getHints(LabeledData.yes) == [ "[LabeledData][Available] You are probably interested in classification" ]
raise "Wrong prediction on unavailable labeled data" unless LabeledDataHints.getHints(LabeledData.no) == [ "[LabeledData][NotAvailable] You are probably interested in clustering" ]
raise "Wrong prediction on labeled data when not specified" unless LabeledDataHints.getHints(LabeledData.noInfo) == [ "[LabeledData][NoInfo] You should check [Prediction] suggestion" ]

