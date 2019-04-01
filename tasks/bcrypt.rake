# frozen_string_literal: true

namespace :bcrypt do
  # Display how much time (in milliseconds) is spent to compute a bcrypt hash
  # on this machine for each cost up to one full second.
  #
  # Pick a "safe" cost value (for your own definition of "safe"). In doubt,
  # Thomas Pornin's answer at https://security.stackexchange.com/a/3993 is a
  # good starting read.
  desc 'time spent to compute a bcrypt hash'
  task :cost do
    require 'bcrypt'
    require 'benchmark'
    cost = 4 # min bcrypt cost
    printf "BCrypt::Engine.cost\ttime(ms)\n"
    loop do
      BCrypt::Engine.cost = cost
      time = Benchmark.measure do
        BCrypt::Password.create('secret')
      end
      ms = 1000 * time.real
      printf "%19d\t%8d\n", cost, ms
      break if ms > 1000
      cost += 1
    end
  end
end
