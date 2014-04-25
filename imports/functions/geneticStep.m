function [chains,newPop] = geneticStep(chains,params,constants,pareto,elite,oldPop)

  sumFitness=0;
  for i = 1:length(oldPop)
    sumFitness = sumFitness + oldPop{i}.accepted.error.fitness;
  end
  for i = 1:constants.nc
    sumFitness = sumFitness + chains{i}.cycles{end}.accepted.error.fitness;
  end

  k=1;
  survivors=[];
  for i = 1:constants.nc
    if (constants.survival*chains{i}.cycles{end}.accepted.error.fitness/sumFitness)<rand & length(survivors)<(constants.popMax-constants.nc)
      survivors{k} = chains{i}.cycles{end};
      k=k+1;
    end
  end
  for i = 1:length(oldPop)
    if (constants.survival*oldPop{i}.accepted.error.fitness/sumFitness)<rand & length(survivors)<(constants.popMax-constants.nc)
      survivors{k} = oldPop{i};
      k=k+1;
    end
  end

  gen = [survivors,elite,pareto];
  sumFitness=0;
  for i = 1:length(gen)
    sumFitness=sumFitness+gen{i}.accepted.error.fitness;
  end

  newPop=[];
  for i = 1:constants.nc
    while true
      parent1=gen{randi([1,length(gen)],1)};
      r1 = parent1.accepted.error.fitness/sumFitness;
      r2 = rand;
      if(r1<r2); break; end
    end
    while true
      parent2=gen{randi([1,length(gen)],1)};
      r1 = parent2.accepted.error.fitness/sumFitness;
      r2 = rand;
      if (r1<r2); break; end
    end

    for k = 1:length(parent1.accepted.params)
      if rand<0.5
        paramsOld{k}=parent1.accepted.params{k};
      else
        paramsOld{k}=parent2.accepted.params{k};
      end
      if rand<constants.mcProb
        paramsNew{k} = params{k}.prior.random;
        while paramsNew{k}<params{k}.bounds(1) || paramsNew{k}>params{k}.bounds(2)
          paramsNew{k} = params{k}.prior.random;
        end
      else
        paramsNew{k} = paramsOld{k} + randn *params{k}.step;
        while paramsNew{k}<params{k}.bounds(1) || paramsNew{k}>params{k}.bounds(2)
          paramsNew{k} = paramsOld{k} + randn *params{k}.step;
        end
      end
    end

    chains{i}.cycles{end+1}=Cycle(paramsNew);
    newPop{length(newPop)+1}=chains{i}.cycles{end};
  end

  newPop = [newPop,survivors];
