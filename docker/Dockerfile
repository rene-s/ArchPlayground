FROM archlinux:latest

ADD ./helpers/add-aur.sh /usr/sbin/add-aur
ADD ./helpers/add-users.sh /usr/sbin/add-users

RUN pacman-db-upgrade
RUN pacman -Syyu --noconfirm
RUN pacman -S --noconfirm \
git \
go \
zsh
RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
RUN locale-gen
RUN echo 'LANG=en_US.UTF-8' > /etc/locale.conf
RUN add-aur docker
RUN add-users
RUN su - docker -c "yay -S --noconfirm micro-bin"
RUN chsh -s /usr/bin/zsh root
RUN chsh -s /usr/bin/zsh docker
RUN chsh -s /usr/bin/zsh re

# @fixme This is rather inefficient
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN su - re -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN su - docker -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#RUN cp /usr/share/oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc
#RUN cp /usr/share/oh-my-zsh/templates/zshrc.zsh-template /home/re/.zshrc && chown re:users /home/re/.zshrc
#RUN cp /usr/share/oh-my-zsh/templates/zshrc.zsh-template /home/docker/.zshrc && chown docker:users /home/docker/.zshrc

# now to install from the AUR, you can do this:
# su docker -c "yay -S --noprogressbar --needed --noconfirm $PACKAGENAME"