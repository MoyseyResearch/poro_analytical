classdef Cycle < handle

  properties
    proposed;
    accepted;
    rejected;
  end

  methods

    function obj = Cycle(proposed)
      obj.proposed=proposed;
    end

  end

end
