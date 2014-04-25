classdef Chain < handle

  properties
    cycles;
  end

  methods

    function obj = Chain(cycle)
      obj.cycles{1}=cycle;
    end

  end

end
