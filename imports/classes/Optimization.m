classdef Optimization < handle

  properties
    populations;
    externals;
    chains;
    objectives;
    decisions;
    measured;
    constants;
  end

  methods

    function obj = Optimization(objectives,decisions,measured,constants,maintainExternal)
      obj.objectives=objectives;
      obj.decisions=decisions;
      obj.measured=measured;
      obj.constants=constants;
      for i = 1:obj.constants.nc
        for j = 1:length(obj.decisions)
           samples{i}{j} = Sample( obj.decisions{j}, obj.decisions{j}.prior.random );
           while samples{i}{j}.value<obj.decisions{j}.constraints(1) || samples{i}{j}.value>obj.decisions{j}.constraints(2)
             samples{i}{j} = Sample( obj.decisions{j}, obj.decisions{j}.prior.random );
           end
        end
      end
      data=forwardModel(samples,obj.objectives);
      for i = 1:constants.nc
        newSolution = Solution( samples{i}, data{i} );
        newSolution.setError(measured);
        newCycle = Cycle(newSolution);
        chains{i} = Chain(newCycle);
        chains{i}.cycles{1}.accepted = chains{i}.cycles{1}.proposed;
        solutions{i} = newSolution;
      end
      obj.chains = chains;
      obj.populations{1} = Population(solutions);
      if maintainExternal
        obj.externals{1}   = Population(solutions);
        obj.externals{1}.removeDominated;
      end
    end


    function obj = updatePareto(obj)
      for i = 1:length(obj.populations)
        obj.populations{i}.updatePareto;
      end
    end

    function obj = assignParetoDominance(obj)
      for i = 1:length(obj.populations)
        obj.populations{i}.assignParetoDominance;
      end
    end

    function [] = append(obj,solutions)
      obj.populations{end+1} = Population(solutions);
      if length(obj.externals)>0
        obj.externals{end+1}   = Population([solutions,obj.externals{end}.solutions]);
        obj.externals{end}.removeDominated;
      end
    end

    function [] = mc(obj,maxiter)
      for iter = 1:maxiter
        disp(sprintf('Monte Carlo, iteration %i',length(obj.populations)+1));
        for i = 1:obj.constants.nc
          for j = 1:length(obj.decisions)
             samples{i}{j} = Sample( obj.decisions{j}, obj.decisions{j}.prior.random );
             while samples{i}{j}.value<obj.decisions{j}.constraints(1) || samples{i}{j}.value>obj.decisions{j}.constraints(2)
               samples{i}{j} = Sample( obj.decisions{j}, obj.decisions{j}.prior.random );
             end
          end
        end
        data=forwardModel(samples,obj.objectives);
        for i = 1:obj.constants.nc
          newSolution = Solution( samples{i}, data{i} );
          newSolution.setError(obj.measured);
          obj.chains{i}.cycles{end+1} = Cycle(newSolution);
          obj.chains{i}.cycles{end}.accepted = obj.chains{i}.cycles{end}.proposed;
          obj.chains{i}.cycles{end}.rejected = obj.chains{i}.cycles{end-1}.accepted;
          solutions{i} = newSolution;
        end
        obj.append(solutions);
      end
    end

    function [] = mcmc(obj,maxiter)
      for iter = 1:maxiter
        disp(sprintf('MCMC, iteration %i',length(obj.populations)+1));
        for i = 1:length(obj.chains)
          for j = 1:length(obj.decisions)
            samples{i}{j} = Sample( obj.decisions{j}, obj.chains{i}.cycles{end}.accepted.samples{j}.value + randn*obj.decisions{j}.step );
            while samples{i}{j}.value<obj.decisions{j}.constraints(1) || samples{i}{j}.value>obj.decisions{j}.constraints(2)
              samples{i}{j} = Sample( obj.decisions{j}, obj.chains{i}.cycles{end}.accepted.samples{j}.value + randn*obj.decisions{j}.step );
            end
          end
        end
        data=forwardModel(samples,obj.objectives);
        for i = 1:obj.constants.nc
          newSolution = Solution( samples{i}, data{i} );
          newSolution.setError(obj.measured);
          obj.chains{i}.cycles{end+1} = Cycle(newSolution);
          if obj.chains{i}.cycles{end}.proposed.error < obj.chains{i}.cycles{end-1}.accepted.error
            obj.chains{i}.cycles{end}.accepted = obj.chains{i}.cycles{end}.proposed;
            obj.chains{i}.cycles{end}.rejected = obj.chains{i}.cycles{end-1}.accepted;
          elseif log(obj.chains{i}.cycles{end-1}.accepted.error-obj.chains{i}.cycles{end}.proposed.error)<rand
            obj.chains{i}.cycles{end}.accepted = obj.chains{i}.cycles{end}.proposed;
            obj.chains{i}.cycles{end}.rejected = obj.chains{i}.cycles{end-1}.accepted;
          else
            obj.chains{i}.cycles{end}.rejected = obj.chains{i}.cycles{end}.proposed;
            obj.chains{i}.cycles{end}.accepted = obj.chains{i}.cycles{end-1}.accepted;
          end
          solutions{i} = newSolution;
        end
        obj.append(solutions);
      end
    end

    function [] = sga(obj,maxiter)
      for iter = 1:maxiter
        disp(sprintf('SGA, iteration %i',length(obj.populations)+1));
        obj.populations{end}.fitAssignWeightedSums;
        survivors=obj.populations{end}.selectRoulette(0.1);
        newPop=survivors.crossoverUniform(0.5,length(obj.populations{end}.solutions));
