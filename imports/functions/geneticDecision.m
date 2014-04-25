function chains = geneticDecision(chains,constants)

  for i = 1:constants.nc

    chains{i}.cycles{end}.accepted = chains{i}.cycles{end}.proposed;

  end
