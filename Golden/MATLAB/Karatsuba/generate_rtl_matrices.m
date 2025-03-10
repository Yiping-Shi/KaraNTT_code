% Generate RTL-compatible representation of matrices
function generate_rtl_matrices(EVAL, POSTprocess)
    % Open file
    fid = fopen('matrix_coefficients.vh', 'w');
    
    fprintf(fid, '// Transformation matrix coefficients definition (N=16, q=998244353)\n\n');
    
    % Output evaluation matrix in sparse format
    [rows, cols] = size(EVAL);
    fprintf(fid, '// Evaluation matrix (EVAL) - %dx%d\n', rows, cols);
    fprintf(fid, '// Stored in sparse format [row, col, value]\n');
    fprintf(fid, '`define EVAL_ROWS %d\n', rows);
    fprintf(fid, '`define EVAL_COLS %d\n', cols);
    fprintf(fid, '`define EVAL_NONZEROS %d\n', nnz(EVAL));
    fprintf(fid, 'parameter eval_entry_t EVAL_MATRIX[0:%d-1] = ''{\n', nnz(EVAL));
    
    % Find non-zero elements in EVAL
    [r_eval, c_eval, v_eval] = find(EVAL);
    for i = 1:length(r_eval)
        fprintf(fid, '  ''{ %d, %d, %d }', r_eval(i)-1, c_eval(i)-1, v_eval(i)); % 0-based indexing for HDL
        if i < length(r_eval)
            fprintf(fid, ',\n');
        else
            fprintf(fid, '\n');
        end
    end
    fprintf(fid, '};\n\n');
    
    % Column pointer array for EVAL (CSC format)
    fprintf(fid, '// EVAL matrix - column pointers\n');
    fprintf(fid, '`define EVAL_COL_PTRS %d\n', cols+1);
    fprintf(fid, 'parameter int EVAL_COL_PTR[0:%d] = ''{\n  ', cols);
    
    % Calculate column pointers for EVAL
    col_ptr_eval = zeros(cols+1, 1);
    for i = 1:length(c_eval)
        col_ptr_eval(c_eval(i)+1) = col_ptr_eval(c_eval(i)+1) + 1;
    end
    for i = 2:cols+1
        col_ptr_eval(i) = col_ptr_eval(i) + col_ptr_eval(i-1);
    end
    
    % Output column pointers
    for i = 1:cols+1
        fprintf(fid, '%d', col_ptr_eval(i));
        if i < cols+1
            fprintf(fid, ', ');
            if mod(i, 8) == 0
                fprintf(fid, '\n  ');
            end
        end
    end
    fprintf(fid, '\n};\n\n');
    
    % Output post-processing matrix (POSTprocess)
    [rows, cols] = size(POSTprocess);
    fprintf(fid, '// Post-processing matrix (POSTprocess) - %dx%d\n', rows, cols);
    fprintf(fid, '// Stored in sparse format [row, col, value]\n');
    fprintf(fid, '`define POSTPROC_ROWS %d\n', rows);
    fprintf(fid, '`define POSTPROC_COLS %d\n', cols);
    fprintf(fid, '`define POSTPROC_NONZEROS %d\n', nnz(POSTprocess));
    fprintf(fid, 'parameter postproc_entry_t POSTPROC_MATRIX[0:%d-1] = ''{\n', nnz(POSTprocess));
    
    % Find non-zero elements in POSTprocess
    [r_post, c_post, v_post] = find(POSTprocess);
    for i = 1:length(r_post)
        fprintf(fid, '  ''{ %d, %d, %d }', r_post(i)-1, c_post(i)-1, v_post(i)); % 0-based indexing for HDL
        if i < length(r_post)
            fprintf(fid, ',\n');
        else
            fprintf(fid, '\n');
        end
    end
    fprintf(fid, '};\n\n');
    
    % Column pointer array for POSTprocess (CSC format)
    fprintf(fid, '// POSTPROC matrix - column pointers\n');
    fprintf(fid, '`define POSTPROC_COL_PTRS %d\n', cols+1);
    fprintf(fid, 'parameter int POSTPROC_COL_PTR[0:%d] = ''{\n  ', cols);
    
    % Calculate column pointers for POSTprocess
    col_ptr_post = zeros(cols+1, 1);
    for i = 1:length(c_post)
        col_ptr_post(c_post(i)+1) = col_ptr_post(c_post(i)+1) + 1;
    end
    for i = 2:cols+1
        col_ptr_post(i) = col_ptr_post(i) + col_ptr_post(i-1);
    end
    
    % Output column pointers
    for i = 1:cols+1
        fprintf(fid, '%d', col_ptr_post(i));
        if i < cols+1
            fprintf(fid, ', ');
            if mod(i, 8) == 0
                fprintf(fid, '\n  ');
            end
        end
    end
    fprintf(fid, '\n};\n\n');
    
    % Define entry types for SystemVerilog
    fprintf(fid, '// Define struct types for matrix entries\n');
    fprintf(fid, 'typedef struct packed {\n');
    fprintf(fid, '  logic [$clog2(`EVAL_ROWS)-1:0] row;\n');
    fprintf(fid, '  logic [$clog2(`EVAL_COLS)-1:0] col;\n');
    fprintf(fid, '  logic [31:0]                   value;\n');
    fprintf(fid, '} eval_entry_t;\n\n');
    
    fprintf(fid, 'typedef struct packed {\n');
    fprintf(fid, '  logic [$clog2(`POSTPROC_ROWS)-1:0] row;\n');
    fprintf(fid, '  logic [$clog2(`POSTPROC_COLS)-1:0] col;\n');
    fprintf(fid, '  logic [31:0]                       value;\n');
    fprintf(fid, '} postproc_entry_t;\n');
    
    fclose(fid);
    fprintf('Generated RTL-compatible matrix definitions to matrix_coefficients.vh\n');
end