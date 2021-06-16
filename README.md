# Caterva Poster

Caterva poster for SciPy Conference 2021!


## Setup

1. Fork this repository and clone it:
   ```
   git clone https://github.com/<your-github-username>/caterva-scipy21
   ```

2. Create and activate a Python Virtual Environment:
   ```
   python -m venv .venv
   source .venv/bin/activate 
   python -m pip install -r requirements.txt
   ```

3. Launch the Jupyter notebook:
   ```
   jupyter notebook caterva_workshop.md
   ```
   Activate `View->Cell Toolbar->Slideshow` to display slides options.

4. Render the slides into `html` folder:
   ```
   ./generate_slides.sh
   ```
4. Deactivate the Virtual Environment:
   ```
   deactivate
   ```
