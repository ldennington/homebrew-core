class GitCredentialManager < Formula
  desc "Secure, cross-platform Git credential storage with authentication to GitHub, Azure Repos, and other popular Git hosting services."
  homepage "https://gh.io/gcm"
  url "https://github.com/git-ecosystem/git-credential-manager/archive/refs/tags/v2.0.935.tar.gz"
  sha256 "30a027de376f31e41dd5b3b2083108944f833f2c78c5470e6b82d1b0fed43464"
  license "MIT"

  depends_on "dotnet" => :build

  def install
    tfm = "net6.0"
    cfg = "Release"
    outdir = "publish"

    if OS.mac?
      os = "osx"
    end

    if OS.linux?
      os = "linux"
    end

    if Hardware::CPU.arm?
      arch = "arm64"
    else
      arch = "x64"
    end

    rid = "#{os}-#{arch}"

    publish_args = %W[
      --configuration=#{cfg}
      --framework=#{tfm}
      --runtime=#{rid}
      --self-contained
      --output=#{outdir}
    ]

    projects = %W[
      src/shared/Git-Credential-Manager
      src/shared/Git-Credential-Manager.UI.Avalonia
      src/shared/Atlassian.Bitbucket.UI.Avalonia
      src/shared/GitHub.UI.Avalonia
      src/shared/GitLab.UI.Avalonia
    ]

    for proj in projects do
      system "dotnet", "publish", proj, *publish_args
    end

    libexec.install Dir["#{outdir}/*"]
    bin.install_symlink libexec/"git-credential-manager"
    bin.install_symlink "git-credential-manager" => "git-credential-manager-core"
  end

  def caveats
    <<~EOS
      Git Credential Manager can be set as the credential helper for Git using:
          git-credential-manager configure [--system]
      For more information, see the documentation: https://aka.ms/gcm/docs
    EOS
  end

  test do
    system "git-credential-manager", "--version"
  end
end
