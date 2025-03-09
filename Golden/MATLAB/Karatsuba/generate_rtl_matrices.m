% Generate RTL-compatible representation of matrices
function generate_rtl_matrices(EVAL, POSTprocess)
    % Open file
    fid = fopen('matrix_coefficients.vh', 'w');
    
    fprintf(fid, '// Transformation matrix coefficients definition (N=16, q=998244353)\n\n');
    
    % Output evaluation matrix
    [rows, cols] = size(EVAL);
    fprintf(fid, '// Evaluation matrix (EVAL) - %dx%d\n', rows, cols);
    fprintf(fid, '`define EVAL_ROWS %d\n', rows);
    fprintf(fid, '`define EVAL_COLS %d\n', cols);
    fprintf(fid, 'parameter logic [1:0] EVAL_MATRIX[0:%d-1][0:%d-1] = ''{\n', rows, cols);
    
    for i = 1:rows
        fprintf(fid, '  ''{ ');
        for j = 1:cols
            if j < cols
                fprintf(fid, '%d, ', EVAL(i,j));
            else
                fprintf(fid, '%d', EVAL(i,j));
            end
        end
        if i < rows
            fprintf(fid, ' },\n');
        else
            fprintf(fid, ' }\n');
        end
    end
    fprintf(fid, '};\n\n');
    
    % Output post-processing matrix (POSTprocess)
    % Note: Due to the large size of this matrix, we output a sparse version
    [rows, cols] = size(POSTprocess);
    fprintf(fid, '// Post-processing matrix (POSTprocess) - %dx%d\n', rows, cols);
    fprintf(fid, '// Stored in sparse format [row, col, value]\n');
    fprintf(fid, '`define POSTPROC_ROWS %d\n', rows);
    fprintf(fid, '`define POSTPROC_COLS %d\n', cols);
    fprintf(fid, '`define POSTPROC_NONZEROS %d\n', nnz(POSTprocess));
    fprintf(fid, 'parameter postproc_entry_t POSTPROC_MATRIX[0:%d-1] = ''{\n', nnz(POSTprocess));
    
    % Find non-zero elements
    idx = 0;
    [r, c, v] = find(POSTprocess);
    for i = 1:length(r)
        fprintf(fid, '  ''{ %d, %d, %d }', r(i)-1, c(i)-1, v(i)); % 0-based indexing for HDL
        if i < length(r)
            fprintf(fid, ',\n');
        else
            fprintf(fid, '\n');
        end
        idx = idx + 1;
    end
    fprintf(fid, '};\n\n');
    
    fclose(fid);
    fprintf('Generated RTL-compatible matrix definitions to matrix_coefficients.vh\n');
end