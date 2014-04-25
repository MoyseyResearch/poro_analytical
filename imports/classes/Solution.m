classdef Solution < handle

  properties
    samples;
    realizations;
    fitness;
    rank;
    numDominating;
    numDominatedBy;
  end

  methods

    function obj = Solution(samples,realizations)
      obj.samples=samples;
      obj.realizations=realizations;
    end

    function obj = setError(obj,measured)
      for i = 1:length(obj.realizations)
        obj.realizations{i}.error = sum( (obj.realizations{i}.predicted-measured{i}.predicted).^2 );
      end
    end

    function error = error(obj)
      error=0;
      for i = 1:length(obj.realizations)
        error=error+obj.realizations{i}.objective.weight * obj.realizations{i}.error;
      end
    end

  end

end
