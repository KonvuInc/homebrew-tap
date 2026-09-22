class KonvuTelemetry < Formula
  include Language::Python::Virtualenv

  desc "Local-first usage monitor for Claude Code and Codex CLI"
  homepage "https://github.com/KonvuInc/konvu-telemetry"
  url "https://github.com/KonvuInc/konvu-telemetry/releases/download/v0.2.4/konvu_telemetry-0.2.4.tar.gz"
  sha256 "61fc74856c8ac6cfa91a05435fcefde9770c238bf41bd95c215f6b25d33c9786"
  license "MIT"

  depends_on "python@3.14"

  def install
    virtualenv_install_with_resources
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
