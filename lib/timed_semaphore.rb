class TimedSemaphore
  def initialize(num_of_ops, num_of_seconds)
    @count = 0
    @limit = num_of_ops
    @period = num_of_seconds
    @lock = Monitor.new
    @condition = @lock.new_cond
    @timer = nil
  end

  # Acquires a permit or sleeps the thread if all permits are exhausted
  def acquire
    synchronize do
      @condition.wait while @limit > 0 && @count == @limit
      @count += 1
      start_timer if @timer.nil?
    end
  end

  private

  # Starts a thread which releases all permits after @period seconds
  def start_timer
    synchronize do
      @timer = Thread.new do
        sleep(@period)
        release_permits
      end
    end
  end

  # Releases all permits and notifies all waiting threads to try acquire again
  def release_permits
    synchronize do
      @timer = nil
      @count = 0
      @condition.broadcast
    end
  end

  def synchronize(&block)
    fail 'No block given' unless block_given?
    @lock.synchronize(&block)
  end
end
