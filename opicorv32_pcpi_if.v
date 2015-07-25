module opicorv32_pcpi_if (
    pcpi_wait,
    pcpi_rd,
    pcpi_rs2,
    pcpi_rs1,
    pcpi_wr,
    clk,
    pcpi_insn,
    pcpi_valid,
    resetn,
    pcpi_ready,
    pcpi_int_wr,
    pcpi_int_rd,
    pcpi_int_wait,
    pcpi_int_ready
);

    input pcpi_wait;
    input [31:0] pcpi_rd;
    input [31:0] pcpi_rs2;
    input [31:0] pcpi_rs1;
    input pcpi_wr;
    input clk;
    input [31:0] pcpi_insn;
    input pcpi_valid;
    input resetn;
    input pcpi_ready;
    output pcpi_int_wr;
    output [31:0] pcpi_int_rd;
    output pcpi_int_wait;
    output pcpi_int_ready;

    /* signal declarations */
    wire _2537;
    wire _2532;
    wire _2533;
    wire _2534;
    wire [31:0] _2530 = 32'b00000000000000000000000000000000;
    wire [31:0] _2529 = 32'b00000000000000000000000000000000;
    wire [31:0] _2527;
    wire [63:0] _2440 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _2438 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _2480 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _2443;
    wire [63:0] _2436 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _2434 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _2479 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire _2453 = 1'b0;
    wire [63:0] _2447;
    wire [63:0] _2428 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _2426 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire _2488;
    wire [1:0] _2489;
    wire [3:0] _2490;
    wire [7:0] _2491;
    wire [15:0] _2492;
    wire [31:0] _2493;
    wire [63:0] _2495;
    wire [31:0] _2485 = 32'b00000000000000000000000000000000;
    wire [63:0] _2487;
    wire [63:0] _2496;
    wire _2459 = 1'b0;
    wire [62:0] _2460;
    wire [63:0] _2461;
    wire [63:0] _2521;
    wire [63:0] _2427;
    reg [63:0] _2429;
    wire [63:0] _2448;
    wire [63:0] _2449;
    wire [63:0] _2450;
    wire [63:0] _2446;
    wire _2451;
    wire [63:0] _2452;
    wire [62:0] _2454;
    wire [63:0] _2455;
    wire [63:0] _2519;
    wire [63:0] _2435;
    reg [63:0] _2437;
    wire [63:0] _2442;
    wire [63:0] _2432 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _2430 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire _2504;
    wire [1:0] _2505;
    wire [3:0] _2506;
    wire [7:0] _2507;
    wire [15:0] _2508;
    wire [31:0] _2509;
    wire [63:0] _2511;
    wire [31:0] _2501 = 32'b00000000000000000000000000000000;
    wire [63:0] _2503;
    wire _2419;
    wire [63:0] _2512;
    wire [62:0] _2456;
    wire _2457 = 1'b0;
    wire [63:0] _2458;
    wire [63:0] _2520;
    wire [63:0] _2431;
    reg [63:0] _2433;
    wire _2444;
    wire [63:0] _2445;
    wire [63:0] _2518;
    wire [63:0] _2439;
    reg [63:0] _2441;
    wire [31:0] _2526;
    wire [31:0] _2528;
    reg [31:0] _2531;
    wire [31:0] _2540 = 32'b00000000000000000000000000000000;
    wire [31:0] _2541;
    wire [31:0] _2542;
    wire _2522 = 1'b0;
    reg _2523;
    wire _2524 = 1'b0;
    wire _2470 = 1'b0;
    wire _2513;
    wire _2467 = 1'b0;
    wire _2422 = 1'b0;
    reg _2423;
    wire _2424;
    wire _2420 = 1'b0;
    wire _2394 = 1'b0;
    wire [2:0] _2391 = 3'b000;
    wire [2:0] _2390;
    wire _2392;
    wire _2393;
    reg _2395;
    wire _2414;
    wire _2415;
    wire _2416;
    reg _2421;
    wire _2425;
    wire _2475;
    wire [6:0] _2464 = 7'b0000000;
    wire [6:0] _2462 = 7'b0000000;
    wire [6:0] _2477 = 7'b0111110;
    wire [6:0] _2476 = 7'b0011110;
    wire _2412 = 1'b0;
    wire [2:0] _2409 = 3'b011;
    wire [2:0] _2408;
    wire _2410;
    wire _2411;
    reg _2413;
    wire _2406 = 1'b0;
    wire [2:0] _2403 = 3'b010;
    wire [2:0] _2402;
    wire _2404;
    wire _2405;
    reg _2407;
    wire _2400 = 1'b0;
    wire [2:0] _2397 = 3'b001;
    wire [2:0] _2396;
    wire _2398;
    wire [6:0] _2382 = 7'b0000001;
    wire [6:0] _2381;
    wire _2383;
    wire [6:0] _2385 = 7'b0110011;
    wire [6:0] _2384;
    wire _2386;
    wire _2387;
    wire _2388;
    wire _2389;
    wire _2399;
    reg _2401;
    wire _2417;
    wire _2418;
    wire [6:0] _2478;
    wire [6:0] _2473 = 7'b0000001;
    wire [6:0] _2474;
    wire [6:0] _2517;
    wire [6:0] _2463;
    reg [6:0] _2465;
    wire _2472;
    wire _2515;
    wire _2516;
    wire _2466;
    reg _2468;
    wire _2514;
    wire _2469;
    reg _2471;
    reg _2525;
    wire vdd = 1'b1;
    wire _2535;
    wire _2538;
    wire gnd = 1'b0;
    wire _2536;
    wire _2539;

    /* logic */
    assign _2537 = _2536 | _2535;
    assign _2532 = vdd & _2421;
    assign _2533 = gnd & pcpi_wait;
    assign _2534 = _2533 | _2532;
    assign _2527 = _2441[63:32];
    assign _2443 = _2442 ^ _2429;
    assign _2447 = _2437 & _2429;
    assign _2488 = pcpi_rs2[31:31];
    assign _2489 = { _2488, _2488 };
    assign _2490 = { _2489, _2489 };
    assign _2491 = { _2490, _2490 };
    assign _2492 = { _2491, _2491 };
    assign _2493 = { _2492, _2492 };
    assign _2495 = { _2493, pcpi_rs2 };
    assign _2487 = { _2485, pcpi_rs2 };
    assign _2496 = _2401 ? _2495 : _2487;
    assign _2460 = _2429[62:0];
    assign _2461 = { _2460, _2459 };
    assign _2521 = _2468 ? _2496 : _2461;
    assign _2427 = _2521;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2429 <= _2426;
        else
            _2429 <= _2427;
    end
    assign _2448 = _2441 & _2429;
    assign _2449 = _2446 | _2448;
    assign _2450 = _2449 | _2447;
    assign _2446 = _2441 & _2437;
    assign _2451 = _2433[0:0];
    assign _2452 = _2451 ? _2450 : _2446;
    assign _2454 = _2452[62:0];
    assign _2455 = { _2454, _2453 };
    assign _2519 = _2468 ? _2479 : _2455;
    assign _2435 = _2519;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2437 <= _2434;
        else
            _2437 <= _2435;
    end
    assign _2442 = _2441 ^ _2437;
    assign _2504 = pcpi_rs1[31:31];
    assign _2505 = { _2504, _2504 };
    assign _2506 = { _2505, _2505 };
    assign _2507 = { _2506, _2506 };
    assign _2508 = { _2507, _2507 };
    assign _2509 = { _2508, _2508 };
    assign _2511 = { _2509, pcpi_rs1 };
    assign _2503 = { _2501, pcpi_rs1 };
    assign _2419 = _2401 | _2407;
    assign _2512 = _2419 ? _2511 : _2503;
    assign _2456 = _2433[63:1];
    assign _2458 = { _2457, _2456 };
    assign _2520 = _2468 ? _2512 : _2458;
    assign _2431 = _2520;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2433 <= _2430;
        else
            _2433 <= _2431;
    end
    assign _2444 = _2433[0:0];
    assign _2445 = _2444 ? _2443 : _2442;
    assign _2518 = _2468 ? _2480 : _2445;
    assign _2439 = _2518;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2441 <= _2438;
        else
            _2441 <= _2439;
    end
    assign _2526 = _2441[31:0];
    assign _2528 = _2418 ? _2527 : _2526;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2531 <= _2529;
        else
            if (_2471)
                _2531 <= _2528;
    end
    assign _2541 = _2535 ? _2531 : _2540;
    assign _2542 = _2536 ? pcpi_rd : _2541;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2523 <= gnd;
        else
            _2523 <= _2471;
    end
    assign _2513 = _2472 ? vdd : gnd;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2423 <= gnd;
        else
            _2423 <= _2421;
    end
    assign _2424 = ~ _2423;
    assign _2390 = pcpi_insn[14:12];
    assign _2392 = _2390 == _2391;
    assign _2393 = _2389 & _2392;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2395 <= gnd;
        else
            _2395 <= _2393;
    end
    assign _2414 = _2395 | _2401;
    assign _2415 = _2414 | _2407;
    assign _2416 = _2415 | _2413;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2421 <= gnd;
        else
            _2421 <= _2416;
    end
    assign _2425 = _2421 & _2424;
    assign _2475 = ~ _2425;
    assign _2408 = pcpi_insn[14:12];
    assign _2410 = _2408 == _2409;
    assign _2411 = _2389 & _2410;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2413 <= gnd;
        else
            _2413 <= _2411;
    end
    assign _2402 = pcpi_insn[14:12];
    assign _2404 = _2402 == _2403;
    assign _2405 = _2389 & _2404;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2407 <= gnd;
        else
            _2407 <= _2405;
    end
    assign _2396 = pcpi_insn[14:12];
    assign _2398 = _2396 == _2397;
    assign _2381 = pcpi_insn[31:25];
    assign _2383 = _2381 == _2382;
    assign _2384 = pcpi_insn[6:0];
    assign _2386 = _2384 == _2385;
    assign _2387 = resetn & pcpi_valid;
    assign _2388 = _2387 & _2386;
    assign _2389 = _2388 & _2383;
    assign _2399 = _2389 & _2398;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2401 <= gnd;
        else
            _2401 <= _2399;
    end
    assign _2417 = _2401 | _2407;
    assign _2418 = _2417 | _2413;
    assign _2478 = _2418 ? _2477 : _2476;
    assign _2474 = _2465 - _2473;
    assign _2517 = _2468 ? _2478 : _2474;
    assign _2463 = _2517;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2465 <= _2462;
        else
            _2465 <= _2463;
    end
    assign _2472 = _2465[6:6];
    assign _2515 = _2472 ? vdd : _2468;
    assign _2516 = _2468 ? _2475 : _2515;
    assign _2466 = _2516;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2468 <= vdd;
        else
            _2468 <= _2466;
    end
    assign _2514 = _2468 ? gnd : _2513;
    assign _2469 = _2514;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2471 <= gnd;
        else
            _2471 <= _2469;
    end
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _2525 <= gnd;
        else
            _2525 <= _2471;
    end
    assign _2535 = vdd & _2525;
    assign _2538 = _2535 ? _2523 : gnd;
    assign _2536 = gnd & pcpi_ready;
    assign _2539 = _2536 ? pcpi_wr : _2538;

    /* aliases */

    /* output assignments */
    assign pcpi_int_wr = _2539;
    assign pcpi_int_rd = _2542;
    assign pcpi_int_wait = _2534;
    assign pcpi_int_ready = _2537;

endmodule
