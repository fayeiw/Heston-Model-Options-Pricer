# Heston Model Options Pricer

The Heston Model Options Pricer is a hardware implementation of the **stochastic volatility Heston model** in **Verilog**, designed for option pricing via Monte Carlo simulation.  
The project integrates random path generation, stochastic differential equation (SDE) solving, payoff accumulation, and discounting into a synthesizable RTL system.

## Features
- Monte Carlo engine for option pricing based on the Heston stochastic volatility model
- Correlated random noise generation for variance and asset price dynamics
- Fixed-point math modules (Q8.24) for sin, cos, exp, ln, sqrt, and division
- Modular datapath: path generator, SDE solver, payoff calculation, discounting, and accumulation
- Directed testbenches for all major components

## Project Structure
| File | Description |
|------|-------------|
| `heston_engine.v` | Top-level integration of the options pricer. |
| `sim_engine_ctrl.v` | Controls simulation sequencing and Monte Carlo iterations. |
| `path_generator.v` | Generates stochastic paths for asset price and variance. |
| `sde_solver.v` | Solves Heston SDEs for each simulation step. |
| `correlation_noise.v` | Produces correlated Gaussian noise for asset and variance processes. |
| `rng_lfsr_32.v` | 32-bit linear feedback shift register RNG. |
| `payoff_calculator.v` | Computes option payoff at maturity. |
| `discount_engine.v` | Discounts payoff to present value. |
| `accumulator.v` | Accumulates results across Monte Carlo paths. |
| `exp_taylor_q824.v` | Exponential approximation (Taylor, Q8.24). |
| `cos_taylor_q824.v` | Cosine approximation (Taylor, Q8.24). |
| `sin_taylor_q824.v` | Sine approximation (Taylor, Q8.24). |
| `ln_taylor_q824.v` | Logarithm approximation (Taylor, Q8.24). |
| `div_q824.v` | Fixed-point divider (Q8.24). |
| `sqrt_q824.v` | Square root approximation (Q8.24). |
| `sin_lut.v` | LUT-based sine function. |
| `ln_lut.v` | LUT-based logarithm function. |
| `sqrt_lut.v` | LUT-based square root function. |

## Architecture Overview
The engine follows the **Monte Carlo pricing cycle**:
1. **Random Generation**: RNG and correlation logic generate Gaussian noise.  
2. **Path Generation**: Noise drives asset price and variance updates.  
3. **SDE Solver**: Solves coupled stochastic equations for asset and volatility.  
4. **Payoff Calculation**: Computes option payoff at maturity.  
5. **Discounting & Accumulation**: Discounted payoff is aggregated across paths.  

**Pipeline Stages**:
| Stage | Module | Function |
|-------|---------|----------|
| 1 | `rng_lfsr_32.v`, `correlation_noise.v` | Generate correlated noise. |
| 2 | `path_generator.v` | Generate stochastic asset/variance path. |
| 3 | `sde_solver.v` | Solve Heston SDE step. |
| 4 | `payoff_calculator.v` | Compute option payoff. |
| 5 | `discount_engine.v`, `accumulator.v` | Discount and accumulate results. |

## Verification
Verification is performed using **directed testbenches** with manual checking:  
| Testbench | Target Module |
|-----------|---------------|
| `accumulator_tb.v` | `accumulator.v` |
| `correlation_noise_tb.v` | `correlation_noise.v` |
| `cos_taylor_q824_tb.v` | `cos_taylor_q824.v` |
| `discount_engine_tb.v` | `discount_engine.v` |
| `div_q824_tb.v` | `div_q824.v` |
| `exp_taylor_q824_tb.v` | `exp_taylor_q824.v` |
| `ln_taylor_q824_tb.v` | `ln_taylor_q824.v` |
| `payoff_calculator_tb.v` | `payoff_calculator.v` |
| `rng_lfsr_32_tb.v` | `rng_lfsr_32.v` |
| `sde_solver_tb.v` | `sde_solver.v` |
| `sim_engine_ctrl_tb.v` | `sim_engine_ctrl.v` |
| `sin_taylor_q824_tb.v` | `sin_taylor_q824.v` |
| `sqrt_q824_tb.v` | `sqrt_q824.v` |

Waveforms are inspected in GTKWave to validate outputs against expected values.

## Testing
To run simulations:
1. Compile RTL files with your Verilog simulator (Icarus Verilog, Verilator, ModelSim).
2. Run testbenches for individual modules.
3. Verify top-level `heston_engine.v` with known input parameters.

Example:
```bash
iverilog -o sim heston_engine.v sim_engine_ctrl.v path_generator.v \
sde_solver.v correlation_noise.v rng_lfsr_32.v payoff_calculator.v \
discount_engine.v accumulator.v exp_taylor_q824.v cos_taylor_q824.v \
sin_taylor_q824.v ln_taylor_q824.v div_q824.v sqrt_q824.v \
sin_lut.v ln_lut.v sqrt_lut.v
vvp sim
gtkwave dump.vcd
```

## Author
Favour Anuoluwapo Iwueze
