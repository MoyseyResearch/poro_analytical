function data = mcmcData(true,constants)

  % the mcmcData function outputs the measured data
  % this could be a simple assignment, a call to a text file or excel file, 
  % or a call to an outside function that generates synthetic data and noise

  disp('...generating synthetic dataset');
  for i = 1:size(true,2)
    chains{1}.cycles{1}.proposed.params{i} = true{i}.value;
  end
  dataTrue = mcmcForward(chains);

  disp(sprintf('...introducing %f percent noise',constants.dataNoise*100));
  for i = 1:size(dataTrue{1},2)
    data{i} = dataTrue{1}{i} .* (1 + constants.dataNoise .* randn(size(dataTrue{1}{i})) );
  end
