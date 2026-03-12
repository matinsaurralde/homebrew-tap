class Mem < Formula
  include Language::Python::Virtualenv

  desc "Privacy-first CLI that turns shell history into searchable memory"
  homepage "https://github.com/matinsaurralde/mem"
  url "https://github.com/matinsaurralde/mem/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "7a021daaf764ff0b3563766375ae11e4f0a064fa030802d8c3141879e1ba0292"
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
    # Optional: install apple-fm-sdk for on-device AI features (macOS only).
    # Uses quiet_system to avoid aborting when the SDK can't install
    # (sandbox restrictions, non-Apple-Silicon, missing Apple Intelligence).
    if OS.mac?
      quiet_system python3, "-m", "pip", "--python=#{libexec}/bin/python",
                   "install", "--quiet", "apple-fm-sdk"
    end
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
