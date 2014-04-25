function [] = plotOptimization(opt,trueSolution)

  nmax = length(opt.populations);

  for n = 1:nmax
  disp( sprintf('Plotting frame %i',n) );

  for k = 1:length(opt.decisions)
    disp(sprintf('...decision variable: %i',k));
    figure;
    hold on;
    for i = 1:length(opt.chains)
      for j = 1:n
        line(j) = opt.chains{i}.cycles{j}.accepted.samples{k}.value;
      end
      plot(1:n, line, 'color', [0 0 1], 'linewidth', 1.5 );
      clear line;
    end
    plot([1 n],[trueSolution.samples{k}.value trueSolution.samples{k}.value],'r--','linewidth',3.5);
    title(sprintf('%s: %s',opt.decisions{k}.domain.title,opt.decisions{k}.parameter.title),'fontsize',30);
    xlabel('Iterations','fontsize',30);
    xlim([0,nmax]);
    ylim(opt.decisions{k}.constraints);
    set(gca,'fontsize',30);
    set(gca,'ticklength',3*get(gca,'ticklength'));
    print( '-depsc2', sprintf('../frames/dec%02i_iter%05i.eps',k,n) );
    close all;
  end

  for k = 1:length(opt.objectives)
    disp(sprintf('...objective: %i',k));
    figure;
    hold on;
    if opt.objectives{k}.weight==0
      scatter( opt.objectives{k}.times.times, trueSolution.realizations{k}.predicted, 20, [1 0 0], 'fill' );
    else
      scatter( opt.objectives{k}.times.times, trueSolution.realizations{k}.predicted, 20, [0 0 1], 'fill' );
    end
    axis(axis);
    set(gca, 'XScale', 'log');
    for i = 1:length(opt.chains)
      plot( opt.objectives{k}.times.times, opt.chains{i}.cycles{n}.accepted.realizations{k}.predicted, 'color', [0.4 0.4 0.4], 'linewidth', 1.5 );
    end
    if opt.objectives{k}.weight==0
      scatter( opt.objectives{k}.times.times, trueSolution.realizations{k}.predicted, 20, [1 0 0], 'fill' );
    else
      scatter( opt.objectives{k}.times.times, trueSolution.realizations{k}.predicted, 20, [0 0 1], 'fill' );
    end
    title(sprintf('%s: %s',opt.objectives{k}.location.title,opt.objectives{k}.instrument.title),'fontsize',30);
    set(gca,'fontsize',30);
    set(gca,'ticklength',3*get(gca,'ticklength'));
    print( '-depsc2', sprintf('../frames/obj%02i_iter%05i.eps',k,n) );
    close all;
  end

  end
