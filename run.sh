#!/bin/bash
mkdir -p data models report src

touch src/main.py
touch report/forecast_report.md
touch README.md
touch requirements.txt
touch .gitignore

echo "venv/
.venv/
__pycache__/
*.pyc
*.pkl
.ipynb_checkpoints/" > .gitignore

echo "pandas
numpy
matplotlib
seaborn
statsmodels
scikit-learn
joblib" > requirements.txt

echo "Project structure created."