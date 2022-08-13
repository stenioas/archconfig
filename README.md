# Guia de pós-instalação Archlinux

Guia testado em um Acer Nitro 5 an515-44, utilizando a ISO com drivers Nvidia.

<details><summary>Tabela de conteúdos</summary>

- [Configurações básicas](#🏁-configurações-básicas)
  - [Habilitando arquitetura de 32 bits](#multilib)
- [Instalando pacotes](#📦-instalando-pacotes)
  - [AUR Helpers](#aurhelpers)
    - [yay](#aurhelper-yay)
    - [Pamac](#aurhelper-pamac)
  - [Aplicações diversas](#misc-apps)
  - [Pacotes AUR](#aur-apps)
  - [Gnome](#misc-apps-gnome)
- [Restaurando backup](#💽-restaurando-backup)
- [Terminal](#terminal)
  - [Zsh](#zsh)
  - [Oh My Zsh](#oh-my-zsh)
  - [Plugins](#zsh-plugins)
  - [fzf](#fzf)
  - [Starship prompt](#starship)
- [Ambiente de Desenvolvimento](#👨‍💻-ambiente-de-desenvolvimento)
  - [Aplicações para desenvolvimento](#code-apps)
  - [asdf-vm](#asdf)
  - [Docker](#docker)
- [Restaurando chaves SSH](#🔑-restaurando-chaves-ssh)
- [Drivers de vídeo](#👾-drivers-de-vídeo)
- [Jogos](#🎮-jogos)
  - [Dependências Wine](#wine)
  - [Steam](#steam)
  - [Lutris](#lutris)
  - [League of Legends](#leagueoflegends)
- [Extras](#✨-extras)
  - [Obtendo temas](#get-themes)
- [Referências](#🔖-referências)

</details>

<br/>

## 🏁 Configurações básicas

<h3 id="multilib"></h3>

**Habilitando arquitetura 32 bits**

Descomente a seção `[multilib]` do arquivo `/etc/pacman.conf`

```bash
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Atualize a base de dados dos repositórios

```bash
sudo pacman -Sy
```

<br/>

## 📦 Instalando pacotes

<h3 id="aurhelpers"></h3>

**AUR Helpers**

<h3 id="aurhelper-yay"></h3>

Yay

```bash
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
```

<h3 id="aurhelper-pamac"></h3>

Pamac

```bash
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/pamac-aur.git && cd pamac-aur && makepkg -si
```

<h3 id="misc-apps"></h3>

**Aplicações diversas**

```bash
sudo pacman -S --needed firefox firefox-i18n-pt-br ntfs-3g glxgears git htop bashtop neofetch gimp inkscape vlc dconf-editor
```

<h3 id="aur-apps"></h3>

**Pacotes AUR**

```bash
yay -S google-chrome spotify
```

<h3 id="misc-apps-gnome"></h3>

**Gnome**

Indicador de apps na bandeja

```bash
sudo pacman -S --needed gnome-shell-extension-appindicator
```

Integração de aplicações Qt

```bash
sudo pacman -S --needed qt5ct kvantum-qt5
```

Definindo variável de ambiente

```bash
sudo sh -c 'echo "QT_QPA_PLATFORMTHEME=qt5ct" >> /etc/environment'
```

<br/>

## 💽 Restaurando backup

> **🚧 EM CONSTRUÇÃO 🚧**

<br/>

## >\_ Terminal

<h3 id="zsh"></h3>

**Zsh**

```bash
sudo pacman -S --needed zsh zsh-completions
```

<h3 id="oh-my-zsh"></h3>

**Oh My Zsh**

```bash
curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh; zsh
```

Alterando o shell padrão

```bash
sudo usermod --shell $(which zsh) $USER
```

<h3 id="zsh-plugins"></h3>

**Plugins**

- zsh-syntax-highlighting
- zsh-autosuggestions

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

Adicione os plugins ao arquivo `~/.zshrc` na seção plugins, como no exemplo abaixo:

```bash
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)
```

<h3 id="fzf"></h3>

**fzf**

Selecione "y" para todas as perguntas

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
```

<h3 id="starship"></h3>

**Starship prompt**

```bash
sudo pacman -S --needed starship
```

Adicione a linha abaixo ao arquivo `~/.zshrc`

```bash
eval "$(starship init zsh)"
```

<br/>

## 👨‍💻 Ambiente de Desenvolvimento

<h3 id="code-apps"></h3>

**Aplicações para desenvolvimento**

```bash
yay -S visual-studio-code-bin
```

<h3 id="asdf"></h3>

**asdf-vm**

```bash
yay -S asdf-vm
```

Adicione a linha abaixo ao arquivo `~/.zshrc`

```bash
. /opt/asdf-vm/asdf.sh
```

Recarregar as configurações do zsh

```bash
source ~/.zshrc
```

Exemplo adicionando plugin Nodejs:

```bash
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

Exemplo instalando versão lts do Nodejs:

```bash
asdf install nodejs lts
```

<h3 id="docker"></h3>

**Docker**

```bash
sudo pacman -S --needed docker docker-compose
```

<br/>

## 🔑 Restaurando chaves SSH

> **🚧 EM CONSTRUÇÃO 🚧**

<br/>

## 👾 Drivers de vídeo

> **INFO:** _Adiciona suporte a vulkan_

<h3 id="driver-intel"></h3>

**Intel**

```bash
sudo pacman -S --needed lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
```

<h3 id="driver-amd"></h3>

**AMD**

```bash
sudo pacman -S --needed lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
```

<h3 id="driver-nvidia"></h3>

**NVIDIA**

> **ALERTA!** O pacote `nvidia-lts` é recomendado caso você utilize o kernel `linux-lts`, para o kernel `linux` utilize o pacote `nvidia`

```bash
sudo pacman -S --needed nvidia-lts nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
```

<h3 id="optimus-manager"></h3>

**Optimus Manager**

```bash
yay -S optimus-manager
```

Arquivo de configuração

```bash
sudo cp /usr/share/optimus-manager.conf /etc/optimus-manager/optimus-manager.conf
```

Gnome

> **ALERTA!** _O gdm não é compatível com o optimus-manager, substitua-o pela versão com o patch_

```bash
yay -S gdm-prime
```

KDE Plasma

> **INFO:** _Optimus Manager na tray do Plasma_

```bash
yay -S optimus-manager-qt
```

<br/>

## 🎮 Jogos

> **ALERTA!** _A arquitetura de 32 bits precisa estar habilitada, acesse esse passo_ [aqui](#multilib)

<h3 id="wine"></h3>

**Dependências Wine**

```bash
sudo pacman -S --needed wine-staging wine-mono giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader
```

<h3 id="steam"></h3>

**Steam**

```bash
sudo pacman -S --needed steam
```

<h3 id="lutris"></h3>

**Lutris**

```bash
sudo pacman -S --needed lutris
```

<h3 id="leagueoflegends"></h3>

**League of Legends (Lutris)**

Instale o jogo através do script Lutris [aqui][lutris-lol]

Execute o comando abaixo para resolver o erro de inicialização do jogo

```bash
sudo sysctl -w "abi.vsyscall32=0" && sudo sh -c 'echo "# League of Legends\nabi.vsyscall32=0" > /etc/sysctl.d/99-lol.conf'
```

> **DICA:** Caso tenha problemas de tela preta na tela de carregamento das partidas, experimente habilitar a seguinte opção nas configurações do cliente:
>
> **Jogo > Gráficos > Optar pelo modo legado DX9**

<br/>

## ✨ Extras

<h3 id="get-themes"></h3>

**Obtendo temas**

Adwaita para aplicativos legado

```bash
yay -S adw-gtk3-git
```

Fluent-gkt-theme

```bash
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git && cd Fluent-gtk-theme && sudo ./install.sh -i arch --tweaks round solid
```

Papirus Icon Theme

```bash
sudo pacman -S --needed papirus-icon-theme
```

Papirus Folders

```bash
yay -S papirus-folders-git
```

Definindo a cor das pastas

```bash
papirus-folders -C yaru --theme Papirus-Dark
```

McMojave-cursors

```bash
git clone https://github.com/vinceliuice/McMojave-cursors.git && cd McMojave-cursors && sudo ./install.sh
```

---

## 🔖 Referências

- [Repositório oficial Oh My Zsh][ohmyzsh]
- [Repositório oficial fzf][fzf]
- [Guia oficial Starship][starship]
- [Guia oficial asdf-vm][asdfvm]
- [Guia do Docker na archwiki][archwiki-docker]
- [Guia oficial Lutris (Wine)][lutriswinedependencies]
- [Guia oficial Lutris (Drivers)][lutrisinstallingdrivers]
- [Repositório Papirus Folders][papirusfolders]
- [Repositório Fluent Gtk Theme][fluentgtktheme]
- [Repositório McMojave Cursors][mcmojavecursors]

---

**&copy; 2022 Stenio Silveira**

<!-- links -->

[ohmyzsh]: https://github.com/ohmyzsh/ohmyzsh
[fzf]: https://github.com/junegunn/fzf
[starship]: https://starship.rs/guide/
[yay]: https://github.com/Jguer/yay
[asdfvm]: https://asdf-vm.com/guide/getting-started.html#_1-install-dependencies
[archwiki-docker]: https://wiki.archlinux.org/title/docker#Installation
[lutrisinstallingdrivers]: https://github.com/lutris/docs/blob/master/InstallingDrivers.md#arch--manjaro--other-arch-linux-derivatives
[optimusmanager]: https://github.com/Askannz/optimus-manager
[lutriswinedependencies]: https://github.com/lutris/docs/blob/master/WineDependencies.md#archantergosmanjaroother-arch-derivatives
[lutris-lol]: https://lutris.net/games/league-of-legends/
[adwgtk3]: https://github.com/lassekongo83/adw-gtk3
[fluentgtktheme]: https://github.com/vinceliuice/Fluent-gtk-theme
[papirusfolders]: https://github.com/PapirusDevelopmentTeam/papirus-folders
[mcmojavecursors]: https://github.com/vinceliuice/McMojave-cursors
