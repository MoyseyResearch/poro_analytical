function [] = plotComparison(opt1,opt2,opt3,opt4,opt5,filename,objx,objy,nmin,nmax)

  k=1;
  for n = 1:nmax
    for j = 1:length(opt1.populations{n}.solutions)
      pop(k,1) = opt1.populations{n}.solutions{j}.realizations{objx}.error;
      pop(k,2) = opt1.populations{n}.solutions{j}.realizations{objy}.error;
      k=k+1;
    end
    for j = 1:length(opt2.populations{n}.solutions)
      pop(k,1) = opt2.populations{n}.solutions{j}.realizations{objx}.error;
      pop(k,2) = opt2.populations{n}.solutions{j}.realizations{objy}.error;
      k=k+1;
    end
    for j = 1:length(opt3.populations{n}.solutions)
      pop(k,1) = opt3.populations{n}.solutions{j}.realizations{objx}.error;
      pop(k,2) = opt3.populations{n}.solutions{j}.realizations{objy}.error;
      k=k+1;
    end
    for j = 1:length(opt4.populations{n}.solutions)
      pop(k,1) = opt4.populations{n}.solutions{j}.realizations{objx}.error;
      pop(k,2) = opt4.populations{n}.solutions{j}.realizations{objy}.error;
      k=k+1;
    end
    for j = 1:length(opt5.populations{n}.solutions)
      pop(k,1) = opt5.populations{n}.solutions{j}.realizations{objx}.error;
      pop(k,2) = opt5.populations{n}.solutions{j}.realizations{objy}.error;
      k=k+1;
    end
  end
  xmin = min(pop(:,1));
  xmax = max(pop(:,1));
  ymin = min(pop(:,2));
  ymax = max(pop(:,2));
  clear pop;

  for n = nmin:nmax
    disp(sprintf('Plotting iteration %i',n));

    figure;
    hold on;
    xlim([xmin xmax]);
    ylim([ymin ymax]);
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    set(gca,'fontsize',20);
    set(gca,'ticklength',3*get(gca,'ticklength'));

    for j = 1:length(opt1.populations{n}.solutions)
      pop(j,1) = opt1.populations{n}.solutions{j}.realizations{objx}.error;
      pop(j,2) = opt1.populations{n}.solutions{j}.realizations{objy}.error;
    end
    for j = 1:length(opt1.externals{n}.solutions)
      ext(j,1) = opt1.externals{n}.solutions{j}.realizations{objx}.error;
      ext(j,2) = opt1.externals{n}.solutions{j}.realizations{objy}.error;
    end
    ext=sortrows(ext,1);
    scatter(pop(:,1), pop(:,2), 15, 'ro');
    plot(ext(:,1),ext(:,2),'r');
    h(1)=scatter(ext(:,1), ext(:,2), 30, 'ro', 'fill');
    clear pop, ext;

    for j = 1:length(opt2.populations{n}.solutions)
      pop(j,1) = opt2.populations{n}.solutions{j}.realizations{objx}.error;
      pop(j,2) = opt2.populations{n}.solutions{j}.realizations{objy}.error;
    end
    for j = 1:length(opt2.externals{n}.solutions)
      ext(j,1) = opt2.externals{n}.solutions{j}.realizations{objx}.error;
      ext(j,2) = opt2.externals{n}.solutions{j}.realizations{objy}.error;
    end
    ext=sortrows(ext,1);
    scatter(pop(:,1), pop(:,2), 15, 'bo');
    plot(ext(:,1),ext(:,2),'b');
    h(2)=scatter(ext(:,1), ext(:,2), 30, 'bo', 'fill');
    clear pop, ext;

    for j = 1:length(opt3.populations{n}.solutions)
      pop(j,1) = opt3.populations{n}.solutions{j}.realizations{objx}.error;
      pop(j,2) = opt3.populations{n}.solutions{j}.realizations{objy}.error;
    end
    for j = 1:length(opt3.externals{n}.solutions)
      ext(j,1) = opt3.externals{n}.solutions{j}.realizations{objx}.error;
      ext(j,2) = opt3.externals{n}.solutions{j}.realizations{objy}.error;
    end
    ext=sortrows(ext,1);
    scatter(pop(:,1), pop(:,2), 15, 'go');
    plot(ext(:,1),ext(:,2),'g');
    h(3)=scatter(ext(:,1), ext(:,2), 30, 'go', 'fill');
    clear pop, ext;

    for j = 1:length(opt4.populations{n}.solutions)
      pop(j,1) = opt4.populations{n}.solutions{j}.realizations{objx}.error;
      pop(j,2) = opt4.populations{n}.solutions{j}.realizations{objy}.error;
    end
    for j = 1:length(opt4.externals{n}.solutions)
      ext(j,1) = opt4.externals{n}.solutions{j}.realizations{objx}.error;
      ext(j,2) = opt4.externals{n}.solutions{j}.realizations{objy}.error;
    end
    ext=sortrows(ext,1);
    scatter(pop(:,1), pop(:,2), 15, 'co');
    plot(ext(:,1),ext(:,2),'c');
    h(4)=scatter(ext(:,1), ext(:,2), 30, 'co', 'fill');
    clear pop, ext;

    for j = 1:length(opt5.populations{n}.solutions)
      pop(j,1) = opt5.populations{n}.solutions{j}.realizations{objx}.error;
      pop(j,2) = opt5.populations{n}.solutions{j}.realizations{objy}.error;
    end
    for j = 1:length(opt5.externals{n}.solutions)
      ext(j,1) = opt5.externals{n}.solutions{j}.realizations{objx}.error;
      ext(j,2) = opt5.externals{n}.solutions{j}.realizations{objy}.error;
    end
    ext=sortrows(ext,1);
    scatter(pop(:,1), pop(:,2), 15, 'mo');
    plot(ext(:,1),ext(:,2),'m');
    h(5)=scatter(ext(:,1), ext(:,2), 30, 'mo', 'fill');
    clear pop, ext;

    legend(h,'MC','MCMC','SGA','VEGA','MOGA','location','SouthEast');
    title(sprintf('Iteration: %i',n),'fontsize',30);
    xlabel(sprintf('%s: %s',opt1.objectives{objx}.location.title,opt1.objectives{objx}.instrument.title),'fontsize',20);
    ylabel(sprintf('%s: %s',opt1.objectives{objy}.location.title,opt1.objectives{objy}.instrument.title),'fontsize',20);
    print( '-depsc2', sprintf('%s%05i.eps',filename,n) );
    close all;
  end
