class KonvuTelemetry < Formula
  include Language::Python::Virtualenv

  desc "Local-first usage monitor for Claude Code and Codex CLI"
  homepage "https://github.com/KonvuInc/konvu-telemetry"
  url "https://github.com/KonvuInc/konvu-telemetry/releases/download/v0.3.5/konvu_telemetry-0.3.5.tar.gz"
  sha256 "f95a92cf49fed1699a67484184df55df1f7905b74ac13f056a4b47073b9d9291"
  license "MIT"
  revision 1

  depends_on "python@3.14"

  def install
    virtualenv_install_with_resources
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
