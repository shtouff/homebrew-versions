class Logstash21 < Formula
  desc "Tool for managing events and logs"
  homepage "https://www.elastic.co/products/logstash"
  url "https://download.elastic.co/logstash/logstash/logstash-2.1.2.tar.gz"
  sha256 "5d396acf901558c49b231a954741b805a57a67a45ce6b22056fa296690b2cdab"

  conflicts_with "logstash", :because => "Different versions of same formula"

  head do
    url "https://github.com/elastic/logstash.git"
    depends_on :java => "1.8"
  end

  bottle :unneeded

  depends_on :java => "1.7+"

  def install
    if build.head?
      # Build the package from source
      system "rake", "artifact:tar"
      # Extract the package to the current directory
      mkdir "tar"
      system "tar", "--strip-components=1", "-xf", Dir["build/logstash-*.tar.gz"].first, "-C", "tar"
      cd "tar"
    end

    inreplace %w[bin/logstash], %r{^\. "\$\(cd `dirname \$SOURCEPATH`\/\.\.; pwd\)\/bin\/logstash\.lib\.sh\"}, ". #{libexec}/bin/logstash.lib.sh"
    inreplace %w[bin/plugin], %r{^\. "\$\(cd `dirname \$0`\/\.\.; pwd\)\/bin\/logstash\.lib\.sh\"}, ". #{libexec}/bin/logstash.lib.sh"
    inreplace %w[bin/logstash.lib.sh], /^LOGSTASH_HOME=.*$/, "LOGSTASH_HOME=#{libexec}"
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/logstash"
    bin.install_symlink libexec/"bin/plugin" => "logstash-plugin"
  end

  def caveats; <<-EOS.undent
    Please read the getting started guide located at:
      https://www.elastic.co/guide/en/logstash/current/getting-started-with-logstash.html
    The logstash `plugin` command is available as `logstash-plugin`.
    EOS
  end

  test do
    (testpath/"simple.conf").write <<-EOS.undent
      input { stdin { type => stdin } }
      output { stdout { codec => rubydebug } }
    EOS

    output = pipe_output("#{bin}/logstash -f simple.conf", "hello world\n")
    assert_match /hello world/, output
  end
end
