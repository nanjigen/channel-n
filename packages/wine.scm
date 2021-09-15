(define-public wine
  (package
    (name "wine-5.2")
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
        (base32 "02yr0l5xl76iz9shn1xmlx05ab61kp4yviddp079vi27whbpi10r"))))
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
