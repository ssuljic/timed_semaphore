# TimedSemaphore is a specialized implementation of a Semaphore
# that gives a number of permits in a given time frame. A use case
# for it is to limit the load on a resource.
# The idea is taken from the Apache Commons Lang package.
# @see https://commons.apache.org/proper/commons-lang/javadocs/api-3.1/org/apache/commons/lang3/concurrent/TimedSemaphore.html
#   Apache Commons Lang
#
# @author ssuljic
#
# @example
#   threads = []
#   semaphore = TimedSemaphore.new(2, 3)
#
#   10.times do |x|
#     threads << Thread.new do
#       semaphore.acquire
#       puts "Thread #{x}: " + Time.now.to_s
#     end
#   end
#
#   threads.map(&:join)
class TimedSemaphore
  # @param num_of_ops [Fixnum] Number of operations
  #   which should be allowed in a specified time frame.
  # @param num_of_seconds [Fixnum] Period in seconds after all
  #   permits are released.
  # @return [TimedSemaphore] a new instance of TimedSemaphore.
  def initialize(num_of_ops, num_of_seconds)
    @count = 0
    @limit = num_of_ops
    @period = num_of_seconds
    @lock = Monitor.new
    @condition = @lock.new_cond
    @timer = nil
  end

  # Tries to acquire a permit from the semaphore. This method
  # will block if the limit for the current period has already
  # been reached. The first call starts a timer thread for releasing
  # all permits, which makes the semaphore active
  def acquire
    synchronize do
      @condition.wait while @limit > 0 && @count == @limit
      @count += 1
      start_timer if @timer.nil?
    end
  end

  private

  # Starts a timer thread which releases
  # all permits after @period seconds.
  def start_timer
    synchronize do
      @timer = Thread.new do
        sleep(@period)
        release_permits
      end
    end
  end

  # Releases all permits and notifies all
  # waiting threads to try acquire again.
  def release_permits
    synchronize do
      @timer = nil
      @count = 0
      @condition.broadcast
    end
  end

  # Method used for synchronizing on @lock.
  # Syntactic sugar
  def synchronize(&block)
    fail 'No block given' unless block_given?
    @lock.synchronize(&block)
  end
end
