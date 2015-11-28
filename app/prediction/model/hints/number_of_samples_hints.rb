require_relative '../consts/number_of_samples'


class NumberOfSamplesHints

  @@hints = Hash[
      NumberOfSamples.less_than_50 => [ "You definately need more data!" ],

      NumberOfSamples.more_than_50_less_than_10k => [ "You can try with 'MiniBatch KMeans'",
                                                 "You can try with 'kernel approximation'" ],

      NumberOfSamples.more_than_50_less_than_100k => [ "You can try with 'SGD Classifier'",
                                                  "You can try with 'kernel approximation' if SGD Classifier' will not work",
                                                  "You can try with 'SGD Regressor'" ],

      NumberOfSamples.moreThan10k => [ "You can try with 'KMeans'",
                                       "You can try with 'Spectral Clustering GMM' if KMeans' will not work",
                                       "You can try with 'MeanShift VBGMM'",
                                       "You can try with 'Isomap Spectral Embedding'",
                                       "You can try with 'LLE' if 'Isomap Spectral Embedding' will not work" ],

      NumberOfSamples.more_than_100k => [ "You can try with 'Linear SVC'",
                                        "You can try with 'Naive Bayes' if 'Linear SVC' will not work",
                                        "You can try with 'KNeighbors Classifier' if 'Linear SVC' will not work",
                                        "You can try with 'SVC Ensemble Classifiers' if 'KNeighbors Classifier' will not work",
                                        "You can try with 'ElasticNet Lasso'",
                                        "You can try with 'SVR(kernel=`rbf`) EnsembleRegressors' if 'RidgeRegression SVR (kernel=`linear`)' will not work" ]
  ]

  def self.get_hints(samples)
    if samples < 50 then
      @@hints[NumberOfSamples.less_than_50]
    elsif samples > 100_000 then
      @@hints[NumberOfSamples.moreThan10k] + @@hints[NumberOfSamples.more_than_100k]
    elsif samples > 10_000 then
      @@hints[NumberOfSamples.moreThan10k] + @@hints[NumberOfSamples.more_than_50_less_than_100k]
    else
      @@hints[NumberOfSamples.more_than_50_less_than_10k] + @@hints[NumberOfSamples.more_than_50_less_than_100k]
    end
  end

end

