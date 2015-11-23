require_relative 'consts/prediction'
require_relative 'consts/number_of_samples'
require_relative 'consts/text_data'
require_relative 'consts/labeled_data'
require_relative 'consts/algorithm_type'
require_relative 'structures/algorithm'
require_relative 'structures/algorithm_matcher'
require_relative 'structures/algorithm_attributes'


class AlgorithmMatchers

  @@algorithmMatchers = [

      AlgorithmMatcher.new(Algorithm.new('SGD Classifier', AlgorithmType.classification, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.categoryWithUnknownNumberOfCategories, NumberOfSamples.moreThan50LessThan100k, TextData.notRelevant, LabeledData.yes)),

      AlgorithmMatcher.new(Algorithm.new('kernel approximation', AlgorithmType.classification, "if 'SGD Classifier' not working"),
                           AlgorithmAttributes.new(Prediction.categoryWithUnknownNumberOfCategories, NumberOfSamples.moreThan50LessThan100k, TextData.notRelevant, LabeledData.yes)),

      AlgorithmMatcher.new(Algorithm.new('Linear SVC', AlgorithmType.classification, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.categoryWithUnknownNumberOfCategories, NumberOfSamples.moreThan100k, TextData.notRelevant, LabeledData.yes)),

      AlgorithmMatcher.new(Algorithm.new('Naive Bayes', AlgorithmType.classification, "if 'Linear SVC' not working"),
                           AlgorithmAttributes.new(Prediction.categoryWithUnknownNumberOfCategories, NumberOfSamples.moreThan100k, TextData.yes, LabeledData.yes)),

      AlgorithmMatcher.new(Algorithm.new('KNeighbors Classifier', AlgorithmType.classification,  "if 'Linear SVC' not working"),
                           AlgorithmAttributes.new(Prediction.categoryWithUnknownNumberOfCategories, NumberOfSamples.moreThan100k, TextData.no, LabeledData.yes)),

      AlgorithmMatcher.new(Algorithm.new('SVC Ensemble Classifiers', AlgorithmType.classification, "if 'KNeighbors Classifier' not working"),
                           AlgorithmAttributes.new(Prediction.categoryWithUnknownNumberOfCategories, NumberOfSamples.moreThan100k, TextData.no, LabeledData.yes)),

      AlgorithmMatcher.new(Algorithm.new('tough luck...', AlgorithmType.unknown, "there is no ideal algorithm for your problem"),
                           AlgorithmAttributes.new(Prediction.categoryWithUnknownNumberOfCategories, NumberOfSamples.moreThan50LessThan10k, TextData.notRelevant, LabeledData.no)),

      AlgorithmMatcher.new(Algorithm.new('KMeans', AlgorithmType.clustering, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.categoryWithKnownNumberOfCategories, NumberOfSamples.moreThan10k, TextData.notRelevant, LabeledData.no)),

      AlgorithmMatcher.new(Algorithm.new('Spectral Clustering GMM', AlgorithmType.clustering, "if 'KMeans' not working"),
                           AlgorithmAttributes.new(Prediction.categoryWithKnownNumberOfCategories, NumberOfSamples.moreThan10k, TextData.notRelevant, LabeledData.no)),

      AlgorithmMatcher.new(Algorithm.new('MiniBatch KMeans', AlgorithmType.clustering, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.categoryWithKnownNumberOfCategories, NumberOfSamples.moreThan50LessThan10k, TextData.notRelevant, LabeledData.no)),

      AlgorithmMatcher.new(Algorithm.new('MeanShift VBGMM', AlgorithmType.clustering, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.categoryWithUnknownNumberOfCategories, NumberOfSamples.moreThan10k, TextData.notRelevant, LabeledData.no)),


      AlgorithmMatcher.new(Algorithm.new('SGD Regressor', AlgorithmType.regression, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.quantity, NumberOfSamples.moreThan50LessThan100k, TextData.notRelevant, LabeledData.noInfo)),

      AlgorithmMatcher.new(Algorithm.new('ElasticNet Lasso', AlgorithmType.regression, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.quantity, NumberOfSamples.moreThan100k, TextData.notRelevant, LabeledData.noInfo)),

      AlgorithmMatcher.new(Algorithm.new('RidgeRegression SVR (kernel=`linear`)', AlgorithmType.regression, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.quantity, NumberOfSamples.moreThan100k, TextData.notRelevant, LabeledData.noInfo)),

      AlgorithmMatcher.new(Algorithm.new('SVR(kernel=`rbf`) EnsembleRegressors', AlgorithmType.regression, "if 'RidgeRegression SVR (kernel=`linear`)' not working"),
                           AlgorithmAttributes.new(Prediction.quantity, NumberOfSamples.moreThan100k, TextData.notRelevant, LabeledData.noInfo)),


      AlgorithmMatcher.new(Algorithm.new('Randomized PCA', AlgorithmType.dimensionalityReduction, "first choice algorithm in a class"),
                           AlgorithmAttributes.new(Prediction.noInfo, NumberOfSamples.moreThan50LessThan10k, TextData.notRelevant, LabeledData.noInfo)),

      AlgorithmMatcher.new(Algorithm.new('Isomap Spectral Embedding', AlgorithmType.dimensionalityReduction, "if 'Randomized PCA' not working"),
                           AlgorithmAttributes.new(Prediction.noInfo, NumberOfSamples.moreThan10k, TextData.notRelevant, LabeledData.noInfo)),

      AlgorithmMatcher.new(Algorithm.new('LLE', AlgorithmType.dimensionalityReduction, "if 'Isomap Spectral Embedding' not working"),
                           AlgorithmAttributes.new(Prediction.noInfo, NumberOfSamples.moreThan10k, TextData.notRelevant, LabeledData.noInfo)),

      AlgorithmMatcher.new(Algorithm.new( 'kernel approximation', AlgorithmType.dimensionalityReduction, "if 'Randomized PCA' not working"),
                           AlgorithmAttributes.new(Prediction.noInfo, NumberOfSamples.moreThan50LessThan10k, TextData.notRelevant, LabeledData.noInfo)),


      AlgorithmMatcher.new(Algorithm.new('tough luck...', AlgorithmType.unknown, "there is no ideal algorithm for your problem"),
                           AlgorithmAttributes.new(Prediction.structure, NumberOfSamples.moreThan50LessThan10k, TextData.notRelevant, LabeledData.noInfo))

  ]


  def self.getAlgorithmsMatchers()
    @@algorithmMatchers.dup
  end

end