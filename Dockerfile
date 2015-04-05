FROM ubuntu:trusty

MAINTAINER Roberto Carlos Martinez Arriaga <roberto.mtzarriaga@gmail.com>

RUN dpkg --add-architecture i386

RUN apt-get update && apt-get dist-upgrade -y

ENV uid=1000 gid=1000

RUN mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

RUN apt-get install p7zip-full xvfb wine -y

RUN sudo -H -u developer bash -c "WINEARCH=win32 WINEPREFIX=~/.wine winecfg && \
 xvfb-run winetricks --unattended vcrun2008"

RUN su developer && \
    mkdir line_tmp && \
    cd line_tmp && \
    wget http://dl.desktop.line.naver.jp/naver/LINE/win/LineInst.exe && \
    7z x -y LineInst.exe

RUN su developer || \
    inode1=$(ls -ilab | awk 'FNR == 4 {print $1}') || \
    inode2=$(ls -ilab | awk 'FNR == 6 {print $1}') || \
    find . -inum $inode1 -exec mv {} LINE \; || \
    find . -inum $inode2 -exec mv {} resources \; || \
    mv ./resources/res ./LINE || \
    mv ./LINE ../ || \
    cd .. || \
    rm -R line_tmp

CMD ["bash", "-C", "sudo -H -u developer /home/developer/LINE/LinePlayer/LinePlayer.exe"]
