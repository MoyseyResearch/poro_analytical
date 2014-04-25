function chains = mcmcStep(chains,constants)

  % the mcmcStep function takes in the current chain structure and adds a
  % new cycle to the end of each chain, each with a set of parameters that
  % somehow follows from the last cycle. This could simply mean perturbing
  % values by a set amount, or could involve a varying step size. Since you
  % already have the entire chain structure handy inside the scope of this 
  % function, you can easily find the errors and variances of the chains

  for i = 1:constants.nc

    if chains{i}.cycles{end}.proposed.error.err < chains{i}.cycles{end-1}.accepted.error.err
      chains{i}.cycles{end}.accepted = chains{i}.cycles{end}.proposed;
      chains{i}.cycles{end}.rejected = chains{i}.cycles{end-1}.accepted;
    elseif log(chains{i}.cycles{end-1}.accepted.error.err-chains{i}.cycles{end}.proposed.error.err)<rand
      chains{i}.cycles{end}.accepted = chains{i}.cycles{end}.proposed;
      chains{i}.cycles{end}.rejected = chains{i}.cycles{end-1}.accepted;
    else
      chains{i}.cycles{end}.accepted = chains{i}.cycles{end-1}.accepted;
      chains{i}.cycles{end}.rejected = chains{i}.cycles{end}.proposed;
    end

  end
