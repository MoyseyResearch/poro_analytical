function chains = mcmcStep(chains,params,constants,dataMeasured)

  % the mcmcStep function takes in the current chain structure and adds a
  % new cycle to the end of each chain, each with a set of parameters that
  % somehow follows from the last cycle. This could simply mean perturbing
  % values by a set amount, or could involve a varying step size. Since you
  % already have the entire chain structure handy inside the scope of this 
  % function, you can easily find the errors and variances of the chains

  for i = 1:length(chains)
    paramsOld = chains{i}.cycles{end}.accepted.params;
    for k = 1:length(params)
      paramsNew{k} = paramsOld{k} + randn *params{k}.step;
      while paramsNew{k}<params{k}.bounds(1) || paramsNew{k}>params{k}.bounds(2)
        paramsNew{k} = paramsOld{k} + randn *params{k}.step;
      end
    end
    chains{i}.cycles{end+1}.proposed.params = paramsNew;
  end

