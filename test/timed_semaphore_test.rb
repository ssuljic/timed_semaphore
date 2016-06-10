require 'minitest/autorun'
require 'timed_semaphore'

class TimedSemaphoreTest < Minitest::Test
  def test_successful_acquire
    semaphore = TimedSemaphore.new(1, 10)
    t = create_waiting_thread(semaphore)
    assert_equal 'run', t.status
    assert_equal 'finished', t.value
  end

  def test_exhausted_permits
    semaphore = TimedSemaphore.new(1, 10)
    threads = []
    5.times { threads << create_waiting_thread(semaphore) }
    sleep(0.01)
    count_sleeping = threads.count { |t| t.status == 'sleep' }
    assert_equal 4, count_sleeping
  end

  def test_releasing_permits
    semaphore = TimedSemaphore.new(1, 2)
    t = create_waiting_thread(semaphore)
    sleep(0.01)
    assert_equal false, t.status
    t = create_waiting_thread(semaphore)
    sleep(0.01)
    assert_equal 'sleep', t.status
    sleep(2)
    assert_equal false, t.status
    assert_equal 'finished', t.value
  end

  private

  def create_waiting_thread(semaphore)
    Thread.new do
      semaphore.acquire
      'finished'
    end
  end
end