# Convolution Under Modulo P – Hardware Simulation

This project contains both software and hardware simulations for **Convolution under Modulo P**, utilizing the **Number Theoretic Transform (NTT)**.

## 📁 Directory Structure

- **`SW/`**:  
  Contains software implementations of convolution and the Number Theoretic Transform (NTT).

- **`verification/`**:  
  Contains SystemVerilog testbench components used for hardware simulation, including:
  - Interfaces for DUT-to-testbench communication
  - Environment, driver, generator, transaction classes
  - Scoreboards for both NTT and Convolution

## 🧪 Testbench Overview

The top-level testbench is defined in **`mytb.sv`**. It verifies the hardware implementation of convolution using a modular approach based on object-oriented programming.

### Components:

- **Environment**:  
  Responsible for initializing the driver, generator, and scoreboards.

- **Generator**:  
  Produces randomized convolution transactions for diverse test cases using the DPI-C function `gencase`.

- **Driver**:  
  - Controls `enable` and `reset` signals to the DUT.  
  - Waits for the `done` signal from the DUT.  
  - Collects the output results and sends them to the scoreboard via mailbox.

- **Transaction**:  
  Encapsulates convolution data and control parameters. Randomized by the generator for each test.

- **Scoreboards**:
  - **NTT Scoreboard**:  
    Uses DPI-C function `SW_NTT_check` to verify the intermediate NTT outputs.
  - **CONV Scoreboard**:  
    Uses DPI-C function `SW_CONV_check` to validate the final convolution result.

### Test Flow:

1. Each convolution operation requires **two forward NTTs** followed by **one inverse NTT (INTT)** for the point-wise multiplication result.
2. The DUT's `done` signal should assert **three times** for each convolution test case.
3. The driver records intermediate outputs and sends them to the **NTT scoreboard** for validation.
4. Once all NTT operations are complete, the driver sends the final result to the **Convolution scoreboard** for comparison against the expected output.

## ▶️ Running the Simulation

To execute the hardware simulation:

```tcl
do run.tcl
```

This will compile and run the simulation in **ModelSim**.

## ⚠️ Notes

- This project is primarily intended as a **practice for testbench development**.
- The DUT implementations of NTT and CONV are **not optimized**. They use `%` and `*` operators, which may lead to **long critical paths** and are not suitable for high-performance synthesis.
