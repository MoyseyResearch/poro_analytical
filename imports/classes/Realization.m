classdef Realization < handle

  properties
    objective;
    predicted;
    error;
  end

  methods

    function obj = Realization(objective,predicted)
      obj.objective=objective;
      obj.predicted=predicted;
    end

  end

end
