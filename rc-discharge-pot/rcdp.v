module top(
           input         clki,
           input         in,
           output        out,
           output disp0,
           output disp1,
           output disp2,
           output disp3,
           output green);

   // states
   parameter      CHARGING = 0;
   parameter      MEASURING = 1;
   parameter      FINISHED = 2;
   parameter      DISPLAY = 3;

   parameter      CHARGING_TICKS = 12000;

   reg [32:0]            counter;
   reg [32:0]            accumulator;

   reg [1:0]             state;

   reg [7:0]             resetn_counter = 0;
   wire                  resetn;
   reg                   out_hi;

   assign resetn = &resetn_counter;
   assign green = in;
   assign out = out_hi ? 1'b1 : 1'bz;
   assign {disp0, disp1, disp2, disp3} = counter[19:16];

   always @ (posedge clki)
     begin
        if (!resetn)
          begin
             resetn_counter <= resetn_counter + 1;
          end
     end

   // state machine
   always @ (posedge clki)
     if (!resetn)
       begin
          state <= CHARGING;
       end
     else
       begin
          case (state)
            CHARGING:
              begin
                 state <= (accumulator > CHARGING_TICKS) ? MEASURING : CHARGING;
              end
            MEASURING:
              begin
                 state <= (in) ? MEASURING : FINISHED;
              end
            FINISHED:
              begin
                 state <= DISPLAY;
              end
            DISPLAY:
              begin
                 state <= CHARGING;
              end
          endcase // case (state)
       end

   // accumulator
   always @ (posedge clki)
     if (!resetn)
       begin
          accumulator = 32'd0;
       end
     else
       begin
          case (state)
            CHARGING:
              begin
                 accumulator <= (accumulator > CHARGING_TICKS) ? 0 : accumulator + 1;
              end
            MEASURING:
              begin
                 accumulator <= accumulator + 1;
              end
            DISPLAY:
              begin
                 accumulator <= 32'd0;
              end
          endcase // case (state)
     end

   // counter
   always @ (posedge clki)
     if (!resetn)
       begin
          counter <= 32'd0;
       end
     else
       begin
          case (state)
            FINISHED:
              begin
                 counter <= accumulator;                 
              end
          endcase // case (state)
     end

   // out_hi
   always @ (posedge clki)
     if (!resetn)
       begin
          out_hi <= 1;
       end
     else
       begin
          case (state)
            CHARGING:
              begin
                 out_hi <= 1;
              end
            MEASURING:
              begin
                 out_hi <= 0;
              end
            FINISHED:
              begin
                 out_hi <= 0;
              end
            DISPLAY:
              begin
                 out_hi <= 0;
              end
          endcase // case (state)
       end
   
endmodule
