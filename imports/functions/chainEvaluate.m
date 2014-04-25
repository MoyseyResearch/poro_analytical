function chains = chainEvaluate(chains,objFns,constants,dataMeasured)

  dataPredicted = mcmcForward(chains,constants);

  if constants.verb>=1
    disp('...evaluating error/fitness functions');
  end

  for i = 1:constants.nc

    chains{i}.cycles{end}.proposed.data  = dataPredicted{i};
    chains{i}.cycles{end}.proposed.error = mcmcError(objFns,dataPredicted{i},dataMeasured);

  end
