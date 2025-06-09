# Dotfiles

## To install on new machine
1. Generate and configure SSH key for Github
    - Create key
    - Copy public key into Github
    - create .ssh/config file for first run
        - This file will be overwritten so updating the template in the next step is crucial
2. Modify repo for new machine hostname:
    - private_dot_ssh/private_config.tmpl
    - .chezmoi.toml.tmpl
3. Run single line install and application of chezmoi
    - ```sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com-$HOSTNAME:volk12/dotfiles.git```
