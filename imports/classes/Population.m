classdef Population < handle

  properties
    solutions;
  end

  methods

    function obj = Population(solutions)
      obj.solutions=solutions;
    end

    function [] = updatePareto(obj)
      obj.assignParetoRanks(1);
    end

    function [] = updateUnique(obj)
      updated=0;
      while (updated==0)
        updated=1;
        for i = 1:length(obj.solutions)
        for j = 1:length(obj.solutions)
          if i~=j && obj.solutions{i} == obj.solutions{j}
            obj.solutions(i)=[];
            updated=0;
            break;
          end
        end
        if updated==0
          break;
        end
        end
      end
    end

    function [] = assignParetoRanks(obj,rank)
      for i = 1:length(obj.solutions)
        solutions{i} = obj.solutions{i};
        solutions{i}.rank=rank;
      end
      found=0;
      for i = 1:length(solutions)
        for j = 1:length(solutions)
          for k = 1:length(solutions{j}.realizations)
            par(k) = solutions{j}.realizations{k}.error<solutions{i}.realizations{k}.error;
          end
          if prod(par)==1
            solutions{i}.rank=solutions{i}.rank+1;
            found=found+1;
            break;
          end
        end
      end
      while true
        for i = 1:length(solutions)
          if solutions{i}.rank==rank
            solutions(i)=[];
            break;
          end
        end
        if i==length(solutions) || length(solutions)==0; break; end
      end
      if found>0
        newPop=Population(solutions);
        newPop.assignParetoRanks(rank+1);
      end
    end

    function [] = removeDominated(obj)
      found=0;
      for i = 1:length(obj.solutions)
        for j = 1:length(obj.solutions)
          for k = 1:length(obj.solutions{j}.realizations)
            par(k) = obj.solutions{j}.realizations{k}.error<obj.solutions{i}.realizations{k}.error;
          end
          if prod(par)==1
            obj.solutions(i)=[];
            found=1;
            break;
          end
        end
        if found==1
          break;
        end
      end
      if found==1
        obj.removeDominated;
      end
    end

    function [] = assignParetoDominance(obj)
      for i = 1:length(obj.solutions)
        obj.solutions{i}.numDominating=0;
        obj.solutions{i}.numDominatedBy=0;
      end
      for i = 1:length(obj.solutions)
      for j = 1:length(obj.solutions)
        for k = 1:length(obj.solutions{i}.realizations)
          par(k) = obj.solutions{j}.realizations{k}.error<obj.solutions{i}.realizations{k}.error;
        end
        if prod(par)==1
          obj.solutions{i}.numDominatedBy = obj.solutions{i}.numDominatedBy+1;
          obj.solutions{j}.numDominating  = obj.solutions{j}.numDominating+1;
        end
      end
      end
    end

    function [] = sortByWeightedError(obj)
      updated=0;
      while (updated==0)
        updated=1;
        for i = 1:length(obj.solutions)-1
          if obj.solutions{i}.error > obj.solutions{i+1}.error
            temp=obj.solutions{i};
            obj.solutions{i}=obj.solutions{i+1};
            obj.solutions{i+1}=temp;
            updated=0;
            break;
          end
        end
      end
    end    

    function [] = sortByFitness(obj)
      updated=0;
      while (updated==0)
        updated=1;
        for i = 1:length(obj.solutions)-1
          if obj.solutions{i}.fitness > obj.solutions{i+1}.fitness
            temp=obj.solutions{i};
            obj.solutions{i}=obj.solutions{i+1};
            obj.solutions{i+1}=temp;
            updated=0;
            break;
          end
        end
      end
    end

    function [] = fitAssignWeightedSums(obj)
      for i = 1:length(obj.solutions)
        fitness=0;
        for k = 1:length(obj.solutions{i}.realizations)
          fitness=fitness+obj.solutions{i}.realizations{k}.objective.weight/obj.solutions{i}.realizations{k}.error;
        end
        obj.solutions{i}.fitness=fitness;
      end
    end

    function survivors = selectTruncate(obj,survivalRate)
      for i = 1:floor(length(obj.solutions)*survivalRate)
        survivors{i} = obj.solutions{i};
      end
      survivors = Population(survivors);
    end

    function survivors = selectRoulette(obj,survivalRate)
      oldPop=Population(obj.solutions);
      survivors=[];
      while length(survivors)<floor(length(obj.solutions)*survivalRate)
        sumFitness=0;
        for i=1:length(oldPop.solutions)
          sumFitness=sumFitness+oldPop.solutions{i}.fitness;
        end
        p1=randi([1,length(oldPop.solutions)],1);
        while (oldPop.solutions{p1}.fitness/sumFitness)>rand
	  p1=randi([1,length(oldPop.solutions)],1);
	end
        survivors{end+1}=oldPop.solutions{p1};
        oldPop.solutions(p1)=[];
      end
      survivors = Population(survivors);
    end

%{
    function newPop = crossoverUniform(obj,crossoverRate,popSize)
      sumFitness=0;
      for i=1:length(obj.solutions)
	sumFitness=sumFitness+obj.solutions{i}.fitness;
      end
      k=k+1;
      while true
        p1=randi([1,length(obj.solutions)],1);
        while (obj.solutions{p1}.fitness/sumFitness)>rand
	  p1=randi([1,length(obj.solutions)],1);
	end
        p2=randi([1,length(obj.solutions)],1);
        while p1==p2 || (obj.solutions{p2}.fitness/sumFitness)>rand
          p2=randi([1,length(obj.solutions)],1);
        end
        if k<floor(crossoverRate*popSize)
          for j = 1:length(obj.solutions{1}.samples)
            samples{j} = Sample( obj.solutions{1}.samples{j}.decision, obj.solutions{p1);
          end
        else
          for j = 1:length(obj.solutions{1}.samples)
            if rand<0.5
              samples{k}{j} = Sample( obj.solutions{1}.samples{j}.decision, obj.solutions{p1}.samples{j}.value );
            else
              samples{k}{j} = Sample( obj.solutions{1}.samples{j}.decision, obj.solutions{p2}.samples{j}.value );
            end
          end
        end
        k=k+1;
        if k>popSize
          break;
        end
      end
      for k = 1:popSize        
      end
    end
%}

  end
end
