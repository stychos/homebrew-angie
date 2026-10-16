# frozen_string_literal: true

# Adds or updates the `bottle do` block for one Angie version in the formula.
#
#   ruby scripts/bottle-block.rb Formula/angie.rb <version> <root_url> <tag>=<sha256>...
#
# Lines for tags that are not passed are kept, so bottles added from elsewhere
# (e.g. by scripts/bottle-local.sh) survive a CI run for the same version.
# Lives in scripts/ because `brew doctor` rejects Ruby files in the tap root.
# Used by .github/workflows/publish.yml and scripts/bottle-local.sh.

formula_file, version, root_url, *bottles = ARGV
abort "usage: #{$PROGRAM_NAME} <formula> <version> <root_url> <tag>=<sha256>..." if bottles.empty?

source = File.read(formula_file)
blocks = source.scan(/^  bottle do\n.*?^  end\n/m)
block = blocks.find { |candidate| candidate.include?("/releases/download/#{version}\"") }

entries = {}
block.to_s.each_line do |line|
  match = line.match(/^\s+sha256 cellar: (\S+), (\w+):\s+"([0-9a-f]+)"$/)
  entries[match[2]] = [match[1], match[3]] if match
end
bottles.each do |bottle|
  tag, sha256 = bottle.split("=", 2)
  abort "expected <tag>=<sha256>, got: #{bottle}" unless sha256&.match?(/\A[0-9a-f]{64}\z/)

  # publish.yml has always recorded bottles as `cellar: :any`.
  entries[tag] = [":any", sha256]
end

width = entries.keys.map(&:length).max + 1
lines = entries.sort.map do |tag, (cellar, sha256)|
  format("    sha256 cellar: %<cellar>s, %<tag>-#{width}s \"%<sha256>s\"\n",
         cellar: cellar, tag: "#{tag}:", sha256: sha256)
end
new_block = "  bottle do\n    root_url \"#{root_url}\"\n#{lines.join}  end\n"

updated = if block
  source.sub(block) { new_block }
else
  # New version: insert after the existing blocks, before the first `depends_on`.
  source.sub(/^  depends_on/) { "#{new_block}\n  depends_on" }
end
File.write(formula_file, updated)
puts "#{block ? "Updated" : "Added"} bottle block #{version}: #{entries.keys.join(", ")}"
