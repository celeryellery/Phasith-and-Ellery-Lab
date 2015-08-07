//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module ProjectPart1A( // top-level module

 //////////// CLOCK //////////
 input               CLOCK_50,
 input               CLOCK2_50,
 input               CLOCK3_50,
 input               CLOCK4_50,

 //////////// SEG7 //////////
 output       [6:0]  HEX0,
 output       [6:0]  HEX1,
 output       [6:0]  HEX2,
 output       [6:0]  HEX3,
 output       [6:0]  HEX4,
 output       [6:0]  HEX5,

 //////////// KEY //////////
 input        [3:0]  KEY,

 //////////// LED //////////
 output       [9:0]  LEDR,

 //////////// SW //////////
 input        [9:0]  SW,

 //////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
 inout       [35:0]  GPIO
);



//=======================================================
//  REG/WIRE declarations
//=======================================================
wire [31:0] clockCount;
wire [3:0] rawkey;
wire rawValid;
wire[3:0] debouncedKey;
wire debouncedValid;
wire blankZero;


//=======================================================
//  Structural coding
//=======================================================
Scan mykeypadScan (CLOCK_50, GPIO[25:11], rawkey, rawValid);
Debounce(CLOCK_50, rawkey, rawValid, debouncedKey, debouncedValid); 
SevenSegment( debouncedKey, HEX0, blankZero );
endmodule

// Scan the keypad
module Scan(input CLOCK_50, 
            inout[7:0] keypad, 
            output reg[3:0] rawkey, 
				output reg rawValid);
	
	wire[3:0] rows;
	wire[3:0] cols; 
	reg[31:0] counter;
	reg[1:0] colsNum;
	reg[3:0] decodedcols;
	
   parameter clockDivisor = 500;
	wire Allrows = rows[0]& rows[1]& rows[2]& rows[3];

	assign cols = keypad[3:0];
	assign rows = keypad[7:4];

	always @(posedge CLOCK_50)
		begin 
			if (counter==0)
		begin
			counter <= clockDivisor;
			if (Allrows==1)
			colsNum<=colsNum+1;
		end
    else 
		counter <= counter -1;
    end

	 always@( colsNum)
		case (colsNum)
		0: decodedcols = 4'b0111;
		1: decodedcols = 4'b1011;
		2: decodedcols = 4'b1101;
		3: decodedcols = 4'b1110;
		endcase

	always@(*)
		if (Allrows )	// If no raw is pressed
		begin
			rawkey =0;
				rawValid = 0;			
				end
		else			// If a row is pressed
			begin
				casex (rows)
				4'b0xxx:		// Key pressed in row o
					begin	
						case(cols)
						4'b0111:					// Pressing key #1
						begin
							rawValid <=1;
							rawkey <= 4'b0001;
						end
						4'b1011 :				// Pressing key #2
						begin
							rawValid <=1;
							rawkey <= 4'b0010;
						end
						4'b1101:					// Pressing key #3
						begin
							rawValid <=1;
							rawkey <= 4'b0011;
						end
						4'b1110 :				// Pressing key #A
						begin
							rawValid <=1;
							rawkey <= 4'b1010;
						end
					endcase
				end
					
					4'b10xx:		// Key pressed in row 1
					begin	
						case(cols)
						4'b0111:					// Pressing key #4
						begin
							rawValid <=1;
							rawkey <= 4'b0100;
						end
						4'b1011 :				// Pressing key #5
						begin
							rawValid <=1;
							rawkey <= 4'b0101;
						end
						4'b1101:					// Pressing key #6
						begin
							rawValid <=1;
							rawkey <= 4'b0110;
						end
						4'b1110 :				// Pressing key #B
						begin
							rawValid <=1;
							rawkey <= 4'b1011;
						end
					endcase
				end
					4'b110x:						// Key pressed in row 2
					begin	
						case(cols)
						4'b0111:					// Pressing key #7
						begin
							rawValid <=1;
							rawkey <= 4'b0111;
						end
						4'b1011 :				// Pressing key #8
						begin
							rawValid <=1;
							rawkey <= 4'b1000;
						end
						4'b1101:					// Pressing key #9
						begin
							rawValid <=1;
							rawkey <= 4'b1001;
						end
						4'b1110 :				// Pressing key #C
						begin
							rawValid <=1;
							rawkey <= 4'b1100;
						end
					endcase
					end
					4'b1110:						// Key pressed in row 3
					begin	
						case(cols)
						4'b0111:					// Pressing key #*( E)
						begin
							rawValid <=1;
							rawkey <= 4'b1110;
						end
						4'b1011 :				// Pressing key #0
						begin
							rawValid <=1;
							rawkey <= 4'b0000;
						end
						4'b1101:					// Pressing key ##(F)
						begin
							rawValid <=1;
							rawkey <= 4'b1111;
						end
						4'b1110 :				// Pressing key #D
						begin
							rawValid <=1;
							rawkey <= 4'b1101;
						end
					endcase
					end
					default: rawValid = 0;	// If more than one key pressed or else
			endcase
			end
