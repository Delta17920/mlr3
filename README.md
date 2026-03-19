# mlr3changepoint - GSoC Test Submissions

This repository contains solutions to the Easy, Medium, and Hard tests for the [mlr3changepoint GSoC project](https://github.com/rstats-gsoc/gsoc2026/wiki/mlr3changepoint).

## Tests Completed

| Test | Description | Key Result |
|------|-------------|------------|
| [Easy](easy/) | Run one change-point algorithm and plot results | PELT detects 3 change-points correctly |
| [Medium](medium/) | Compare two algorithms on two datasets | PELT vs BinSeg show clear differences across datasets |
| [Hard](hard/) | IntervalRegressionCV with 5-fold CV + BIC/SIC and constant baselines | Mean AUC: 0.9965, Mean Accuracy: ~98% |

## Repository Structure
```
mlr3/
├── easy/
│   ├── easy_test.R
│   ├── README.md
│   └── output/
├── medium/
│   ├── medium_test.R
│   ├── README.md
│   └── output/
└── hard/
    ├── hard_test.R
    ├── README.md
    └── output/
```

## Packages Used
- `changepoint` - PELT algorithm
- `binsegRcpp` - Binary Segmentation
- `penaltyLearning` - IntervalRegressionCV, ROChange, and AUC-based CV
- `ggplot2` - Visualization
- `data.table` - Data manipulation
- `survival` - Used internally by penaltyLearning
