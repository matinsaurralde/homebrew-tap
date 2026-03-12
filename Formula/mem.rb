class Mem < Formula
  include Language::Python::Virtualenv

  desc "Privacy-first CLI that turns shell history into searchable memory"
  homepage "https://github.com/matinsaurralde/mem"
  url "https://github.com/matinsaurralde/mem/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "e389c5e14c4af136729b4b41ab1ba14eb144968de6b11de98e98b4a4b1bf7093"
  license "MIT"
  head "https://github.com/matinsaurralde/mem.git", branch: "master"

  depends_on "python@3.12"

  def install
    python3 = Formula["python@3.12"].opt_bin/"python3.12"
    venv = virtualenv_create(libexec, python3)
    # Install deps without Rust extensions first
    system python3, "-m", "pip", "--python=#{libexec}/bin/python",
           "install", "click", "rich"
    # Install mem without pulling pydantic (installed in post_install)
    system python3, "-m", "pip", "--python=#{libexec}/bin/python",
           "install", "--no-deps", buildpath.to_s
    bin.install_symlink libexec/"bin/mem"
  end

  def post_install
    # Install pydantic after Homebrew's relocation step to avoid
    # dylib header rewriting failures with pydantic-core's Rust extension.
    python3 = Formula["python@3.12"].opt_bin/"python3.12"
    system python3, "-m", "pip", "--python=#{libexec}/bin/python",
           "install", "--quiet", "pydantic"
    # Install apple-fm-sdk for on-device AI pattern extraction (macOS only).
    # Fails gracefully on non-Apple-Silicon Macs; mem falls back to heuristics.
    system python3, "-m", "pip", "--python=#{libexec}/bin/python",
           "install", "--quiet", "apple-fm-sdk" if OS.mac?
  end

  def caveats
    <<~EOS
      Run one of these and restart your terminal:

        echo 'eval "$(mem init zsh)"' >> ~/.zshrc && source ~/.zshrc

        echo 'eval "$(mem init bash)"' >> ~/.bashrc && source ~/.bashrc
    EOS
  end

  test do
    # Verify CLI loads and responds
    assert_match "Usage", shell_output("#{bin}/mem --help")

    # Verify init outputs valid shell hook code
    output = shell_output("#{bin}/mem init zsh")
    assert_match "_mem_preexec", output
    assert_match "_mem_precmd", output
  end
end
