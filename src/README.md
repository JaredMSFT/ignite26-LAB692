# Source

This folder contains the Python dependency and environment configuration used by the lab notebooks.

Create your local environment file before running the notebooks:

```powershell
Copy-Item src/.env.sample src/.env
```

Fill in `src/.env` with the values provided by the lab environment. The local `.env` file is ignored
by Git and must not be committed.

From the repository root, install the dependencies with:

```powershell
python -m pip install -r src/requirements.txt
```
