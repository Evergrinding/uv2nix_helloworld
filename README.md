## Python Project with Nix & uv2nix

This template provides a reproducible Python development environment using Nix, uv, and uv2nix. It uses `direnv` for automatic shell activation.

### Prerequisites

Ensure you have the following installed:

  * **Nix** (with Flakes enabled)
  * **direnv**

-----

### Initial Setup

The first time you use this template, you must generate the initial **`uv.lock`** file.

1.  **Clone the Repository**: Get the project files onto your local machine.
2.  **Allow `direnv`**: Navigate into the directory and run:
    ```bash
    direnv allow
    ```
    This will fail and print instructions, which is expected.
3.  **Create the Lock File**: Follow the printed instructions to enter a temporary shell and create the lock file.
    ```bash
    nix develop .#impure
    uv lock
    git add uv.lock
    exit
    ```
4.  **Reload the Environment**: `direnv` will now detect the `uv.lock` file and automatically load the complete development environment.

-----

### Daily Usage

After the initial setup, `direnv` handles everything. Just `cd` into the project directory, and the correct Python interpreter and all your dependencies will be ready to use instantly.

-----

### Managing Dependencies

Follow this simple workflow to add, update, or remove Python packages.

1.  **Edit `pyproject.toml`**: Modify the `dependencies` list.
    ```toml
    # Example: pyproject.toml
    dependencies = [
      "numpy",
      "requests", # <-- Add or remove packages here
    ]
    ```
2.  **Update the Lock File**: Run the `uv lock` command directly in your terminal.
    ```bash
    uv lock
    ```
3.  **Reload the Environment**: Tell `direnv` to load the changes from the new lock file.
    ```bash
    direnv reload
    ```

Your shell is now updated with the new set of dependencies.