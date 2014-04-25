function elite = updateElite(chains,constants,elite)

  for i = 1:constants.nc
    elite{length(elite)+1} = chains{i}.cycles{end};
  end

  unsorted=0;
  while ( unsorted<length(elite)-1 )
    unsorted=0;
    for i = 1:length(elite)-1
      if elite{i}.accepted.error.err>elite{i+1}.accepted.error.err
        temp = elite{i+1};
        elite{i+1} = elite{i};
        elite{i}   = temp;
      else
       	unsorted=unsorted+1;
      end
    end
  end

  while length(elite)>constants.eliteMax
    elite(end)=[];
  end
