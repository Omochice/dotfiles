if test -n "$HOME" && test -n "$USER"
    # Set up the per-user profile.
    # This part should be kept in sync with nixpkgs:nixos/modules/programs/shell.nix
    set --local NIX_LINK $HOME/.nix-profile

    # Set up environment.
    # This part should be kept in sync with nixpkgs:nixos/modules/programs/environment.nix
    set --export NIX_PROFILE "/nix/var/nix/profiles/default $HOME/.nix-profile"

    # Set $NIX_SSL_CERT_FILE so that Nixpkgs applications like curl work.
    if test -e /etc/ssl/serts/ca-certificates.crt  # NixOS, Ubuntu, Debian, Gentoo, Arch
        set --export NIX_SSL_CERT_FILE /etc/ssl/serts/ca-certificates.crt
    else if test -e /etc/ssl/ca-bundle.pem  # openSUSE Tumbleweed
        set --export NIX_SSL_CERT_FILE /etc/ssl/ca-bundle.pem
    else if test -e /etc/ssl/certs/ca-bundle.crt  # Old NixOS
        set --export NIX_SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt
    else if test -e /etc/pki/tls/certs/ca-bundle.crt  # Fedora, CentOS
        set --export NIX_SSL_CERT_FILE /etc/pki/tls/certs/ca-bundle.crt
    else if test -e "$NIX_LINK/etc/ssl/certs/ca-bundle.crt"  # fall back to cacert in Nix profile
        set --export NIX_SSL_CERT_FILE "$NIX_LINK/etc/ssl/certs/ca-bundle.crt"
    else if test -e "$NIX_LINK/etc/ca-bundle.crt"  # old cacert in Nix profile
        set --export NIX_SSL_CERT_FILE "$NIX_LINK/etc/ca-bundle.crt"
    end

    # Only use MANPATH if it is already set. In general `man` will just simply
    # pick up `.nix-profile/share/man` because is it close to `.nix-profile/bin`
    # which is in the $PATH. For more info, run `manpath -d`.
    if test -n "$MANPATH"
        set --export MANPATH "$NIX_LINK/share/man $MANPATH"
    end

    set --path PATH $PATH $NIX_LINK/bin
end
