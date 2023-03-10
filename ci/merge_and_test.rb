# rubocop:disable all
puts "Checkout branch #{ARGV[0]}"
system("git checkout -b #{ARGV[0]} origin/#{ARGV[0]} 2>&1")
exit $?.exitstatus unless $?.exitstatus == 0

puts "Merge branch #{ARGV[0]} with 4.x"
system("git merge origin/4.x --no-edit 2>&1")
exit $?.exitstatus unless $?.exitstatus == 0

puts "Execute tests on branch #{ARGV[0]} after merge"
system("bundle exec rake 2>&1")
exit $?.exitstatus unless $?.exitstatus == 0
# rubocop:enable all