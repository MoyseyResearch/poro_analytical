classdef Objective < handle

  properties
    location;
    instrument;
    times;
    weight;
    noise;
  end

  methods

    function obj = Objective(location,instrument,times,weight,noise)
      obj.location=location;
      obj.instrument=instrument;
      obj.times=times;
      obj.weight=weight;
      obj.noise=noise;
    end

  end

end
