- Install and configure **[uv][uv]**:

  ```sh
  wget -qO- https://astral.sh/uv/install.sh | sh
  echo "export UV_LINK_MODE=copy" >> ~/.bashrc
  echo "export UV_ENV_FILE=.env" >> ~/.bashrc
  . ~/.bashrc
  ```

- Export Nomad variables:

  ```sh
  export NOMAD_TOKEN=
  export NOMAD_ADDR=
  export NOMAD_CACERT=
  export NOMAD_CLIENT_CERT=
  export NOMAD_CLIENT_KEY=
  ```

- Get list of available recipes:

  ```sh
  uv run list
  ```

- Deploy a recipe:

  ```sh
  uv run deploy
  ```
