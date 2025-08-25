# FPGA-DESIGN: AXI4-Lite to APB Bridge

This repository contains the RTL design and testbenches for an **AXI4-Lite to APB Bridge** implementation in Verilog/SystemVerilog.

---

## 📂 Directory Structure
├── readme.md
├── Sim
│ └── Bridge.png
├── src
│ ├── Axi4_lite
│ │ ├── AXIL4_master.v
│ │ ├── AXIL4_slave.v
│ │ └── AXIL4_top.v
│ └── Axi4_lite_APB_Bridge
│ └── axi4lite_to_apb.v
└── tb
├── TB_AXI4_lite.sv
└── tb_bridge.sv


## 🚀 Overview

- **AXI4-Lite modules**: Implement basic AXI4-Lite master and slave logic for bus communication.
- **AXI4-Lite to APB Bridge**: Converts AXI4-Lite transactions into APB protocol transactions for peripheral access.
- **Testbenches**: Validate functionality of AXI4-Lite modules and the AXI4-Lite to APB bridge using SystemVerilog.

---

## 🛠️ How to Use

1. Clone the repository:
   ```bash
   git clone https://github.com/divyanshu101/FPGA-DESIGN.git
   cd FPGA-DESIGN
