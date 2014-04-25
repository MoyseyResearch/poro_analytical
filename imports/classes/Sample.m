classdef Sample < handle

  properties
    decision;
    value;
  end

  methods

    function obj = Sample(decision,value)
      obj.decision=decision;
      obj.value=value;
    end

  end

end
