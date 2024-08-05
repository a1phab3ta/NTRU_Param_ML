# NTRU Hyperparameter Optimization with Machine Learning

This repository contains the code and scripts used to optimize the parameters for the NTRU encryption algorithm using machine learning techniques. The goal is to identify the best parameters for encryption and decryption times without compromising security.

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Data Preparation](#data-preparation)
- [Machine Learning Model](#machine-learning-model)
- [Usage](#usage)
- [Results](#results)
- [Contributing](#contributing)
- [License](#license)

## Introduction

In the post-quantum era, traditional cryptographic algorithms are vulnerable to quantum attacks. NTRU is a lattice-based cryptographic algorithm known for its efficiency and security in the post-quantum era. This project aims to optimize the parameters of the NTRU algorithm to achieve the best performance using machine learning.

## Prerequisites

- Python 3.x
- NumPy
- Pandas
- Scikit-learn
- Sympy
- GNU Core Utilities (for `dd` command in shell scripts)

## Data Preparation

To gather data for training the machine learning model, we perform a comprehensive parameter sweep using a shell script. This script measures encryption and decryption times for various parameter combinations.

### Shell Scripts

- **ntru_best_data.sh**: This script generates the best parameters for training the model.
- **test_parameters.sh**: This script runs with the best parameters predicted by the model and collects the data in `ntru_best_performance_data.csv`.

## Machine Learning Model

The machine learning model is implemented in a Jupyter Notebook. This notebook trains a RandomForestRegressor model to predict the optimal parameters for given message lengths based on the collected data.

### Jupyter Notebook

- **NTRU_parameter_tuning_ML.ipynb**: This notebook contains the code to train the machine learning model and predict the optimal NTRU parameters.

## Usage

1. Run the shell script to gather data:
    ```bash
    bash ntru_best_data.sh
    ```

2. Open the Jupyter Notebook to train the machine learning model:
    ```bash
    jupyter notebook NTRU_parameter_tuning_ML.ipynb
    ```

3. Use the trained model to predict optimal parameters for different message lengths as demonstrated in the notebook.

4. Test the data in ```predicted_parameters.csv``` using ```test_parameters.sh```
    ```bash
    bash test_parameters.sh
    ```
## Results

The models trained in this project can predict the optimal parameters for the NTRU encryption algorithm for any message length between 1 and 500, ensuring efficient encryption and decryption operations.

- **ntru_performance_data.csv**: Contains the raw performance data collected from running the shell script.
- **ntru_best_performance_data.csv**: Contains the best performance data identified by the machine learning model.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the GNU GPL-3.0 License.