endmodule

// Debounce each key
module Debounce(input CLOCK_50,input[3:0] rawkey, input rawValid, output reg[3:0] debouncedKey, output reg debouncedValid);
reg[31:0] counter;
reg[3:0] LastrawValid;
parameter MaxCounter = 10000;
always @(posedge CLOCK_50)
	begin
	if(rawValid)		
		begin 
		LastrawValid <= rawValid;
			if (rawkey==LastrawValid)	// Input is the same as last input
				begin
					if (counter ==0)		// Input has been valid 10000 times
						begin
						debouncedValid <= 1;
						debouncedKey <= rawkey;	// Print input to display
						end
					else
						counter <= counter - 1; 	// Input has not been valid for 10000 times yet
				end
				
				
			else 											// Input is not the same as last
				begin
				counter <= MaxCounter;			
				debouncedValid <= 0;
				end
		end
	else
		begin
			if(counter==MaxCounter)		// No key is pressed
				debouncedValid<=0;
			else
			counter <= counter +1;		// rawinput is invalid
		end
			
	end
endmodule

// 7 segments
module SevenSegment( input [3:0] hexDigit,
		output [6:0] segments, input blankZero );
		
	// The actual segments driving lines are active low on the
	// DE1-SoC.
			
	// blankZero = 1 means if the hexDigit = 0, blank out that
	// digit.  Useful for blanking leading zeros.
		
	wire b0, b1, b2, b3;
	wire [6:0] s;
	
	// Break the hex digit into individual bits to make it easier
	// to write the combinatorial equations.
	
	assign b0 = hexDigit[0];
	assign b1 = hexDigit[1];
	assign b2 = hexDigit[2];
	assign b3 = hexDigit[3];
	
	// Equations for each of the segments, counting clockwise around
	// the outside starting from the top, then the middle.
	
	assign s[0] = b1 & b2 | ~b1 & ~b2 & b3 | ~b0 & b3 |
						~b0 & ~b2 | b0 & b2 & ~b3 | b1 & ~b3;
	assign s[1] = ~b2 & ~b3 | ~b0 & ~b1 & ~b3 | b0 & b1 & ~b3 |
						~b0 & ~b2 | b0 & ~b1 & b3;
	assign s[2] = b2 & ~b3 | ~b2 & b3 | b0 & ~b1 | ~b1 & ~b3 | b0 & ~b3;
	assign s[3] = ~b0 & b1 & b2 | b0 & b1 & ~b2 | ~b1 & b3 |
						b0 & ~b1 & b2 | ~b0 & ~b2 & ~b3;
	assign s[4] = ~b0 & b1 | b2 & b3 | b1 & b3 | ~b0 & ~b2;
	assign s[5] = ~b0 & b2 | ~b2 & b3 | b1 & b3 | ~b0 & ~b1 | ~b1 & b2 & ~b3;
	assign s[6] = ~b0 & b1 | ~b2 & b3 | b0 & b3 | ~b1 & b2 & ~b3 | b1 & ~b2;
	
	// Blank leading zeros and invert the output for active low
	// on the DE1-SoC board.
	
	assign segments = ( blankZero && hexDigit == 4'b0 ) ? ~7'b0 : ~s;
			
endmodule

