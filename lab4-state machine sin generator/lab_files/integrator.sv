//----------------------------------------------------------------------------------------------------
// Module name: integrator
// Author:      Refael Gantz
// Date:        23.11.2018
// email:       refael.gantz@gmail.com
// Description: This module implements a simple fixed gain digital integrator.
//----------------------------------------------------------------------------------------------------

module integrator (
		   input logic 	      clk,
		   input logic 	      resetb,
		   input logic [8:0]  in,
		   output logic [8:0] out
		   );

   logic [25:0] 	    integrator;
   logic [25:0] 	    integrator_next;
   
   assign integrator_next = { {17{in[8]}}, in};

   always_ff @ (posedge clk or negedge resetb)
     if (~resetb)
       integrator <= 26'b0;
     else
       integrator <= integrator + integrator_next;

   assign out = integrator[25:17];
      
endmodule 
