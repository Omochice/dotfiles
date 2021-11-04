require "benchmark"

Benchmark.benchmark() do |x|
  count = 1000

  x.report("case1") do
    count.times do
      # call function
    end
  end

  x.report("case2") do
    count.times do
      # call function
    end
  end
end
