# mlr3changepoint - GSoC Test Submissions

This repository contains solutions to the Easy, Medium, and Hard tests for the [mlr3changepoint GSoC project](https://github.com/rstats-gsoc/gsoc2025/wiki/mlr3changepoint).

## Tests Completed

| Test | Description | Key Result |
|------|-------------|------------|
| [Easy](easy/) | Run one change-point algorithm and plot results | PELT detects 3 change-points correctly |
| [Medium](medium/) | Compare two algorithms on two datasets | PELT vs BinSeg show clear differences across datasets |
| [Hard](hard/) | IntervalRegressionCV on neuroblastoma with ROC curves | Accuracy: 97.66%, AUC: 0.9931 |

## Repository Structure
```
mlr3/
├── easy/
│   ├── easy_test.R
│   └── output/
├── medium/
│   ├── medium_test.R
│   └── output/
└── hard/
    ├── hard_test.R
    └── output/
```

## Packages Used
- `changepoint` - PELT algorithm
- `binsegRcpp` - Binary Segmentation
- `penaltyLearning` - IntervalRegressionCV and ROChange
- `ggplot2` - Visualization
- `data.table` - Data manipulation
