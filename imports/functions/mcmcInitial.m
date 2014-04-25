function [chains,pareto,elite,pop] = mcmcInitial(params,objFns,constants,dataMeasured)

  % the mcmcInitial function should output the initial chain structure,
  % with the first set of proposed parameters

  if constants.verb>=1
    disp('...building initial chain structure from prior models');
  end

  for i = 1:constants.nc
  for j = 1:size(params,2)
     newParams{j} = params{j}.prior.random;
     while newParams{j}<params{j}.bounds(1) || newParams{j}>params{j}.bounds(2)
       newParams{j} = params{j}.prior.random;
     end
  end
  chains{i}.cycles{1} = Cycle(newParams);
  end

  if constants.verb>=1
    disp('...running forward model for initial solutions');
  end

  dataPredicted = mcmcForward(chains,constants);

  if constants.verb>=1
    disp('...evaluating errors for initial solutions');
  end

  for i = 1:constants.nc
    chains{i}.cycles{1}.proposed.data  = dataPredicted{i};
    chains{i}.cycles{1}.proposed.error = mcmcError(objFns,dataPredicted{i},dataMeasured);
    chains{i}.cycles{1}.accepted = chains{i}.cycles{1}.proposed;
    pop{1}{i} = chains{1}.cycles{1};
  end

  if constants.verb>=1
    disp('...defining pareto front');
  end

  pareto = updatePareto(chains,constants,objFns,[]);

  if constants.verb>=1
    disp('...defining elite cohort');
  end

  elite  = updateElite(chains,constants,[]);
