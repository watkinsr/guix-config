(use-modules
 (gnu)
 (srfi srfi-1)
 (gnu system nss)
 (gnu system locale)
 (ryan guix packages guile-wm-git))

(use-service-modules desktop ssh networking)
(use-package-modules certs suckless)

(operating-system
  (host-name "antelope")
  (timezone "Europe/London")
  (locale "en_US.UTF-8")

  (bootloader (grub-configuration (target "/dev/sda")))
  (swap-devices '("/dev/sda3"))

  (mapped-devices
   (list (mapped-device
          (source (uuid "cf04333a-5ebd-484a-a4b3-e649f47bcd02"))
          (target "the-partition")
          (type luks-device-mapping))))

  (file-systems (cons (file-system
                        (device "my-root")
                        (title 'label)
                        (mount-point "/")
                        (type "ext4")
                        (dependencies mapped-devices))
                      %base-file-systems))

  (users (cons (user-account
                (name "ryan")
                (group "users")
                (supplementary-groups '("wheel" "netdev"
                                        "audio" "video"))
                (home-directory "/home/ryan"))
               %base-user-accounts))

  ;; This is where we specify system-wide packages.
  (packages (cons* guile-wm-git
             nss-certs
             %base-packages))

  ;; include the X11 log-in service, networking with Wicd,
  ;; and more.
  (services (cons* (console-keymap-service "en-latin9")
		   (lsh-service #:port-number 22 #:x11-forwarding? #t #:public-key-authentication? #t #:allow-empty-passwords? #f #:password-authentication? #t)
		   (bluetooth-service)
	           (extra-special-file "/usr/bin/env"
                      (file-append coreutils "/bin/env"))
		   %desktop-services))

  ;; Allow resolution of '.local' host names with mDNS.
  (name-service-switch %mdns-host-lookup-nss))
