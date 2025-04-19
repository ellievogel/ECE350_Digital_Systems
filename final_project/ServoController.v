module ServoController(
    input        clk, 		    // System Clock Input 100 Mhz
    input[9:0]   switches,	    // Position control switches
    output       servoSignal    // Signal to the servo
    );	
        
    wire[9:0] duty_cycle;
    assign duty_cycle = switches;
    PWMSerializer #(.PERIOD_WIDTH_NS(25'd20000000))
    serial(.clk(clk), .reset(1'b0), .duty_cycle(duty_cycle), .signal(servoSignal));
    
    
    ////////////////////
	// Your Code Here //
	////////////////////
    
endmodule