%{
        data=forwardModel(samples,obj.objectives);
        for i = 1:obj.constants.nc
          newSolution = Solution( samples{i}, data{i} );
          newSolution.setError(obj.measured);
          obj.chains{i}.cycles{end+1} = Cycle(newSolution);
          obj.chains{i}.cycles{end}.accepted = obj.chains{i}.cycles{end}.proposed;
          solutions{i} = newSolution;
        end
        obj.append(solutions);
%}
      end
    end

    function [] = vega(obj,maxiter)
      for iter = 1:maxiter
        disp(sprintf('VEGA, iteration %i',length(obj.populations)+1));
        k=1;
        for n = 1:length(obj.objectives)
          sumFitness=0;
          for i=1:length(obj.populations{end}.solutions)
            sumFitness=sumFitness+obj.populations{end}.solutions{i}.realizations{n}.error;
          end
          while true
            p1=randi([1,length(obj.populations{end}.solutions)],1);
            while (obj.populations{end}.solutions{p1}.realizations{n}.error/sumFitness)>rand
              p1=randi([1,length(obj.populations{end}.solutions)],1);
            end
            p2=randi([1,length(obj.populations{end}.solutions)],1);
            while p1==p2 || (obj.populations{end}.solutions{p2}.realizations{n}.error/sumFitness)>rand
              p2=randi([1,length(obj.populations{end}.solutions)],1);
            end
            for j = 1:length(obj.decisions)
              if rand<0.5
                samples{k}{j} = Sample( obj.decisions{j}, obj.populations{end}.solutions{p1}.samples{j}.value + randn*obj.decisions{j}.step );
              else
                samples{k}{j} = Sample( obj.decisions{j}, obj.populations{end}.solutions{p2}.samples{j}.value + randn*obj.decisions{j}.step );
              end
            end
            k=k+1;
            if k> (obj.constants.nc/length(obj.objectives))*n
              break;
            end
          end
        end
        data=forwardModel(samples,obj.objectives);
        for i = 1:obj.constants.nc
          newSolution = Solution( samples{i}, data{i} );
          newSolution.setError(obj.measured);
          obj.chains{i}.cycles{end+1} = Cycle(newSolution);
          obj.chains{i}.cycles{end}.accepted = obj.chains{i}.cycles{end}.proposed;
          solutions{i} = newSolution;
        end
        obj.append(solutions);
      end
    end

    function [] = moga(obj,maxiter)
      for iter = 1:maxiter
        obj.populations{end}.updatePareto;
        for i = 1:length(obj.populations{end}.solutions)
          obj.populations{end}.solutions{i}.fitness = 1.0 / obj.populations{end}.solutions{i}.rank;
        end
        disp(sprintf('MOGA, iteration %i',length(obj.populations)+1));
        sumFitness=0;
        for i=1:length(obj.populations{end}.solutions)
          sumFitness=sumFitness+obj.populations{end}.solutions{i}.fitness;
        end
        k=1;
        while true
          p1=randi([1,length(obj.populations{end}.solutions)],1);
          while (obj.populations{end}.solutions{p1}.fitness/sumFitness)>rand
            p1=randi([1,length(obj.populations{end}.solutions)],1);
          end
          p2=randi([1,length(obj.populations{end}.solutions)],1);
          while p1==p2 || (obj.populations{end}.solutions{p2}.fitness/sumFitness)>rand
            p2=randi([1,length(obj.populations{end}.solutions)],1);
          end
          for j = 1:length(obj.decisions)
            if rand<0.5
              samples{k}{j} = Sample( obj.decisions{j}, obj.populations{end}.solutions{p1}.samples{j}.value + randn*obj.decisions{j}.step );
            else
              samples{k}{j} = Sample( obj.decisions{j}, obj.populations{end}.solutions{p2}.samples{j}.value + randn*obj.decisions{j}.step );
            end
          end
          k=k+1;
          if k>obj.constants.nc
            break;
          end
        end
        data=forwardModel(samples,obj.objectives);
        for i = 1:obj.constants.nc
          newSolution = Solution( samples{i}, data{i} );
          newSolution.setError(obj.measured);
          obj.chains{i}.cycles{end+1} = Cycle(newSolution);
          obj.chains{i}.cycles{end}.accepted = obj.chains{i}.cycles{end}.proposed;
          solutions{i} = newSolution;
        end
        obj.append(solutions);
      end
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{

    function [] = npga(obj,maxiter,tournamentSize,nicheRadius)
      for iter = 1:maxiter
        obj.populations{end}.updatePareto;
        for i = 1:length(obj.populations{end}.solutions)
          obj.populations{end}.solutions{i}.fitness = 1.0 / obj.populations{end}.solutions{i}.rank;
        end
        disp(sprintf('MOGA, iteration %i',length(obj.populations)+1));
        sumFitness=0;
        for i=1:length(obj.populations{end}.solutions)
          sumFitness=sumFitness+obj.populations{end}.solutions{i}.fitness;
        end
        k=1;
        while true
          p1=randi([1,length(obj.populations{end}.solutions)],1);
          while (obj.populations{end}.solutions{p1}.fitness/sumFitness)>rand
            p1=randi([1,length(obj.populations{end}.solutions)],1);
          end
          p2=randi([1,length(obj.populations{end}.solutions)],1);
          while p1==p2 || (obj.populations{end}.solutions{p2}.fitness/sumFitness)>rand
            p2=randi([1,length(obj.populations{end}.solutions)],1);
          end
          for j = 1:length(obj.decisions)
            if rand<0.5
              samples{k}{j} = Sample( obj.decisions{j}, obj.populations{end}.solutions{p1}.samples{j}.value + randn*obj.decisions{j}.step );
            else
              samples{k}{j} = Sample( obj.decisions{j}, obj.populations{end}.solutions{p2}.samples{j}.value + randn*obj.decisions{j}.step );
            end
          end
          k=k+1;
          if k>obj.constants.nc
            break;
          end
        end
        data=forwardModel(samples,obj.objectives);
        for i = 1:obj.constants.nc
          newSolution = Solution( samples{i}, data{i} );
          newSolution.setError(obj.measured);
          obj.chains{i}.cycles{end+1} = Cycle(newSolution);
          obj.chains{i}.cycles{end}.accepted = obj.chains{i}.cycles{end}.proposed;
          solutions{i} = newSolution;
        end
        obj.append(solutions);
      end
    end

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    function [] = plotPareto2D(obj,filename,objx,objy,nmin,nmax)
      k=1;
      for i = nmin:nmax
        for j = 1:length(obj.populations{i}.solutions)
          vals(k,1) = obj.populations{i}.solutions{j}.realizations{objx}.error;
          vals(k,2) = obj.populations{i}.solutions{j}.realizations{objy}.error;
          vals(k,3) = obj.populations{i}.solutions{j}.numDominatedBy;
          k=k+1;
        end
      end
      for i = nmin:nmax
        disp(sprintf('Plotting objective %i against %i, iteration %i',objx,objy,i));
        for j = 1:length(obj.populations{i}.solutions)
          pop(j,1) = obj.populations{i}.solutions{j}.realizations{objx}.error;
          pop(j,2) = obj.populations{i}.solutions{j}.realizations{objy}.error;
          pop(j,3) = obj.populations{i}.solutions{j}.numDominatedBy;
        end
        for j = 1:length(obj.externals{i}.solutions)
          ext(j,1) = obj.externals{i}.solutions{j}.realizations{objx}.error;
          ext(j,2) = obj.externals{i}.solutions{j}.realizations{objy}.error;
          ext(j,3) = obj.externals{i}.solutions{j}.numDominatedBy;
        end
        ext=sortrows(ext,1);
        figure;
        hold on;
        scatter(pop(:,1), pop(:,2), 20, pop(:,3), 'fill');
        xlim([min(vals(:,1)) max(vals(:,1))]);
        ylim([min(vals(:,2)) max(vals(:,2))]);
        set(gca, 'XScale', 'log');
        set(gca, 'YScale', 'log');
        colorbar;
        caxis([min(vals(:,3)) max(vals(:,3))]);
        plot(ext(:,1),ext(:,2),'k');
        scatter(ext(:,1), ext(:,2), 30, 'k', 'fill');
        title(sprintf('Iteration: %i',i),'fontsize',30);
        xlabel(sprintf('%s: %s [%s]',obj.objectives{objx}.location.title,obj.objectives{objx}.instrument.title,obj.objectives{objx}.instrument.units),'fontsize',20);
        ylabel(sprintf('%s: %s [%s]',obj.objectives{objy}.location.title,obj.objectives{objy}.instrument.title,obj.objectives{objy}.instrument.units),'fontsize',20);
        set(gca,'fontsize',30);
        set(gca,'ticklength',3*get(gca,'ticklength'));
        print( '-depsc2', sprintf('%s%05i.eps',filename,i) );
        close all;
        clear par, pop;
      end
    end

    function [] = plotPareto2Dall(obj,filename,nmin,nmax)
      combs = combnk([1:length(obj.objectives)],2);
      for i = combs(:,1)
      for j = combs(:,2)
        plotPareto2D(obj,sprintf('%s_obj%02i_obj%02i_',filename,i,j),i,j,nmin,nmax);
      end
      end
    end

    function [] = plotDecisionVariables(obj,filename,nmin,nmax)
      for k = 1:length(obj.decisions)
      for n = nmin:nmax
        disp(sprintf('Plotting decision variable %i, iteration %i',k,n));
        figure;
        hold on;
        for i = 1:length(obj.chains)
        for j = 1:n
          pop(j) = obj.chains{i}.cycles{j}.accepted.samples{k}.value;
        end
        plot([1:n],pop);
        end
        xlim([1 nmax]);
        ylim(obj.decisions{k}.constraints);
        title(sprintf('Iteration: %i',n),'fontsize',30);
        xlabel('Iterations','fontsize',20);
        ylabel(sprintf('%s: %s [%s]',obj.decisions{k}.domain.title,obj.decisions{k}.parameter.title,obj.decisions{k}.parameter.units),'fontsize',20);
        set(gca,'fontsize',30);
        set(gca,'ticklength',3*get(gca,'ticklength'));
        print( '-depsc2', sprintf('%s%02i_%05i.eps',filename,k,n) );
        close all;
        clear pop;
      end
      end
    end

  end
end
