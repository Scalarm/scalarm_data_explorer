require_relative '../consts/text_data'


class TextDataHints

  @@hints = Hash[
      TextData.yes => [ "'Naive Bayes' would be a good choice because you have String-type parameters" ],
      TextData.no  => [ "You can try with 'KNeighbors Classifier' because you don't have String-type parameters",
                       "You can try with 'SVC Ensemble Classifiers' if 'KNeighbors Classifier' will not work" ],
      TextData.not_relevant => []
  ]

  def self.get_hints(text_data)
    @@hints[text_data]
  end

end