function error = mcmcError(objFns,dataPredicted,dataMeasured)

  % the mcmcError function should output a single number that represents the
  % mismatch between the predicted and measured data

  error.err = 0;
  for k = 1:length(objFns)
    error.obj{k} = sum( (dataPredicted{k}-dataMeasured{k}).^2 );
    error.err    = error.err + objFns{k}.weight * error.obj{k} / var(dataMeasured{k});
  end
  error.fitness = 1.0/error.err;
