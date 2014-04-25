classdef Decision < handle

  properties
    domain;
    parameter;
    prior;
    constraints;
    step;
  end

  methods

    function obj = Decision(domain,parameter,prior,constraints,step)
      obj.domain=domain;
      obj.parameter=parameter;
      obj.prior=prior;
      obj.constraints=constraints;
      obj.step=step;
    end

  end

end
