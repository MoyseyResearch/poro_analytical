function data = forwardModel(sample,objectives)

  for i = 1:length(sample)

    Q     = sample{i}{1}.value;
    h     = sample{i}{2}.value;
    mu    = sample{i}{3}.value;
    k     = 10^sample{i}{4}.value;
    gamma = sample{i}{5}.value;
    D     = sample{i}{6}.value;

    for j = 1:length(objectives)
      r = objectives{j}.location.location;
      t = objectives{j}.times.times;
      rp = r.^2./(4*D.*t);
      p = Q./h./(4*pi*k./mu).*expint(rp);
      d = Q./h.*gamma./(4*pi*D).*r.*( (1-exp(-rp))./rp + expint(rp) );
      if objectives{j}.instrument.abv=='p'
        data{i}{j} = Realization(objectives{j}, p * (1+randn*objectives{j}.noise) );
      else
        data{i}{j} = Realization(objectives{j}, d * (1+randn*objectives{j}.noise) );
      end
    end

  end
