class Navicatonpremserver2 < Formula
  version "2.0.2"
  desc "Navicat On-Prem Server is an on-premise solution that provides you with the option to host a cloud environment for storing Navicat objects internally at your location. You can enjoy complete control over your system and maintain 100% privacy."
  homepage "https://www.navicat.com/en/products/navicat-on-prem-server"
  url "https://download3.navicat.com/onpremsvr2-download/homebrew/navicat-onprem-server-2.0.2.tar.gz"
  mirror "https://dn.navicat.com.cn/onpremsvr2-download/homebrew/navicat-onprem-server-2.0.2.tar.gz"
  sha256 "376e050b79cf5da3425d1eac5d50e3adf1824602b9dd6cf41918f8c81d2b08e0"

  def install
    # Preload
    system "./install.sh"
    libexec.install Dir["*"]
    
    system "codesign", "--entitlements", libexec/"app.entitlements", "--force", "--sign", "-", libexec/"libcc-web.dylib"
    system "codesign", "--entitlements", libexec/"app.entitlements", "--force", "--sign", "-", libexec/"libssl.3.dylib"
    system "codesign", "--entitlements", libexec/"app.entitlements", "--force", "--sign", "-", libexec/"libcrypto.3.dylib"
    system "codesign", "--entitlements", libexec/"app.entitlements", "--force", "--sign", "-", libexec/"libmariadb.3.dylib"
    system "codesign", "--entitlements", libexec/"app.entitlements", "--force", "--sign", "-", libexec/"libcc_wrap.so"
    system "codesign", "--entitlements", libexec/"app.entitlements", "--force", "--sign", "-", libexec/"navicatonpremserver"

    # Create script in /opt/homebrew/bin
    (libexec/"navicatonpremserver_env").write_env_script "#{libexec}/navicatonpremserver", DYLD_LIBRARY_PATH: libexec, NAVICAT_ONPREM_ROOT: libexec
    chmod 0755, libexec/"navicatonpremserver_env"
    bin.write_exec_script "#{libexec}/navicatonpremserver_env"
    mv "#{bin}/navicatonpremserver_env", "#{bin}/navicatonpremserver"
  end

  def post_install
    # Symlink
    rm_rf "#{libexec}/var"
    mkdir_p "#{var}/navicatonpremserver/var"
    ln_s "#{var}/navicatonpremserver/var", "#{libexec}/var"
    rm_rf "#{libexec}/log"
    mkdir_p "#{var}/navicatonpremserver/log"
    ln_s "#{var}/navicatonpremserver/log", "#{libexec}/log"
    rm_rf "#{libexec}/cert"
    mkdir_p "#{var}/navicatonpremserver/cert"
    ln_s "#{var}/navicatonpremserver/cert", "#{libexec}/cert"
    rm_rf "#{libexec}/tmp"
    mkdir_p "#{var}/navicatonpremserver/tmp"
    ln_s "#{var}/navicatonpremserver/tmp", "#{libexec}/tmp"
  end

  service do
    run [bin/"navicatonpremserver", "start"]
    # run [opt_bin/"mariadbd-safe", "--datadir=#{var}/mysql"]
    working_dir bin
  end

  test do
    system "navicatonpremserver", "version"
  end
end
