function psd = cpsdm(input,window,overlap,nfft,fs)

%remove the dc component
for i=1:size(input,2)
   input(:,i) = input(:,i) - mean(input(:,i)); 
end

% Obtain the cpsd matrix
for i=1:size(input,2)
  for j=1:size(input,2)
    psd(i,j,:) = cpsd(input(:,i),input(:,j),window,overlap,nfft,fs);
  end
end