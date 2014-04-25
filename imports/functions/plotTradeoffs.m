function [] = plotOptimization(chains,params,constants,objFns,data,true,pareto,elite,pop)

  for i = 1:length(pop)
    disp( sprintf('Plotting frame %i',i) );
    figure;
    for j = 1:length(pop{i})
      scatter3( pop{i}{j}.accepted.params{1},pop{i}{j}.accepted.params{2},pop{i}{j}.accepted.params{3}, 'k.' );
      hold on;
    end
    scatter3( log10(15e9), -6, 20, 'r', 'fill' );
    xlim([ 9 11 ]);
    ylim([ -7 -5 ]);
    zlim([ 0.05 0.45 ]);
    title(sprintf('Iteration: %i',i+1),'fontsize',30);
    xlabel('Log E','fontsize',30);
    ylabel('Log k','fontsize',30);
    zlabel('Poisson ratio','fontsize',30);
    view([120+3*i,30]);
    print( '-depsc2', sprintf('../frames/tradeoff_view3_iter%05i.eps',i) );
    close all;
  end
