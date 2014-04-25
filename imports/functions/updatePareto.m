function paretoNew = updatePareto(chains,constants,objFns,paretoOld)

  for i = 1:constants.nc
    paretoOld{length(paretoOld)+1} = chains{i}.cycles{end};
  end

  paretoNew=[];
  for i = 1:length(paretoOld)
  isPareto=1;
  for j = 1:length(paretoOld)
    if (i~=j)
      for k = 1:length(paretoOld{i}.accepted.error.obj)
        if (objFns{k}.weight==0)
          obj(k)=1;
        else
          obj(k)=paretoOld{i}.accepted.error.obj{k}>paretoOld{j}.accepted.error.obj{k};
        end
      end
      if prod(obj)
        isPareto=0;
        break;
      end
    end
  end
  if isPareto
    paretoNew{length(paretoNew)+1}=paretoOld{i};
  end
  end
