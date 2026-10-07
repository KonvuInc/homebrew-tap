class KonvuTelemetry < Formula
  include Language::Python::Virtualenv

  desc "Local-first usage monitor for Claude Code and Codex CLI"
  homepage "https://github.com/KonvuInc/konvu-telemetry"
  url "https://github.com/KonvuInc/konvu-telemetry/releases/download/v1.0.3/konvu_telemetry-1.0.3.tar.gz"
  sha256 "c44e1c2656490f99bd4ce642e245a1f7eb267844566980c58c26f4c598dc8bfe"
  license "MIT"

  depends_on "python@3.14"

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/0b/a7/71ac2cff56fec219ed242bb11b8efb69fcc4bec75db06fb7bfe35de520e6/certifi-2026.7.22-py3-none-any.whl"
    sha256 "62f22742b58a1a33014a2b6b706588a8d7e2a88ae7bd1a6ebe8c992928483775"
  end

  resource "charset-normalizer" do
    url "https://files.pythonhosted.org/packages/fc/ad/d07d7862a62ffa6d79d68074d14823243dd235a77c45262acbf6adeb28bf/charset_normalizer-3.5.2-py3-none-any.whl"
    sha256 "b6b751274acb69d77b3323d6b7dbaa3c7fdfc1eb829b7eb61d262f32e1af9685"
  end

  resource "ctok" do
    url "https://files.pythonhosted.org/packages/07/be/85fdcb8b6c901f0dfaf7da4bac125820cd501f73e69f7550131bb685a143/ctok-1.3.0-py3-none-any.whl"
    sha256 "84442682eeb2013ecb86861f9477b4ad3e19cc174099df98e9b5016450013217"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/58/a2/bb081bab032533a855d44de1d56f8e8426114ff1ba5d1f07a438a0a654f8/idna-3.20-py3-none-any.whl"
    sha256 "ab7ae7122974553370f0bdb919e1a960b2cd1bc1ef0276416d896db81c14582c"
  end

  resource "regex" do
    on_arm do
      url "https://files.pythonhosted.org/packages/dd/5f/52bc2abc3fef040cd9de76ab29c918d6a717a454ae2b9dd7938b0c95656d/regex-2026.9.29-cp314-cp314-macosx_11_0_arm64.whl"
      sha256 "0166844493626c5015c6088ee15c9ca2fd060ca15b7641d1657da6a58432ae33"
    end

    on_intel do
      url "https://files.pythonhosted.org/packages/9c/83/9b693a3fd1451381e812031a8961ec5b3b8f0c8cc6871f14c5223642804d/regex-2026.9.29-cp314-cp314-macosx_10_15_x86_64.whl"
      sha256 "c9b602fae1e00b7c035d661ce85575365719192a7b46784bd71cf64c68053aa0"
    end
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/a0/f4/c67b0b3f1b9245e8d266f0f112c500d50e5b4e83cb6f3b71b6528104182a/requests-2.34.2-py3-none-any.whl"
    sha256 "2a0d60c172f83ac6ab31e4554906c0f3b3588d37b5cb939b1c061f4907e278e0"
  end

  resource "tiktoken" do
    on_arm do
      url "https://files.pythonhosted.org/packages/62/85/2ae74575e321148484147e10b53c3b1717c59ebaa9edb4fe18b1f5c055f8/tiktoken-0.14.0-cp314-cp314-macosx_11_0_arm64.whl"
      sha256 "f2af4a336ea56d6c14f27741a0e1d8294a35dd0b038bcf990d232ebb54eb994b"
    end

    on_intel do
      url "https://files.pythonhosted.org/packages/59/b0/1cf129f4af8fc513931f931023def596b7c4bfc77026513cd9d851da9e88/tiktoken-0.14.0-cp314-cp314-macosx_10_15_x86_64.whl"
      sha256 "e067f4cbcc5d036e8aff7fe7a6b530a8f4de2e4616ad9005a24a1879e24e6450"
    end
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/92/9d/c4e665119135114480843e7ab388fa94d8480650450e6f8e26b70d323a4c/urllib3-2.8.0-py3-none-any.whl"
    sha256 "0cf3cae568d36aa9576b28dfb35f11328f1cb974ca7647d9475ebb86c75ac6e3"
  end

  def install
    venv = virtualenv_install_with_resources(without: %w[regex tiktoken])
    %w[regex tiktoken].each do |name|
      wheel = resource(name)
      wheel.stage { venv.pip_install Pathname.pwd/wheel.downloader.basename }
    end
    restart_after_upgrade = libexec/"restart-after-upgrade"
    restart_after_upgrade.write <<~SH
      #!/bin/sh
      service="gui/$(/usr/bin/id -u)/com.konvu.telemetry"
      /bin/launchctl print "$service" >/dev/null 2>&1 || exit 0
      exec /bin/launchctl kickstart -k "$service"
    SH
    restart_after_upgrade.chmod 0755
  end

  post_install_steps do
    on_macos do
      run "restart-after-upgrade", base: :libexec
    end
  end

  def caveats
    <<~EOS
      Before removing the formula, clean up the background service and CLI integrations:
        konvu-telemetry uninstall
        brew uninstall konvu-telemetry
    EOS
  end

  test do
    ENV["HOME"] = testpath
    port = free_port
    pid = nil
    pid = spawn bin/"konvu-telemetry", "serve", "--port", port.to_s, "--interval", "1"
    sleep 2
    output = shell_output("curl --silent --fail http://127.0.0.1:#{port}/healthz")
    assert_match '"status": "healthy"', output
  ensure
    if pid && Process.wait(pid, Process::WNOHANG).nil?
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
