# Ollama Switcher

Switch the Ollama CLI between a local daemon and a remote Ollama instance from the Omarchy bar.

The widget prompts for the remote endpoint on first launch. Left-click switches between local and remote; right-click edits the saved remote endpoint.

## Requirements

- Omarchy with the Quattro shell
- Ollama installed at `/usr/bin/ollama`
- Bash and standard GNU userland tools
- Network access to the remote Ollama API, typically over Tailscale

The plugin runs without root privileges. It writes endpoint state under `~/.config/omarchy/esh.ollama/`. It does not configure or expose the remote Ollama daemon for you.

## Install

```sh
omarchy plugin add https://github.com/ESHAYAT102/ollama-omarchy-plugin.git --enable
```

When enabled, the plugin installs a guarded CLI wrapper at `~/.local/bin/ollama`. It refuses to overwrite an unrelated file and refreshes its own wrapper after plugin updates. Omarchy places `~/.local/bin` before `/usr/bin` by default; open a new terminal after installation.

If an unrelated `~/.local/bin/ollama` already exists, move or remove it and reload the plugin. You can also run `~/.config/omarchy/plugins/esh.ollama/install.sh` directly.

## Configure The Remote Machine

The remote Ollama server must listen on its Tailscale address, and its firewall must allow TCP port `11434` from your tailnet. Confirm it from the Omarchy machine:

```sh
curl http://pc:11434/api/tags
```

Configure the remote system service according to the [Ollama FAQ](https://docs.ollama.com/faq#how-do-i-configure-ollama-server). If Ollama runs as a system user, ensure `OLLAMA_MODELS` points to the model store that user can access.

## Usage

- Left-click the bar icon to switch between local and remote Ollama.
- Right-click the icon to edit the remote endpoint.
- Enter a Tailscale hostname such as `pc:11434`, or a full URL such as `http://pc:11434`.
- Run `ollama ls`, `ollama run`, and other Ollama commands normally.

The active endpoint is stored in `~/.config/omarchy/esh.ollama/active-endpoint`. The configured remote is stored separately in `~/.config/omarchy/esh.ollama/remote-endpoint`.

## Validate

```sh
omarchy plugin validate .
qmllint -I "$OMARCHY_PATH/shell" BarWidget.qml Panel.qml
```

## Remove

Remove the CLI wrapper before removing the plugin:

```sh
~/.config/omarchy/plugins/esh.ollama/uninstall.sh --purge
omarchy plugin remove esh.ollama
```

Without `--purge`, the uninstaller preserves the saved endpoints.

## Publishing

Push this repository to a public GitHub repository, then submit its URL through the [Omarchy Plugin Marketplace form](https://github.com/omacom/omarchy-plugin-marketplace/issues/new?template=submit-plugin.yml).

## License

[MIT](LICENSE)
