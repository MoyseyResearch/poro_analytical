function dataPredicted = mcmcForward(chains)

  % the mcmcForward function should take in the current chain structure,
  % and return a data structure. The output data could be a single number, 
  % a time-series, a 2D array, or just about anything that can fit in a 
  % cell array. It will also need to be compatible with the mcmcError function

  for i = 1:length(chains)
    j = length(chains{i}.cycles);

    r     = 0.2;
    t     = logspace(-2,log10(3600*6),100);
    Q     = chains{i}.cycles{j}.proposed.params{1};
    h     = chains{i}.cycles{j}.proposed.params{2};
    mu    = chains{i}.cycles{j}.proposed.params{3};
    k     = 10^chains{i}.cycles{j}.proposed.params{4};
    gamma = chains{i}.cycles{j}.proposed.params{5};
    D     = chains{i}.cycles{j}.proposed.params{6};

    rp = r.^2./(4*D.*t);
    p = Q./h./(4*pi*k./mu).*expint(rp);
    d = Q./h.*gamma./(4*pi*D).*r.*( (1-exp(-rp))./rp + expint(rp) );

    dataPredicted{i}{1} = p;
    dataPredicted{i}{2} = d;
  end
