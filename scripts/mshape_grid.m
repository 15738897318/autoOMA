function modepar = mshape_grid(modepar, mshape_length, res)

for i=1:length(modepar)
  fprintf('processing mode %d, fn : %0.2f\n',i,modepar(i).fn);
  modepar(i).comgrid = create_grid(complex2realmode(modepar(i).paddedmshape), mshape_length, res);
  modepar(i).regrid = create_grid(real(modepar(i).paddedmshape), mshape_length, res);
  modepar(i).imgrid = create_grid(imag(modepar(i).paddedmshape), mshape_length, res);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function grid = create_grid(mshape, mshape_length, res)
%helper function for mshape_grid to extract each mode shape new grid points
length(mshape)
%check the sizing
if rem(length(mshape),mshape_length) ~= 0
  error('mode shape length is incorrect, length is not divisible');
end

%check if modeshape is row vector, if yes, transpose it into column vector
if isrow(mshape)
  mshape = mshape';
end

%temporary grid storage
temp_grid = [];

%create curve fitted grid points in length direction
i = 1;
j = 1;
while i <= length(mshape)
  old_gridpoint = 1:mshape_length;
  new_gridpoint = 1:res:mshape_length;

  %curve fitting into new grid points
  temp_grid(:,j) = spline(old_gridpoint, mshape(i : i + mshape_length - 1),new_gridpoint);

  %update counter
  i = i + mshape_length;
  j = j + 1;
end

%final grid storage
grid = [];
%temporary grid dimension size
temp_gridsize = size(temp_grid);

%curve fitted grid in second dimension
for i=1:temp_gridsize(1)
  old_gridpoint = 1:temp_gridsize(2);
  new_gridpoint = 1:res:temp_gridsize(2);

  %curve fitting into new grid points
  grid(i,:) = spline(old_gridpoint, temp_grid(i,:),new_gridpoint);
end