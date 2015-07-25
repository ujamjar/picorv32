module opicorv32_memif (
    mem_rdata,
    reg_op2,
    mem_wordsize,
    next_pc,
    reg_op1,
    resetn,
    clk,
    mem_do_prefetch,
    mem_do_wdata,
    mem_do_rdata,
    mem_do_rinst,
    mem_ready,
    mem_done,
    mem_valid,
    mem_instr,
    mem_addr,
    mem_wdata,
    mem_wstrb,
    mem_rdata_latched,
    mem_rdata_q,
    mem_rdata_word,
    mem_la_read,
    mem_la_write,
    mem_la_addr,
    mem_la_wdata,
    mem_la_wstrb
);

    input [31:0] mem_rdata;
    input [31:0] reg_op2;
    input [1:0] mem_wordsize;
    input [31:0] next_pc;
    input [31:0] reg_op1;
    input resetn;
    input clk;
    input mem_do_prefetch;
    input mem_do_wdata;
    input mem_do_rdata;
    input mem_do_rinst;
    input mem_ready;
    output mem_done;
    output mem_valid;
    output mem_instr;
    output [31:0] mem_addr;
    output [31:0] mem_wdata;
    output [3:0] mem_wstrb;
    output [31:0] mem_rdata_latched;
    output [31:0] mem_rdata_q;
    output [31:0] mem_rdata_word;
    output mem_la_read;
    output mem_la_write;
    output [31:0] mem_la_addr;
    output [31:0] mem_la_wdata;
    output [3:0] mem_la_wstrb;

    /* signal declarations */
    wire _1329;
    wire _1330;
    wire _1331;
    wire _1332;
    wire _1313;
    wire _1333;
    wire _1334;
    wire [7:0] _1392;
    wire [23:0] _1397 = 24'b000000000000000000000000;
    wire [31:0] _1399;
    wire [7:0] _1384;
    wire [23:0] _1389 = 24'b000000000000000000000000;
    wire [31:0] _1391;
    wire [7:0] _1376;
    wire [23:0] _1381 = 24'b000000000000000000000000;
    wire [31:0] _1383;
    wire [7:0] _1368;
    wire [23:0] _1373 = 24'b000000000000000000000000;
    wire [31:0] _1375;
    wire [1:0] _1400;
    reg [31:0] _1401;
    wire [15:0] _1402;
    wire [15:0] _1406 = 16'b0000000000000000;
    wire [31:0] _1408;
    wire [15:0] _1409;
    wire [15:0] _1413 = 16'b0000000000000000;
    wire [31:0] _1415;
    wire _1416;
    wire [31:0] _1417;
    reg [31:0] _1418;
    wire _1341;
    wire [31:0] _1343 = 32'b00000000000000000000000000000000;
    wire [31:0] _1342 = 32'b00000000000000000000000000000000;
    reg [31:0] _1344;
    wire _1345;
    wire _1346;
    wire [31:0] _1347;
    wire [31:0] _1340;
    wire [3:0] _1429 = 4'b0000;
    wire [3:0] _1427 = 4'b0000;
    wire [3:0] _1435 = 4'b0000;
    wire [3:0] _1359 = 4'b1000;
    wire [3:0] _1358 = 4'b0100;
    wire [3:0] _1357 = 4'b0010;
    wire [3:0] _1356 = 4'b0001;
    wire [1:0] _1360;
    reg [3:0] _1361;
    wire [3:0] _1363 = 4'b1100;
    wire [3:0] _1362 = 4'b0011;
    wire _1364;
    wire [3:0] _1365;
    wire [3:0] _1366 = 4'b1111;
    reg [3:0] _1367;
    wire [3:0] _1443;
    wire _1444;
    wire [3:0] _1445;
    wire [3:0] _1428;
    reg [3:0] _1430;
    wire [31:0] _1425 = 32'b00000000000000000000000000000000;
    wire [31:0] _1423 = 32'b00000000000000000000000000000000;
    wire [7:0] _1351;
    wire [15:0] _1352;
    wire [31:0] _1353;
    wire [15:0] _1348;
    wire [31:0] _1349;
    reg [31:0] _1355;
    wire _1446;
    wire [31:0] _1447;
    wire [31:0] _1424;
    reg [31:0] _1426;
    wire [31:0] _1421 = 32'b00000000000000000000000000000000;
    wire [31:0] _1419 = 32'b00000000000000000000000000000000;
    wire [1:0] _1335 = 2'b00;
    wire [29:0] _1336;
    wire [31:0] _1337;
    wire _1338;
    wire [31:0] _1339;
    wire _1448;
    wire [31:0] _1449;
    wire [31:0] _1420;
    reg [31:0] _1422;
    wire _1432 = 1'b0;
    wire _1436;
    wire _1439;
    wire _1440;
    wire _1441;
    wire _1442;
    wire _1431;
    reg _1433;
    wire _1318 = 1'b0;
    wire _1450;
    wire _1451;
    wire _1452;
    wire _1453;
    wire _1454;
    wire _1455;
    wire _1456;
    wire _1457;
    wire _1458;
    wire _1459;
    wire _1317;
    reg _1319;
    wire _1314;
    wire _1323;
    wire _1324;
    wire _1325;
    wire vdd = 1'b1;
    wire [1:0] _1311 = 2'b00;
    wire gnd = 1'b0;
    wire [1:0] _1305 = 2'b00;
    wire _1437;
    wire _1438;
    wire [1:0] _1460;
    wire [1:0] _1461;
    wire _1434;
    wire [1:0] _1462;
    wire [1:0] _1463;
    wire [1:0] _1464;
    wire [1:0] _1465;
    wire [1:0] _1306 = 2'b11;
    wire _1466;
    wire [1:0] _1467;
    wire [1:0] _1307 = 2'b10;
    wire _1468;
    wire [1:0] _1469;
    wire [1:0] _1308 = 2'b01;
    wire _1470;
    wire [1:0] _1471;
    wire _1472;
    wire [1:0] _1473;
    wire [1:0] _1310;
    reg [1:0] _1312;
    wire [1:0] _1309 = 2'b00;
    wire _1315;
    wire _1316;
    wire _1326;
    wire _1327;
    wire _1328;

    /* logic */
    assign _1329 = resetn & _1313;
    assign _1330 = _1329 & mem_do_wdata;
    assign _1331 = mem_do_rinst | mem_do_prefetch;
    assign _1332 = _1331 | mem_do_rdata;
    assign _1313 = _1309 == _1312;
    assign _1333 = resetn & _1313;
    assign _1334 = _1333 & _1332;
    assign _1392 = mem_rdata[31:24];
    assign _1399 = { _1397, _1392 };
    assign _1384 = mem_rdata[23:16];
    assign _1391 = { _1389, _1384 };
    assign _1376 = mem_rdata[15:8];
    assign _1383 = { _1381, _1376 };
    assign _1368 = mem_rdata[7:0];
    assign _1375 = { _1373, _1368 };
    assign _1400 = reg_op1[1:0];
    always @* begin
        case (_1400)
        0: _1401 <= _1375;
        1: _1401 <= _1383;
        2: _1401 <= _1391;
        default: _1401 <= _1399;
        endcase
    end
    assign _1402 = mem_rdata[31:16];
    assign _1408 = { _1406, _1402 };
    assign _1409 = mem_rdata[15:0];
    assign _1415 = { _1413, _1409 };
    assign _1416 = reg_op1[1:1];
    assign _1417 = _1416 ? _1408 : _1415;
    always @* begin
        case (mem_wordsize)
        0: _1418 <= mem_rdata;
        1: _1418 <= _1417;
        default: _1418 <= _1401;
        endcase
    end
    assign _1341 = _1319 & mem_ready;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1344 <= _1342;
        else
            if (_1341)
                _1344 <= _1340;
    end
    assign _1345 = _1319 & mem_ready;
    assign _1346 = _1345 | gnd;
    assign _1347 = _1346 ? mem_rdata : _1344;
    assign _1340 = _1347;
    assign _1360 = reg_op1[1:0];
    always @* begin
        case (_1360)
        0: _1361 <= _1356;
        1: _1361 <= _1357;
        2: _1361 <= _1358;
        default: _1361 <= _1359;
        endcase
    end
    assign _1364 = reg_op1[1:1];
    assign _1365 = _1364 ? _1363 : _1362;
    always @* begin
        case (mem_wordsize)
        0: _1367 <= _1366;
        1: _1367 <= _1365;
        default: _1367 <= _1361;
        endcase
    end
    assign _1443 = _1438 ? _1435 : _1367;
    assign _1444 = _1312 == _1309;
    assign _1445 = _1444 ? _1443 : _1430;
    assign _1428 = _1445;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1430 <= _1427;
        else
            _1430 <= _1428;
    end
    assign _1351 = reg_op2[7:0];
    assign _1352 = { _1351, _1351 };
    assign _1353 = { _1352, _1352 };
    assign _1348 = reg_op2[15:0];
    assign _1349 = { _1348, _1348 };
    always @* begin
        case (mem_wordsize)
        0: _1355 <= reg_op2;
        1: _1355 <= _1349;
        default: _1355 <= _1353;
        endcase
    end
    assign _1446 = _1312 == _1309;
    assign _1447 = _1446 ? _1355 : _1426;
    assign _1424 = _1447;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1426 <= _1423;
        else
            _1426 <= _1424;
    end
    assign _1336 = reg_op1[31:2];
    assign _1337 = { _1336, _1335 };
    assign _1338 = mem_do_prefetch | mem_do_rinst;
    assign _1339 = _1338 ? next_pc : _1337;
    assign _1448 = _1312 == _1309;
    assign _1449 = _1448 ? _1339 : _1422;
    assign _1420 = _1449;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1422 <= _1419;
        else
            _1422 <= _1420;
    end
    assign _1436 = mem_do_prefetch | mem_do_rinst;
    assign _1439 = _1438 ? _1436 : _1433;
    assign _1440 = mem_do_wdata ? gnd : _1439;
    assign _1441 = _1312 == _1309;
    assign _1442 = _1441 ? _1440 : _1433;
    assign _1431 = _1442;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1433 <= gnd;
        else
            _1433 <= _1431;
    end
    assign _1450 = _1438 ? vdd : _1319;
    assign _1451 = mem_do_wdata ? vdd : _1450;
    assign _1452 = mem_ready ? gnd : _1319;
    assign _1453 = mem_ready ? gnd : _1319;
    assign _1454 = _1312 == _1307;
    assign _1455 = _1454 ? _1453 : _1319;
    assign _1456 = _1312 == _1308;
    assign _1457 = _1456 ? _1452 : _1455;
    assign _1458 = _1312 == _1309;
    assign _1459 = _1458 ? _1451 : _1457;
    assign _1317 = _1459;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1319 <= gnd;
        else
            _1319 <= _1317;
    end
    assign _1314 = _1306 == _1312;
    assign _1323 = _1314 & mem_do_rinst;
    assign _1324 = mem_do_rinst | mem_do_rdata;
    assign _1325 = _1324 | mem_do_wdata;
    assign _1437 = mem_do_prefetch | mem_do_rinst;
    assign _1438 = _1437 | mem_do_rdata;
    assign _1460 = _1438 ? _1308 : _1312;
    assign _1461 = mem_do_wdata ? _1307 : _1460;
    assign _1434 = mem_do_rinst | mem_do_rdata;
    assign _1462 = _1434 ? _1309 : _1306;
    assign _1463 = mem_ready ? _1462 : _1312;
    assign _1464 = mem_ready ? _1309 : _1312;
    assign _1465 = mem_do_rinst ? _1309 : _1312;
    assign _1466 = _1312 == _1306;
    assign _1467 = _1466 ? _1465 : _1312;
    assign _1468 = _1312 == _1307;
    assign _1469 = _1468 ? _1464 : _1467;
    assign _1470 = _1312 == _1308;
    assign _1471 = _1470 ? _1463 : _1469;
    assign _1472 = _1312 == _1309;
    assign _1473 = _1472 ? _1461 : _1471;
    assign _1310 = _1473;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1312 <= _1305;
        else
            _1312 <= _1310;
    end
    assign _1315 = _1309 == _1312;
    assign _1316 = ~ _1315;
    assign _1326 = mem_ready & _1316;
    assign _1327 = _1326 & _1325;
    assign _1328 = _1327 | _1323;

    /* aliases */

    /* output assignments */
    assign mem_done = _1328;
    assign mem_valid = _1319;
    assign mem_instr = _1433;
    assign mem_addr = _1422;
    assign mem_wdata = _1426;
    assign mem_wstrb = _1430;
    assign mem_rdata_latched = _1340;
    assign mem_rdata_q = _1344;
    assign mem_rdata_word = _1418;
    assign mem_la_read = _1334;
    assign mem_la_write = _1330;
    assign mem_la_addr = _1339;
    assign mem_la_wdata = _1355;
    assign mem_la_wstrb = _1367;

endmodule
