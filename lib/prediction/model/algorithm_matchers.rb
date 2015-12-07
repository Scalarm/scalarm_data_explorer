class AlgorithmMatchers

  @@algorithm_matchers = [

      AlgorithmMatcher.new(Algorithm.new('SGD Classifier', AlgorithmType.classification, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.category_unknown_number_of_categories, NumberOfSamples.more_than_50_less_than_100k, TextData.not_relevant, LabeledData.yes)),

      AlgorithmMatcher.new(Algorithm.new('Kernel Approximation', AlgorithmType.classification, "if 'SGD Classifier' not working"),
                           AlgorithmAttributes.new(Prediction.category_unknown_number_of_categories, NumberOfSamples.more_than_50_less_than_100k, TextData.not_relevant, LabeledData.yes)),

      AlgorithmMatcher.new(Algorithm.new('Linear SVC', AlgorithmType.classification, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.category_unknown_number_of_categories, NumberOfSamples.more_than_100k, TextData.not_relevant, LabeledData.yes)),

      AlgorithmMatcher.new(Algorithm.new('Naive Bayes', AlgorithmType.classification, "if 'Linear SVC' not working"),
                           AlgorithmAttributes.new(Prediction.category_unknown_number_of_categories, NumberOfSamples.more_than_100k, TextData.yes, LabeledData.yes)),

      AlgorithmMatcher.new(Algorithm.new('Regression Tree', AlgorithmType.classification, "if 'Linear SVC' not working"),
                           AlgorithmAttributes.new(Prediction.category_unknown_number_of_categories, NumberOfSamples.more_than_50_less_than_100k, TextData.not_relevant, LabeledData.no)),

      AlgorithmMatcher.new(Algorithm.new('KNeighbors Classifier', AlgorithmType.classification,  "if 'Linear SVC' not working"),
                           AlgorithmAttributes.new(Prediction.category_unknown_number_of_categories, NumberOfSamples.more_than_100k, TextData.no, LabeledData.yes)),

      AlgorithmMatcher.new(Algorithm.new('SVC Ensemble Classifiers', AlgorithmType.classification, "if 'KNeighbors Classifier' not working"),
                           AlgorithmAttributes.new(Prediction.category_unknown_number_of_categories, NumberOfSamples.more_than_100k, TextData.no, LabeledData.yes)),

      AlgorithmMatcher.new(Algorithm.new('tough luck...', AlgorithmType.unknown, "there is no ideal algorithm for your problem"),
                           AlgorithmAttributes.new(Prediction.category_unknown_number_of_categories, NumberOfSamples.more_than_50_less_than_10k, TextData.not_relevant, LabeledData.no)),

      AlgorithmMatcher.new(Algorithm.new('KMeans', AlgorithmType.clustering, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.category_known_number_of_categories, NumberOfSamples.moreThan10k, TextData.not_relevant, LabeledData.no)),

      AlgorithmMatcher.new(Algorithm.new('Hierarchical clustering', AlgorithmType.clustering, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.category_unknown_number_of_categories, NumberOfSamples.more_than_50_less_than_100k, TextData.not_relevant, LabeledData.no_info)),

      AlgorithmMatcher.new(Algorithm.new('Spectral Clustering GMM', AlgorithmType.clustering, "if 'KMeans' not working"),
                           AlgorithmAttributes.new(Prediction.category_known_number_of_categories, NumberOfSamples.moreThan10k, TextData.not_relevant, LabeledData.no)),

      AlgorithmMatcher.new(Algorithm.new('MiniBatch KMeans', AlgorithmType.clustering, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.category_known_number_of_categories, NumberOfSamples.more_than_50_less_than_10k, TextData.not_relevant, LabeledData.no)),

      AlgorithmMatcher.new(Algorithm.new('MeanShift VBGMM', AlgorithmType.clustering, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.category_unknown_number_of_categories, NumberOfSamples.moreThan10k, TextData.not_relevant, LabeledData.no)),

      AlgorithmMatcher.new(Algorithm.new('SGD Regressor', AlgorithmType.regression, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.quantity, NumberOfSamples.more_than_50_less_than_100k, TextData.not_relevant, LabeledData.no_info)),

      AlgorithmMatcher.new(Algorithm.new('ElasticNet Lasso', AlgorithmType.regression, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.quantity, NumberOfSamples.more_than_100k, TextData.not_relevant, LabeledData.no_info)),

      AlgorithmMatcher.new(Algorithm.new('RidgeRegression SVR (kernel=`linear`)', AlgorithmType.regression, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.quantity, NumberOfSamples.more_than_100k, TextData.not_relevant, LabeledData.no_info)),

      AlgorithmMatcher.new(Algorithm.new('SVR(kernel=`rbf`) EnsembleRegressors', AlgorithmType.regression, "if 'RidgeRegression SVR (kernel=`linear`)' not working"),
                           AlgorithmAttributes.new(Prediction.quantity, NumberOfSamples.more_than_100k, TextData.not_relevant, LabeledData.no_info)),

      AlgorithmMatcher.new(Algorithm.new('Randomized PCA', AlgorithmType.dimensionality_reduction, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.anything, NumberOfSamples.more_than_50_less_than_10k, TextData.not_relevant, LabeledData.no_info)),

      AlgorithmMatcher.new(Algorithm.new('Isomap Spectral Embedding', AlgorithmType.dimensionality_reduction, "if 'Randomized PCA' not working"),
                           AlgorithmAttributes.new(Prediction.anything, NumberOfSamples.moreThan10k, TextData.not_relevant, LabeledData.no_info)),

      AlgorithmMatcher.new(Algorithm.new('LLE', AlgorithmType.dimensionality_reduction, "if 'Isomap Spectral Embedding' not working"),
                           AlgorithmAttributes.new(Prediction.anything, NumberOfSamples.moreThan10k, TextData.not_relevant, LabeledData.no_info)),

      AlgorithmMatcher.new(Algorithm.new( 'Kernel Approximation', AlgorithmType.dimensionality_reduction, "if 'Randomized PCA' not working"),
                           AlgorithmAttributes.new(Prediction.anything, NumberOfSamples.more_than_50_less_than_10k, TextData.not_relevant, LabeledData.no_info)),


      AlgorithmMatcher.new(Algorithm.new('tough luck...', AlgorithmType.unknown, "there is no ideal algorithm for your problem"),
                           AlgorithmAttributes.new(Prediction.structure, NumberOfSamples.more_than_50_less_than_10k, TextData.not_relevant, LabeledData.no_info))

  ]


  def self.get_algorithms_matchers()
    @@algorithm_matchers.dup
  end

end