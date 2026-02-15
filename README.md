# Analysis of MOS Gas Sensor Baseline Drift under Sinusoidal Temperature Modulation

## 📖 Introduction

This repository contains the source code and analysis tools for investigating the **baseline drift phenomenon** in Metal-Oxide-Semiconductor (MOS) gas sensors. 
Specifically, this study focuses on sensors operating under **Sinusoidal Temperature Modulation (STM)** across varying preheating durations.

The project aims to quantify the impact of preheating time on sensor stability and develop robust feature extraction methods to mitigate drift effects in gas detection tasks.

---

## 📂 Repository Structure

The codebase is organized as follows:

```text
.
├── GasDetect.m                       # [Main] Core processing script for feature extraction & detection
├── SelectFilesByLeftRightText.m      # [Utility] Filters files based on specific string patterns
├── SelectFilesByRegExp.m             # [Utility] Filters files using Regular Expressions
├── mat/                              # [Data] Directory for storing/loading processed feature matrices
├── README.md                         # Project documentation
└── LICENSE                           # License file

1. Prerequisites
MATLAB

2. Running the Analysis
The main entry point is GasDetect.m. This script orchestrates the data loading, processing, and visualization pipeline.

Run the main script:

Matlab
GasDetect
Note: Ensure that the raw data path inside GasDetect.m points to the correct location where you unzipped the dataset.

3. File Selection Utilities
To handle large datasets with complex naming conventions (e.g., Gas_A_Conc_100ppm_Preheat_12h.txt), this repository provides two utility functions:

SelectFilesByLeftRightText: Matches files starting and ending with specific strings.

SelectFilesByRegExp: Uses regex patterns for advanced filtering.

📊 Dataset Availability
The raw experimental data used in this study, including the full voltage/resistance profiles for different preheating times, is hosted on IEEE DataPort.

Dataset Name: MOS Gas Sensor Dataset under STM with Varying Preheating Times

Access Link: Click here to view on IEEE DataPort (Please update this link)

The mat/ folder in this repository contains pre-processed feature matrices to facilitate quick reproduction of the results without re-processing the raw signals.

📝 Citation
If you use this code or the dataset in your research, please cite our paper:

Plain Text:

[Author Names]. "Mitigating Baseline Drift in Sinusoidal Temperature Modulated MOS Gas Sensors via Adaptive Feature Extraction." Journal Name, vol. XX, no. XX, pp. 1-10, 202X.


📧 Contact
For questions regarding the code or dataset, please open an issue in this repository or contact the author directly:

Email: [guolihua@mail.nwpu.edu.cn]
