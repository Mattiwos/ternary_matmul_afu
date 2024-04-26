
package dv_pkg;

import config_pkg::*;

function automatic void fdisplay_vector(integer fd, vector_t v, bit T = 0);
    for (integer i = 0; i < D; i++) begin
        $fwrite(fd, fixed_point2real(v[i]));
        if (T) $fwrite(fd, "\t");
        else $fwrite(fd, "\n");
    end
    if (T) $fwrite(fd, "\n");
endfunction

function automatic void fdisplay_ternary_matrix(integer fd, ternary_matrix_t m, bit T = 0);
    integer i, j;
    if (T) begin
        for (i = 0; i < D; i++) begin
            for (j = 0; j < D; j++) begin
                $fwrite(fd, ternary2real(m[i][j]), "\t");
            end
            $fwrite(fd, "\n");
        end
    end else begin
        for (i = 0; i < D; i++) begin
            for (j = 0; j < D; j++) begin
                $fwrite(fd, ternary2real(m[j][i]), "\t");
            end
            $fwrite(fd, "\n");
        end
    end
endfunction

function automatic real ternary2real(ternary_t x);
    return $itor(x);
endfunction

function automatic real fixed_point2real(fixed_point_t x);
    real out = $itor(x);
    out *= (2.0 ** FixedPointExponent);
    return out;
endfunction

function automatic vector_t random_vector;
    vector_t out;
    for (integer i = 0; i < D; i++) begin
        out[i] = fixed_point_t'($urandom_range(0, fixed_point_t'(-1)));
    end
    return out;
endfunction

function automatic ternary_matrix_t random_ternary_matrix;
    ternary_matrix_t out;
    for (integer i = 0; i < D; i++) begin
        for (integer j = 0; j < D; j++) begin
            out[i][j] = -2;
            while (out[i][j] == -2)
                out[i][j] = 2'($urandom_range(0, 3));
        end
    end
    return out;
endfunction

function automatic ddr_data_t random_ddr_data;
    ddr_data_t out = $urandom();
    for (integer i = 0; i < DdrAddressWidth/32; i++) begin
        out <<= 32;
        out |= $urandom();
    end
    return out;
endfunction

endpackage
