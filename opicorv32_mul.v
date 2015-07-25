module opicorv32_mul (
    pcpi_rs2,
    pcpi_rs1,
    clk,
    pcpi_insn,
    pcpi_valid,
    resetn,
    pcpi_wr,
    pcpi_rd,
    pcpi_wait,
    pcpi_ready
);

    input [31:0] pcpi_rs2;
    input [31:0] pcpi_rs1;
    input clk;
    input [31:0] pcpi_insn;
    input pcpi_valid;
    input resetn;
    output pcpi_wr;
    output [31:0] pcpi_rd;
    output pcpi_wait;
    output pcpi_ready;

    /* signal declarations */
    wire _1723 = 1'b0;
    reg _1724;
    wire [31:0] _1729 = 32'b00000000000000000000000000000000;
    wire [31:0] _1728 = 32'b00000000000000000000000000000000;
    wire [31:0] _1726;
    wire [63:0] _1639 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _1637 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _1679 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _1642;
    wire [63:0] _1635 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _1633 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _1678 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire _1652 = 1'b0;
    wire [63:0] _1646;
    wire [63:0] _1627 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _1625 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire _1687;
    wire [1:0] _1688;
    wire [3:0] _1689;
    wire [7:0] _1690;
    wire [15:0] _1691;
    wire [31:0] _1692;
    wire [63:0] _1694;
    wire [31:0] _1684 = 32'b00000000000000000000000000000000;
    wire [63:0] _1686;
    wire [63:0] _1695;
    wire _1658 = 1'b0;
    wire [62:0] _1659;
    wire [63:0] _1660;
    wire [63:0] _1720;
    wire [63:0] _1626;
    reg [63:0] _1628;
    wire [63:0] _1647;
    wire [63:0] _1648;
    wire [63:0] _1649;
    wire [63:0] _1645;
    wire _1650;
    wire [63:0] _1651;
    wire [62:0] _1653;
    wire [63:0] _1654;
    wire [63:0] _1718;
    wire [63:0] _1634;
    reg [63:0] _1636;
    wire [63:0] _1641;
    wire [63:0] _1631 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire [63:0] _1629 = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    wire _1703;
    wire [1:0] _1704;
    wire [3:0] _1705;
    wire [7:0] _1706;
    wire [15:0] _1707;
    wire [31:0] _1708;
    wire [63:0] _1710;
    wire [31:0] _1700 = 32'b00000000000000000000000000000000;
    wire [63:0] _1702;
    wire _1618;
    wire [63:0] _1711;
    wire [62:0] _1655;
    wire _1656 = 1'b0;
    wire [63:0] _1657;
    wire [63:0] _1719;
    wire [63:0] _1630;
    reg [63:0] _1632;
    wire _1643;
    wire [63:0] _1644;
    wire [63:0] _1717;
    wire [63:0] _1638;
    reg [63:0] _1640;
    wire [31:0] _1725;
    wire [31:0] _1727;
    reg [31:0] _1730;
    wire _1721 = 1'b0;
    wire _1669 = 1'b0;
    wire _1712;
    wire _1666 = 1'b0;
    wire _1621 = 1'b0;
    reg _1622;
    wire _1623;
    wire _1619 = 1'b0;
    wire _1593 = 1'b0;
    wire [2:0] _1590 = 3'b000;
    wire [2:0] _1589;
    wire _1591;
    wire _1592;
    reg _1594;
    wire _1613;
    wire _1614;
    wire _1615;
    reg _1620;
    wire _1624;
    wire _1674;
    wire [6:0] _1663 = 7'b0000000;
    wire [6:0] _1661 = 7'b0000000;
    wire [6:0] _1676 = 7'b0111110;
    wire [6:0] _1675 = 7'b0011110;
    wire _1611 = 1'b0;
    wire [2:0] _1608 = 3'b011;
    wire [2:0] _1607;
    wire _1609;
    wire _1610;
    reg _1612;
    wire _1605 = 1'b0;
    wire [2:0] _1602 = 3'b010;
    wire [2:0] _1601;
    wire _1603;
    wire _1604;
    reg _1606;
    wire vdd = 1'b1;
    wire _1599 = 1'b0;
    wire gnd = 1'b0;
    wire [2:0] _1596 = 3'b001;
    wire [2:0] _1595;
    wire _1597;
    wire [6:0] _1581 = 7'b0000001;
    wire [6:0] _1580;
    wire _1582;
    wire [6:0] _1584 = 7'b0110011;
    wire [6:0] _1583;
    wire _1585;
    wire _1586;
    wire _1587;
    wire _1588;
    wire _1598;
    reg _1600;
    wire _1616;
    wire _1617;
    wire [6:0] _1677;
    wire [6:0] _1672 = 7'b0000001;
    wire [6:0] _1673;
    wire [6:0] _1716;
    wire [6:0] _1662;
    reg [6:0] _1664;
    wire _1671;
    wire _1714;
    wire _1715;
    wire _1665;
    reg _1667;
    wire _1713;
    wire _1668;
    reg _1670;
    reg _1722;

    /* logic */
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1724 <= gnd;
        else
            _1724 <= _1670;
    end
    assign _1726 = _1640[63:32];
    assign _1642 = _1641 ^ _1628;
    assign _1646 = _1636 & _1628;
    assign _1687 = pcpi_rs2[31:31];
    assign _1688 = { _1687, _1687 };
    assign _1689 = { _1688, _1688 };
    assign _1690 = { _1689, _1689 };
    assign _1691 = { _1690, _1690 };
    assign _1692 = { _1691, _1691 };
    assign _1694 = { _1692, pcpi_rs2 };
    assign _1686 = { _1684, pcpi_rs2 };
    assign _1695 = _1600 ? _1694 : _1686;
    assign _1659 = _1628[62:0];
    assign _1660 = { _1659, _1658 };
    assign _1720 = _1667 ? _1695 : _1660;
    assign _1626 = _1720;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1628 <= _1625;
        else
            _1628 <= _1626;
    end
    assign _1647 = _1640 & _1628;
    assign _1648 = _1645 | _1647;
    assign _1649 = _1648 | _1646;
    assign _1645 = _1640 & _1636;
    assign _1650 = _1632[0:0];
    assign _1651 = _1650 ? _1649 : _1645;
    assign _1653 = _1651[62:0];
    assign _1654 = { _1653, _1652 };
    assign _1718 = _1667 ? _1678 : _1654;
    assign _1634 = _1718;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1636 <= _1633;
        else
            _1636 <= _1634;
    end
    assign _1641 = _1640 ^ _1636;
    assign _1703 = pcpi_rs1[31:31];
    assign _1704 = { _1703, _1703 };
    assign _1705 = { _1704, _1704 };
    assign _1706 = { _1705, _1705 };
    assign _1707 = { _1706, _1706 };
    assign _1708 = { _1707, _1707 };
    assign _1710 = { _1708, pcpi_rs1 };
    assign _1702 = { _1700, pcpi_rs1 };
    assign _1618 = _1600 | _1606;
    assign _1711 = _1618 ? _1710 : _1702;
    assign _1655 = _1632[63:1];
    assign _1657 = { _1656, _1655 };
    assign _1719 = _1667 ? _1711 : _1657;
    assign _1630 = _1719;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1632 <= _1629;
        else
            _1632 <= _1630;
    end
    assign _1643 = _1632[0:0];
    assign _1644 = _1643 ? _1642 : _1641;
    assign _1717 = _1667 ? _1679 : _1644;
    assign _1638 = _1717;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1640 <= _1637;
        else
            _1640 <= _1638;
    end
    assign _1725 = _1640[31:0];
    assign _1727 = _1617 ? _1726 : _1725;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1730 <= _1728;
        else
            if (_1670)
                _1730 <= _1727;
    end
    assign _1712 = _1671 ? vdd : gnd;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1622 <= gnd;
        else
            _1622 <= _1620;
    end
    assign _1623 = ~ _1622;
    assign _1589 = pcpi_insn[14:12];
    assign _1591 = _1589 == _1590;
    assign _1592 = _1588 & _1591;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1594 <= gnd;
        else
            _1594 <= _1592;
    end
    assign _1613 = _1594 | _1600;
    assign _1614 = _1613 | _1606;
    assign _1615 = _1614 | _1612;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1620 <= gnd;
        else
            _1620 <= _1615;
    end
    assign _1624 = _1620 & _1623;
    assign _1674 = ~ _1624;
    assign _1607 = pcpi_insn[14:12];
    assign _1609 = _1607 == _1608;
    assign _1610 = _1588 & _1609;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1612 <= gnd;
        else
            _1612 <= _1610;
    end
    assign _1601 = pcpi_insn[14:12];
    assign _1603 = _1601 == _1602;
    assign _1604 = _1588 & _1603;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1606 <= gnd;
        else
            _1606 <= _1604;
    end
    assign _1595 = pcpi_insn[14:12];
    assign _1597 = _1595 == _1596;
    assign _1580 = pcpi_insn[31:25];
    assign _1582 = _1580 == _1581;
    assign _1583 = pcpi_insn[6:0];
    assign _1585 = _1583 == _1584;
    assign _1586 = resetn & pcpi_valid;
    assign _1587 = _1586 & _1585;
    assign _1588 = _1587 & _1582;
    assign _1598 = _1588 & _1597;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1600 <= gnd;
        else
            _1600 <= _1598;
    end
    assign _1616 = _1600 | _1606;
    assign _1617 = _1616 | _1612;
    assign _1677 = _1617 ? _1676 : _1675;
    assign _1673 = _1664 - _1672;
    assign _1716 = _1667 ? _1677 : _1673;
    assign _1662 = _1716;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1664 <= _1661;
        else
            _1664 <= _1662;
    end
    assign _1671 = _1664[6:6];
    assign _1714 = _1671 ? vdd : _1667;
    assign _1715 = _1667 ? _1674 : _1714;
    assign _1665 = _1715;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1667 <= vdd;
        else
            _1667 <= _1665;
    end
    assign _1713 = _1667 ? gnd : _1712;
    assign _1668 = _1713;
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1670 <= gnd;
        else
            _1670 <= _1668;
    end
    always @(posedge clk or negedge resetn) begin
        if (resetn == 0)
            _1722 <= gnd;
        else
            _1722 <= _1670;
    end

    /* aliases */

    /* output assignments */
    assign pcpi_wr = _1722;
    assign pcpi_rd = _1730;
    assign pcpi_wait = _1620;
    assign pcpi_ready = _1724;

endmodule
