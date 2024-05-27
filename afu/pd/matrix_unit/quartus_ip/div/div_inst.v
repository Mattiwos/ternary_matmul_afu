	div u0 (
		.numer    (_connected_to_numer_),    //   input,  width = 8,  lpm_divide_input.numer
		.denom    (_connected_to_denom_),    //   input,  width = 8,                  .denom
		.quotient (_connected_to_quotient_), //  output,  width = 8, lpm_divide_output.quotient
		.remain   (_connected_to_remain_)    //  output,  width = 8,                  .remain
	);

