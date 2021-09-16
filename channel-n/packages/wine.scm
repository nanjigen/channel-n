;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2014, 2015 Sou Bunnbu <iyzsong@gmail.com>
;;; Copyright © 2016 Ricardo Wurmus <rekado@elephly.net>
;;; Copyright © 2016, 2017, 2018 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2017, 2018, 2019 Rutger Helling <rhelling@mykolab.com>
;;; Copyright © 2017, 2020 Nicolas Goaziou <mail@nicolasgoaziou.fr>
;;; Copyright © 2018, 2019, 2020 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2019 Pierre Neidhardt <mail@ambrevar.xyz>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (channel-n packages wine)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages image)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages kerberos)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages mingw)
  #:use-module (gnu packages openldap)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages mp3)
  #:use-module (gnu packages photo)
  #:use-module (gnu packages samba)
  #:use-module (gnu packages scanner)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1))

(define-public wine
  (package
    (name "wine")
    (version "5.2")
    (source
     (origin
       (method url-fetch)
       (uri (let ((dir (string-append
                        (version-major version)
                        (if (string-suffix? ".0" (version-major+minor version))
                            ".0/"
                            ".x/"))))
              (string-append "https://dl.winehq.org/wine/source/" dir
                             "wine-" version ".tar.xz")))
       (sha256
        (base32 "0h2xm3dyy72yvyjgxn04nsf4r46q39pkx66fcc81vppay0s9q361"))))
    (build-system gnu-build-system)
    (native-inputs
     `(("bison" ,bison)
       ("flex" ,flex)
       ("gettext" ,gettext-minimal)
       ("perl" ,perl)
       ("pkg-config" ,pkg-config)))
    (inputs
     `(("alsa-lib" ,alsa-lib)
       ("dbus" ,dbus)
       ("cups" ,cups)
       ("eudev" ,eudev)
       ("faudio" ,faudio)
       ("fontconfig" ,fontconfig)
       ("freetype" ,freetype)
       ("gnutls" ,gnutls)
       ("gst-plugins-base" ,gst-plugins-base)
       ("lcms" ,lcms)
       ("libxml2" ,libxml2)
       ("libxslt" ,libxslt)
       ("libgphoto2" ,libgphoto2)
       ("libmpg123" ,mpg123)
       ("libldap" ,openldap)
       ("libnetapi" ,samba)
       ("libsane" ,sane-backends)
       ("libpcap" ,libpcap)
       ("libpng" ,libpng)
       ("libjpeg" ,libjpeg-turbo)
       ("libusb" ,libusb)
       ("libtiff" ,libtiff)
       ("libICE" ,libice)
       ("libX11" ,libx11)
       ("libXi" ,libxi)
       ("libXext" ,libxext)
       ("libXcursor" ,libxcursor)
       ("libXrender" ,libxrender)
       ("libXrandr" ,libxrandr)
       ("libXinerama" ,libxinerama)
       ("libXxf86vm" ,libxxf86vm)
       ("libXcomposite" ,libxcomposite)
       ("mit-krb5" ,mit-krb5)
       ("openal" ,openal)
       ("pulseaudio" ,pulseaudio)
       ("sdl2" ,sdl2)
       ("unixodbc" ,unixodbc)
       ("v4l-utils" ,v4l-utils)
       ("vkd3d" ,vkd3d)
       ("vulkan-loader" ,vulkan-loader)))
    (arguments
     `(;; Force a 32-bit build targeting a similar architecture, i.e.:
       ;; armhf for armhf/aarch64, i686 for i686/x86_64.
       #:system ,@(match (%current-system)
                    ((or "armhf-linux" "aarch64-linux")
                     `("armhf-linux"))
                    (_
                     `("i686-linux")))

       ;; XXX: There's a test suite, but it's unclear whether it's supposed to
       ;; pass.
       #:tests? #f

       #:configure-flags
       (list (string-append "LDFLAGS=-Wl,-rpath=" %output "/lib/wine32"))

       #:make-flags
       (list "SHELL=bash"
             (string-append "libdir=" %output "/lib/wine32"))

       #:phases
       (modify-phases %standard-phases
         ;; Explicitly set the 32-bit version of vulkan-loader when installing
         ;; to i686-linux or x86_64-linux.
         ;; TODO: Add more JSON files as they become available in Mesa.
         ,@(match (%current-system)
             ((or "i686-linux" "x86_64-linux")
              `((add-after 'install 'wrap-executable
                  (lambda* (#:key inputs outputs #:allow-other-keys)
                    (let* ((out (assoc-ref outputs "out"))
                           (icd (string-append out "/share/vulkan/icd.d")))
                      (mkdir-p icd)
                      (copy-file (string-append
                                  (assoc-ref inputs "mesa")
                                  "/share/vulkan/icd.d/radeon_icd.i686.json")
                                 (string-append icd "/radeon_icd.i686.json"))
                      (copy-file (string-append
                                  (assoc-ref inputs "mesa")
                                  "/share/vulkan/icd.d/intel_icd.i686.json")
                                 (string-append icd "/intel_icd.i686.json"))
                      (wrap-program (string-append out "/bin/wine-preloader")
                        `("VK_ICD_FILENAMES" ":" =
                          (,(string-append icd
                                           "/radeon_icd.i686.json" ":"
                                           icd "/intel_icd.i686.json"))))
                      #t)))))
             (_
              `()))
         (add-after 'configure 'patch-dlopen-paths
           ;; Hardcode dlopened sonames to absolute paths.
           (lambda _
             (let* ((library-path (search-path-as-string->list
                                   (getenv "LIBRARY_PATH")))
                    (find-so (lambda (soname)
                               (search-path library-path soname))))
               (substitute* "include/config.h"
                 (("(#define SONAME_.* )\"(.*)\"" _ defso soname)
                  (format #f "~a\"~a\"" defso (find-so soname))))
               #t)))
         (add-after 'patch-generated-file-shebangs 'patch-makefile
           (lambda* (#:key outputs #:allow-other-keys)
             (invoke "make" "Makefile") ; Makefile is first regenerated
             (substitute* "Makefile"
               (("-lntdll" id)
                (string-append id
                               " -Wl,-rpath=" (assoc-ref outputs "out")
                               "/lib/wine32/wine/$(ARCH)-unix")))
             #t)))))
    (home-page "https://www.winehq.org/")
    (synopsis "Implementation of the Windows API (32-bit only)")
    (description
     "Wine (originally an acronym for \"Wine Is Not an Emulator\") is a
compatibility layer capable of running Windows applications.  Instead of
simulating internal Windows logic like a virtual machine or emulator, Wine
translates Windows API calls into POSIX calls on-the-fly, eliminating the
performance and memory penalties of other methods and allowing you to cleanly
integrate Windows applications into your desktop.")
    ;; Any platform should be able to build wine, but based on '#:system' these
    ;; are thr ones we currently support.
    (supported-systems '("i686-linux" "x86_64-linux" "armhf-linux"))
    (license license:lgpl2.1+)))

(define-public wine64
  (package
    (inherit wine)
    (name "wine64")
    (inputs `(("wine" ,wine)
              ,@(package-inputs wine)))
    (arguments
     `(#:make-flags
       (list "SHELL=bash"
             (string-append "libdir=" %output "/lib/wine64"))
       #:phases
       (modify-phases %standard-phases
         ;; Explicitly set both the 64-bit and 32-bit versions of vulkan-loader
         ;; when installing to x86_64-linux so both are available.
         ;; TODO: Add more JSON files as they become available in Mesa.
         ,@(match (%current-system)
             ((or "x86_64-linux")
              `((add-after 'copy-wine32-binaries 'wrap-executable
                  (lambda* (#:key inputs outputs #:allow-other-keys)
                    (let* ((out (assoc-ref outputs "out")))
                      (wrap-program (string-append out "/bin/wine-preloader")
                        `("VK_ICD_FILENAMES" ":" =
                          (,(string-append
                             (assoc-ref inputs "mesa")
                             "/share/vulkan/icd.d/radeon_icd.x86_64.json" ":"
                             (assoc-ref inputs "mesa")
                             "/share/vulkan/icd.d/intel_icd.x86_64.json" ":"
                             (assoc-ref inputs "wine")
                             "/share/vulkan/icd.d/radeon_icd.i686.json" ":"
                             (assoc-ref inputs "wine")
                             "/share/vulkan/icd.d/intel_icd.i686.json"))))
                      (wrap-program (string-append out "/bin/wine64-preloader")
                        `("VK_ICD_FILENAMES" ":" =
                          (,(string-append
                             (assoc-ref inputs "mesa")
                             "/share/vulkan/icd.d/radeon_icd.x86_64.json"
                             ":" (assoc-ref inputs "mesa")
                             "/share/vulkan/icd.d/intel_icd.x86_64.json"
                             ":" (assoc-ref inputs "wine")
                             "/share/vulkan/icd.d/radeon_icd.i686.json"
                             ":" (assoc-ref inputs "wine")
                             "/share/vulkan/icd.d/intel_icd.i686.json"))))
                      #t)))))
             (_
              `()))
         (add-after 'patch-generated-file-shebangs 'patch-makefile
           (lambda* (#:key outputs #:allow-other-keys)
             (invoke "make" "Makefile") ; Makefile is first regenerated
             (substitute* "Makefile"
               (("-lntdll" id)
                (string-append id
                               " -Wl,-rpath=" (assoc-ref outputs "out")
                               "/lib/wine64/wine/$(ARCH)-unix")))
             #t))
         (add-after 'install 'copy-wine32-binaries
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((wine32 (assoc-ref %build-inputs "wine"))
                    (out (assoc-ref %outputs "out")))
               ;; Copy the 32-bit binaries needed for WoW64.
               (copy-file (string-append wine32 "/bin/wine")
                          (string-append out "/bin/wine"))
               ;; Copy the real 32-bit wine-preloader instead of the wrapped
               ;; version.
               (copy-file (string-append wine32 "/bin/.wine-preloader-real")
                          (string-append out "/bin/wine-preloader"))
               #t)))
         (add-after 'install 'copy-wine32-libraries
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((wine32 (assoc-ref %build-inputs "wine"))
                    (out (assoc-ref %outputs "out")))
               (copy-recursively (string-append wine32 "/lib/wine32")
                                 (string-append out "/lib/wine32"))
               #t)))
         (add-after 'compress-documentation 'copy-wine32-manpage
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((wine32 (assoc-ref %build-inputs "wine"))
                    (out (assoc-ref %outputs "out")))
               ;; Copy the missing man file for the wine binary from wine.
               (copy-file (string-append wine32 "/share/man/man1/wine.1.gz")
                          (string-append out "/share/man/man1/wine.1.gz"))
               #t)))
         (add-after 'configure 'patch-dlopen-paths
           ;; Hardcode dlopened sonames to absolute paths.
           (lambda _
             (let* ((library-path (search-path-as-string->list
                                   (getenv "LIBRARY_PATH")))
                    (find-so (lambda (soname)
                               (search-path library-path soname))))
               (substitute* "include/config.h"
                 (("(#define SONAME_.* )\"(.*)\"" _ defso soname)
                  (format #f "~a\"~a\"" defso (find-so soname))))
               #t))))
       #:configure-flags
       (list "--enable-win64"
             (string-append "LDFLAGS=-Wl,-rpath=" %output "/lib/wine64"))
       ,@(strip-keyword-arguments '(#:configure-flags #:make-flags #:phases
                                    #:system)
                                  (package-arguments wine))))
    (synopsis "Implementation of the Windows API (WoW64 version)")
    (supported-systems '("x86_64-linux" "aarch64-linux"))))

;; This minimal build of Wine is needed to prevent a circular dependency with
;; vkd3d.
(define-public wine-minimal
  (package
    (inherit wine)
    (name "wine-minimal")
    (native-inputs (fold alist-delete (package-native-inputs wine)
               '("gettext" "perl" "pkg-config")))
    (inputs `())
    (arguments
     `(#:validate-runpath? #f
       #:phases
       (modify-phases %standard-phases
         (add-after 'configure 'patch-dlopen-paths
           ;; Hardcode dlopened sonames to absolute paths.
           (lambda _
             (let* ((library-path (search-path-as-string->list
                                   (getenv "LIBRARY_PATH")))
                    (find-so (lambda (soname)
                               (search-path library-path soname))))
               (substitute* "include/config.h"
                 (("(#define SONAME_.* )\"(.*)\"" _ defso soname)
                  (format #f "~a\"~a\"" defso (find-so soname))))
               #t))))
       #:configure-flags
       (list "--without-freetype"
             "--without-x")
       ,@(strip-keyword-arguments '(#:configure-flags #:phases)
                                  (package-arguments wine))))))

wine
