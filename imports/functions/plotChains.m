function [] = plotChains(opt)

  for n = 1:length(opt.chains{1}.cycles)
  disp(sprintf('Plotting iteration %i',n));

  k=1;
  for j = 1:length(opt.chains)
    pop(k,1) = opt.chains{j}.cycles{n}.accepted.realizations{1}.error;
    pop(k,2) = opt.chains{j}.cycles{n}.accepted.realizations{2}.error;
    pop(k,3) = opt.chains{j}.cycles{n}.accepted.rank;
    k=k+1;
  end

  figure;
  hold on;
  scatter(pop(:,1), pop(:,2), 20, pop(:,3), 'fill');
  title(sprintf('Iteration: %i',n),'fontsize',30);
  xlabel('Pressure [Pa]','fontsize',30);
  ylabel('Displacement [m]','fontsize',30);
  xlim([10^(5) 10^(20)]);
  ylim([10^(-20) 10^(-8)]);
  set(gca, 'XScale', 'log');
  set(gca, 'YScale', 'log');
  set(gca,'fontsize',30);
  set(gca,'ticklength',3*get(gca,'ticklength'));
  print( '-depsc2', sprintf('../frames/pareto_%05i.eps',n) );
  close all;
  clear par, pop;

  end
