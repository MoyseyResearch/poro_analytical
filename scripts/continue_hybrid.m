addpath ../imports/classes;
addpath ../imports/functions;
rng('shuffle');

load('../data/hybrid.mat');

for i = length(chains{1}.cycles):constants.nmax-1
  tic;
  disp(sprintf('Running iteration %i...',i+1));
  if constants.verb>=1
    disp('...running genetic step');
  end
  [chains,pop{i}] = geneticStep(chains,params,constants,pareto,elite,pop{i-1});
  if constants.verb>=1
    disp('...evaluating forward model');
  end
  chains = chainEvaluate(chains,objFns,constants,dataMeasured);
  if constants.verb>=1
    disp('...running MCMC decision');
  end
  chains = mcmcDecision(chains,constants);
  if constants.verb>=1
    disp('...updating pareto, elite cohorts');
  end
  pareto = updatePareto(chains,constants,objFns,pareto);
  elite  = updateElite(chains,constants,elite);
  if constants.verb>=1
    disp('...saving to file');
  end
  save('../data/hybrid.mat','chains','constants','params','objFns','true','dataMeasured','pop','pareto','elite');
  if constants.verb>=1
    disp(sprintf('...iteration compete, runtime %f',toc));
    disp(sprintf('...elite:  %i',length(elite)));
    disp(sprintf('...pareto: %i',length(pareto)));
    disp(sprintf('...pop:    %i',length(pop{i})));
  end
end
