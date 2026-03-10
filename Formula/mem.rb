class Mem < Formula
  include Language::Python::Virtualenv

  desc "Privacy-first CLI that turns shell history into searchable memory"
  homepage "https://github.com/matinsaurralde/mem"
  url "https://github.com/matinsaurralde/mem/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "172c81800fdecc5c61caff9153c969c9fe64baef021c159fe03e71660191a669"
  license "MIT"
  head "https://github.com/matinsaurralde/mem.git", branch: "master"

  depends_on "python@3.12"

  def install
    python3 = Formula["python@3.12"].opt_bin/"python3.12"
    venv = virtualenv_create(libexec, python3)
    # Use pip with --python flag to allow binary wheels for Rust extensions (pydantic-core).
    # Homebrew's venv.pip_install forces --no-binary :all: which requires a Rust toolchain.
    system python3, "-m", "pip", "--python=#{libexec}/bin/python",
           "install", "click", "rich", "pydantic"
    venv.pip_install buildpath
    bin.install_symlink libexec/"bin/mem"
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
