function [] = plotStuff(opt)

  for i = 1:length(opt.populations)
    for j = 1:length(opt.populations{i}.solutions)
      pop(j,1) = opt.populations{i}.solutions{j}.realizations{1}.error;
      pop(j,2) = opt.populations{i}.solutions{j}.realizations{2}.error;
      pop(j,3) = opt.populations{i}.solutions{j}.rank;
    end

    figure;
    hold on;
    scatter(pop(:,1), pop(:,2), 20, pop(:,3), 'fill');
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    set(gca,'fontsize',30);
    set(gca,'ticklength',3*get(gca,'ticklength'));
    print( '-depsc2', '../frames/pareto_.eps' );
    close all;
    clear pop;

  end
