require_relative '../consts/number_of_samples'


class NumberOfSamplesHints

  @@hints = Hash[
      NumberOfSamples.lessThan50 => [ "[NumberOfSamples][LessThan50] You definately need more data!" ],

      NumberOfSamples.moreThan50LessThan10k => [ "[NumberOfSamples][MoreThan50LessThan10k] You can try with 'MiniBatch KMeans'",
                                                 "[NumberOfSamples][MoreThan50LessThan10k] You can try with 'kernel approximation'" ],

      NumberOfSamples.moreThan50LessThan100k => [ "[NumberOfSamples][MoreThan50LessThan100k] You can try with 'SGD Classifier'",
                                                  "[NumberOfSamples][MoreThan50LessThan100k] You can try with 'kernel approximation' if SGD Classifier' will not work",
                                                  "[NumberOfSamples][MoreThan50LessThan100k] You can try with 'SGD Regressor'" ],

      NumberOfSamples.moreThan10k => [ "[NumberOfSamples][MoreThan10k] You can try with 'KMeans'",
                                       "[NumberOfSamples][MoreThan10k] You can try with 'Spectral Clustering GMM' if KMeans' will not work",
                                       "[NumberOfSamples][MoreThan10k] You can try with 'MeanShift VBGMM'",
                                       "[NumberOfSamples][MoreThan10k] You can try with 'Isomap Spectral Embedding'",
                                       "[NumberOfSamples][MoreThan10k] You can try with 'LLE' if 'Isomap Spectral Embedding' will not work" ],

      NumberOfSamples.moreThan100k => [ "[NumberOfSamples][MoreThan100k] You can try with 'Linear SVC'",
                                        "[NumberOfSamples][MoreThan100k] You can try with 'Naive Bayes' if 'Linear SVC' will not work",
                                        "[NumberOfSamples][MoreThan100k] You can try with 'KNeighbors Classifier' if 'Linear SVC' will not work",
                                        "[NumberOfSamples][MoreThan100k] You can try with 'SVC Ensemble Classifiers' if 'KNeighbors Classifier' will not work",
                                        "[NumberOfSamples][MoreThan100k] You can try with 'ElasticNet Lasso'",
                                        "[NumberOfSamples][MoreThan100k] You can try with 'SVR(kernel=`rbf`) EnsembleRegressors' if 'RidgeRegression SVR (kernel=`linear`)' will not work" ]
  ]

  def self.getHints(samples)
    if samples < 50 then
      @@hints[NumberOfSamples.lessThan50]
    elsif samples > 100_000 then
      @@hints[NumberOfSamples.moreThan10k] + @@hints[NumberOfSamples.moreThan100k]
    elsif samples > 10_000 then
      @@hints[NumberOfSamples.moreThan10k] + @@hints[NumberOfSamples.moreThan50LessThan100k]
    else
      @@hints[NumberOfSamples.moreThan50LessThan10k] + @@hints[NumberOfSamples.moreThan50LessThan100k]
    end
  end

end


########################################################################################################################
raise "Wrong prediction when samples < 50" unless NumberOfSamplesHints.getHints(20) == [ "[NumberOfSamples][LessThan50] You definately need more data!" ]
########################################################################################################################
raise "Wrong prediction when samples > 50 and < 10_000" unless NumberOfSamplesHints.getHints(9_000) == [ "[NumberOfSamples][MoreThan50LessThan10k] You can try with 'MiniBatch KMeans'",
                                                                                                         "[NumberOfSamples][MoreThan50LessThan10k] You can try with 'kernel approximation'",
                                                                                                         "[NumberOfSamples][MoreThan50LessThan100k] You can try with 'SGD Classifier'",
                                                                                                         "[NumberOfSamples][MoreThan50LessThan100k] You can try with 'kernel approximation' if SGD Classifier' will not work",
                                                                                                         "[NumberOfSamples][MoreThan50LessThan100k] You can try with 'SGD Regressor'" ]
########################################################################################################################
raise "Wrong prediction when samples > 10_000 and < 100_000" unless NumberOfSamplesHints.getHints(90_000) == [ "[NumberOfSamples][MoreThan10k] You can try with 'KMeans'",
                                                                                                               "[NumberOfSamples][MoreThan10k] You can try with 'Spectral Clustering GMM' if KMeans' will not work",
                                                                                                               "[NumberOfSamples][MoreThan10k] You can try with 'MeanShift VBGMM'",
                                                                                                               "[NumberOfSamples][MoreThan10k] You can try with 'Isomap Spectral Embedding'",
                                                                                                               "[NumberOfSamples][MoreThan10k] You can try with 'LLE' if 'Isomap Spectral Embedding' will not work",
                                                                                                               "[NumberOfSamples][MoreThan50LessThan100k] You can try with 'SGD Classifier'",
                                                                                                               "[NumberOfSamples][MoreThan50LessThan100k] You can try with 'kernel approximation' if SGD Classifier' will not work",
                                                                                                               "[NumberOfSamples][MoreThan50LessThan100k] You can try with 'SGD Regressor'" ]
########################################################################################################################
raise "Wrong prediction when samples > 100_000" unless NumberOfSamplesHints.getHints(101_000) == [ "[NumberOfSamples][MoreThan10k] You can try with 'KMeans'",
                                                                                                   "[NumberOfSamples][MoreThan10k] You can try with 'Spectral Clustering GMM' if KMeans' will not work",
                                                                                                   "[NumberOfSamples][MoreThan10k] You can try with 'MeanShift VBGMM'",
                                                                                                   "[NumberOfSamples][MoreThan10k] You can try with 'Isomap Spectral Embedding'",
                                                                                                   "[NumberOfSamples][MoreThan10k] You can try with 'LLE' if 'Isomap Spectral Embedding' will not work",
                                                                                                   "[NumberOfSamples][MoreThan100k] You can try with 'Linear SVC'",
                                                                                                   "[NumberOfSamples][MoreThan100k] You can try with 'Naive Bayes' if 'Linear SVC' will not work",
                                                                                                   "[NumberOfSamples][MoreThan100k] You can try with 'KNeighbors Classifier' if 'Linear SVC' will not work",
                                                                                                   "[NumberOfSamples][MoreThan100k] You can try with 'SVC Ensemble Classifiers' if 'KNeighbors Classifier' will not work",
                                                                                                   "[NumberOfSamples][MoreThan100k] You can try with 'ElasticNet Lasso'",
                                                                                                   "[NumberOfSamples][MoreThan100k] You can try with 'SVR(kernel=`rbf`) EnsembleRegressors' if 'RidgeRegression SVR (kernel=`linear`)' will not work" ]