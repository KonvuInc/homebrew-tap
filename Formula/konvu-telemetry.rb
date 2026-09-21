class KonvuTelemetry < Formula
  include Language::Python::Virtualenv

  desc "Local-first usage monitor for Claude Code and Codex CLI"
  homepage "https://github.com/KonvuInc/konvu-telemetry"
  url "https://github.com/KonvuInc/konvu-telemetry/releases/download/v0.1.0/konvu_telemetry-0.1.0.tar.gz"
  sha256 "26cd608a2492637e55b40f516cd3c65ddabd9bff33f5edc663685b52dba2d555"
  license "MIT"

  depends_on "python@3.14"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "Konvu Telemetry", shell_output("#{bin}/konvu-telemetry --help")
  end
end
