# Analysis of MOS Gas Sensor Baseline Drift under Sinusoidal Temperature Modulation During Preheating Period

## 📖 Introduction

This repository contains the source code for investigating the baseline drift phenomenon in Metal-Oxide-Semiconductor (MOS) gas sensors. 
Specifically, this study focuses on sensors operating under Sinusoidal Temperature Modulation across varying preheating durations.

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

📊 Dataset Availability
The raw experimental data used in this study, including the full conductance profiles for different preheating times, is hosted on IEEE DataPort.

Dataset Name: MOS Gas Sensor Responses under Sinusoidal Temperature Modulation with Multiple Preheating Durations

Access Link: Click here to view on IEEE DataPort (https://ieee-dataport.org/documents/mos-gas-sensor-responses-under-sinusoidal-temperature-modulation-multiple-preheating)

The .mat folder in this repository contains pre-processed feature matrices to facilitate quick reproduction of the results without re-processing the raw signals.

📝 Citation
If you use this code or the dataset in your research, please cite our paper:

Plain Text:

[Lihua Guo,Zhengqiao Zhao,Jingdong Chen,Jacob Benesty]. "A Phase-Based Feature for Gas Detection Under Unstable Preheating Condition for E-Noses." IEEE SPL, under review.


📧 Contact
For questions regarding the code or dataset, please open an issue in this repository or contact the author directly:

Email: [guolihua@mail.nwpu.edu.cn]
