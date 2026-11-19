class Konvu < Formula
  desc "Security principles, PR checks and findings for coding agents"
  homepage "https://github.com/KonvuInc/konvu-cli"

  on_macos do
    on_arm do
      url "https://github.com/KonvuInc/konvu-cli/releases/download/v0.47.0/konvu-darwin-arm64.tar.gz"
      sha256 "143d32698a1a5b2131736a00781934c24251480b1e2542e56bc9bf6713924f26"
    end
    on_intel do
      url "https://github.com/KonvuInc/konvu-cli/releases/download/v0.47.0/konvu-darwin-amd64.tar.gz"
      sha256 "d1c0387d9c9d1ea00d52a88ee97e71e85ec8261dc946a65f339c0d499e1698b2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/KonvuInc/konvu-cli/releases/download/v0.47.0/konvu-linux-arm64.tar.gz"
      sha256 "778a2874f3ba8ce4b906b6fe1ac97935cb57e1153fb8a7eb81663ae94d85bcfa"
    end
    on_intel do
      url "https://github.com/KonvuInc/konvu-cli/releases/download/v0.47.0/konvu-linux-amd64.tar.gz"
      sha256 "1d98c786d3edb297b7eb1712e89f645c372559f008f9869fa165229ffd7e68e0"
    end
  end

  def install
    bin.install "konvu"
  end

  def caveats
    <<~EOS
      Install the bundled agent skills, and run it again after each upgrade:
        konvu skills install
    EOS
  end

  test do
    assert_match "\"version\": \"#{version}\"", shell_output("#{bin}/konvu version")
  end
end
