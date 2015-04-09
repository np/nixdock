FROM scratch
MAINTAINER Jean-Francois Richard <jf.richard@heimdalsgata.com>
ADD tmp/nix-archive /nix/
ADD tmp/nix-archive/store/*-bash-*/bin/bash /bin/sh
WORKDIR /root
ENV HOME /root
ENV USER root
RUN \
  echo "root::0:"          >  /etc/group                         &&\
  echo "nixbld::1:nixbld1" >> /etc/group                         &&\
  echo "root::0:0::/root:/bin/sh"            >  /etc/passwd      &&\
  echo "nixbld1::1:1::/var/empty:/bin/false" >> /etc/passwd      &&\
  /nix/store/*-coreutils-*/bin/mkdir -p /tmp /usr/bin /var/empty &&\
  /nix/store/*-nix-*/bin/nix-store --init                        &&\
  /nix/store/*-nix-*/bin/nix-store --load-db < /nix/.reginfo     &&\
  /nix/store/*-nix-*/bin/nix-env --install                         \
    /nix/store/*-nix-*                                             \
    /nix/store/*-coreutils-*                                       \
    /nix/store/*-bash-*                                          &&\
  . /nix/store/*-nix-*/etc/profile.d/nix.sh                      &&\
  rm /nix/.reginfo /nix/install /bin/sh                          &&\
  echo '#!/root/.nix-profile/bin/bash'             >  /bin/nixdo &&\
  echo '. /root/.nix-profile/etc/profile.d/nix.sh' >> /bin/nixdo &&\
  echo '/root/.nix-profile/bin/bash -c "$*"'       >> /bin/nixdo &&\
  chmod +x /bin/nixdo                                            &&\
  ln -s /root/.nix-profile/bin/bash /bin/sh                      &&\
  ln -s /root/.nix-profile/bin/false /bin/false                  &&\
  ln -s /root/.nix-profile/bin/env /usr/bin/env                  &&\
  mkdir /nix/var/nix/manifests                                   &&\
  rm -rf `nix-collect-garbage --print-dead`                      &&\
  rm -rf `nix-collect-garbage --delete-old --print-dead`
ENTRYPOINT ["/bin/nixdo"]
CMD ["/bin/nixdo", "bash" ]
