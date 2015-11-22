require_relative '../consts/text_data'


class TextDataHints

  @@hints = Hash[
      TextData.yes => [ "[TextData][Available] 'Naive Bayes' would be a good choice" ],
      TextData.no  => [ "[TextData][NotAvailable] You can try with 'KNeighbors Classifier' ",
                       "[TextData][NotAvailable] You can try with 'SVC Ensemble Classifiers' if 'KNeighbors Classifier' will not work" ],
      TextData.notRelevant => []
  ]

  def self.getHints(textData)
    @@hints[textData]
  end

end


########################################################################################################################
raise "Wrong prediction on available text data" unless TextDataHints.getHints(TextData.yes) == [ "[TextData][Available] 'Naive Bayes' would be a good choice" ]
raise "Wrong prediction on unavailable text data" unless TextDataHints.getHints(TextData.no) == [ "[TextData][NotAvailable] You can try with 'KNeighbors Classifier' ",
                                                                                                  "[TextData][NotAvailable] You can try with 'SVC Ensemble Classifiers' if 'KNeighbors Classifier' will not work" ]
raise "Wrong prediction on not relevant text data" unless TextDataHints.getHints(TextData.notRelevant) == []
