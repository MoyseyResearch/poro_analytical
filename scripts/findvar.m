addpath ../imports/classes;
addpath ../imports/functions;

load('../data/hybrid.mat');

  values=[];
  for i = length(pop)-10:length(pop)
  for j = length(pop{i})
    values = [ values ; pop{i}{j}.accepted.params{1} ];
  end
  end
  var(values)

  values=[];
  for i = length(pop)-10:length(pop)
  for j = length(pop{i})
    values = [ values ; pop{i}{j}.accepted.params{2} ];
  end
  end
  var(values)

  values=[];
  for i = length(pop)-10:length(pop)
  for j = length(pop{i})
    values = [ values ; pop{i}{j}.accepted.params{3} ];
  end
  end
  var(values)

