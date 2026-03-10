class Mem < Formula
  include Language::Python::Virtualenv

  desc "Privacy-first CLI that turns shell history into searchable memory"
  homepage "https://github.com/matinsaurralde/mem"
  url "https://github.com/matinsaurralde/mem/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "f7053a1be96250d84d3f99d17f057db1f5570ac97dea295e5a9cb1b355d7830d"
  license "MIT"
  head "https://github.com/matinsaurralde/mem.git", branch: "master"

  depends_on "python@3.12"

  def install
    python3 = "python3.12"
    venv = virtualenv_create(libexec, python3)
    venv.pip_install "click"
    venv.pip_install "rich"
    venv.pip_install "pydantic"
    venv.pip_install buildpath
    bin.install_symlink libexec/"bin/mem"
  end

  def post_install
    zshrc = Pathname.new(Dir.home)/".zshrc"
    hook = 'eval "$(mem init zsh)"'
    unless zshrc.exist? && zshrc.read.include?(hook)
      zshrc.append_text("\n# mem — shell history memory\n#{hook}\n")
    end
  end

  def caveats
    <<~EOS
      Done! Reload your shell to activate:

        source ~/.zshrc
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
