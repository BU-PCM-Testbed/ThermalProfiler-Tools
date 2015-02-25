function function_table = ref_table_to_func(ref_table)

num_rows = size(ref_table,1);

num_data_points = num_rows * 10;

function_table = zeros(num_data_points,2);

index = 1;

for i = 1:num_rows
    
    for j = 1:10
        function_table(index,1) = ref_table(i,1) + (j-1);
        function_table(index,2) = ref_table(i,j+1);
        
        index = index + 1;
    end
  
  
end