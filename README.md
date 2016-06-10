# Ruby TimedSemaphore

### Description

A TimedSemaphore is a specialized implementation of a Semaphore that gives a number of permits in a given time frame. This gem is a Ruby implemention inspired by the Java implementation from the [Apache Commons Lang package](https://commons.apache.org/proper/commons-lang/javadocs/api-3.1/org/apache/commons/lang3/concurrent/TimedSemaphore.html).

### Installation

		gem install timed_semaphore

### Usage

Here is a basic example of using a TimedSemaphore
		require 'timed_semaphore'

		threads = []
		semaphore = TimedSemaphore.new(2, 3)

		10.times do
		  threads << Thread.new do
		    semaphore.acquire
		    puts Time.now
		  end
		end

		threads.map(&:join)

### Copyright

Please refer to [LICENSE](https://github.com/ssuljic/timed_semaphore/blob/master/LICENSE).