# My Modern Zsh Configuration

This repository contains my personal Zsh configuration, designed for a fast, powerful, and visually appealing terminal experience. It's built around the `zinit` plugin manager for performance and includes a highly customized prompt.

![Zsh Prompt Screenshot] (screenshot/screen.png)
## Features

-   **Fast Startup**: Uses `zinit` for efficient plugin and snippet loading.
-   **Modern Essentials**:
    -   **Syntax Highlighting**: `zsh-users/zsh-syntax-highlighting`
    -   **Auto Suggestions**: `zsh-users/zsh-autosuggestions`
    -   **Advanced Completions**: `zsh-users/zsh-completions`
-   **Fuzzy-Finder Integration**: `fzf-tab` replaces the default completion menu with `fzf` for interactive filtering.
-   **Smart History**: Extensive history configuration to avoid duplicates and share history across all terminals.
-   **Informative Custom Prompt**:
    -   Two-line prompt for clear separation.
    -   Left side shows `Host | User | Path`.
    -   Right side shows `Date | Time | Command execution time` (for commands taking >5s).
    -   Git branch and status indicator (`*` for modified).
    -   `[SSH]` and `[ROOT]` indicators when applicable.
-   **Smarter Navigation**: `zoxide` integration provides a supercharged `cd`.

## Prerequisites

Before you begin, you need to install the following tools.

-   **`zsh`**: The shell itself.
-   **`git`**: Required by `zinit` to download plugins.
-   **`fzf`**: A command-line fuzzy finder, essential for `fzf-tab`.
-   **`zoxide`**: A smarter `cd` command.
-   **`fastfetch`**: A system information tool (can be replaced with `neofetch` or removed).
-   **(Recommended)** A **Nerd Font** for the best visual experience with icons (though this prompt does not use them by default).

On a Debian/Ubuntu system, you can install most of them with:
```bash
sudo apt update
sudo apt install zsh git fzf
# zoxide and fastfetch might require different installation methods.
# For zoxide:
# curl -sS [https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh](https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh) | bash
# For fastfetch, check its official repository.
```

## Installation

1.  **Clone this Repository**
    Clone this repository to a location on your computer, for example `~/.config/zsh`.
    ```bash
    git clone [https://github.com/your-username/your-repo.git](https://github.com/your-username/your-repo.git) ~/.config/zsh
    ```

2.  **Back up your existing `.zshrc`**
    ```bash
    mv ~/.zshrc ~/.zshrc.bak
    ```

3.  **Create a Symbolic Link**
    Symlinking is the best way to manage your config. It allows you to pull updates from this Git repository without manually copying files.
    ```bash
    ln -s ~/.config/zsh/.zshrc ~/.zshrc
    ```

4.  **Create a Personal Aliases File**
    This configuration sources an optional `~/.zsh_aliases` file. Create it so the script doesn't complain.
    ```bash
    touch ~/.zsh_aliases
    ```
    You can add all your personal aliases here, like `alias ll='ls -lha'`.

5.  **Launch a New Zsh Session**
    Close your current terminal and open a new one, or run `zsh`. Zinit will automatically download and install all the necessary plugins. The new prompt and features will be active.

## Customization

-   **Plugins**: To add or remove plugins, simply edit the `zinit light ...` or `zinit snippet ...` lines in the `.zshrc` file.
-   **Aliases**: Add your personal aliases to the `~/.zsh_aliases` file.
-   **Startup Command**: The `fastfetch` command at the end of the file is what runs on startup. You can change it to `neofetch` or remove it completely.
-   **Prompt**: The prompt is highly customizable. Look for the `precmd()` function in the `.zshrc` file to change colors, separators, or the layout of the `PROMPT` and `RPROMPT` variables.

## License
This project is licensed under the MIT License.
